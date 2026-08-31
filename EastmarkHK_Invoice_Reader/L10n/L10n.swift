import Foundation

/// Follows the system language. English catalog is the source of truth;
/// other languages use curated packs, then Apple Translation (cached on disk).
@MainActor
final class L10n: ObservableObject {
    static let shared = L10n()

    @Published private(set) var revision = 0
    @Published private(set) var packCode = "en"
    @Published private(set) var strings: [String: String] = EnglishCatalog.strings
    @Published private(set) var languageStorageKey = LocalePreferences.load()
    @Published private(set) var translationProgress: TranslationProgress?

    private static let packAliases: [String: String] = [
        "fr-be": "fr",
        "fr-ch": "fr",
        "nl-be": "nl",
        "de-be": "de",
        "de-ch": "de",
        "it-ch": "it",
        "zh-hk": "zh-Hant",
        "zh-tw": "zh-Hant",
        "zh-mo": "zh-Hant",
        "zh-cn": "zh-Hans",
        "zh-sg": "zh-Hans",
    ]

    init() {
        applyEnglish()
        NotificationCenter.default.addObserver(
            forName: NSLocale.currentLocaleDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshForSystemLanguage()
            }
        }
    }

    func t(_ key: String, _ args: [String: String] = [:]) -> String {
        var value = strings[key] ?? EnglishCatalog.strings[key] ?? key
        for (name, replacement) in args {
            value = value.replacingOccurrences(of: "{\(name)}", with: replacement)
        }
        return value
    }

    func refreshForSystemLanguage() async {
        await loadLocale(Locale.autoupdatingCurrent)
    }

    func refreshForStoredLanguage() async {
        let key = LocalePreferences.load()
        languageStorageKey = key
        if key == AppLanguages.system.storageKey {
            await refreshForSystemLanguage()
            return
        }
        let option = AppLanguages.option(for: key)
        if let locale = option.packLocale {
            await loadLocale(locale)
        } else {
            await refreshForSystemLanguage()
        }
    }

    func setLanguage(storageKey: String) async {
        LocalePreferences.save(storageKey)
        languageStorageKey = storageKey
        await refreshForStoredLanguage()
    }

    private func loadLocale(_ locale: Locale) async {
        let code = Self.packCode(for: locale)
        packCode = code

        if code == "en" || code.hasPrefix("en-") {
            translationProgress = nil
            applyEnglish()
            return
        }

        if let cached = Self.loadCache(code: code), Self.isComplete(cached) {
            translationProgress = nil
            apply(Self.merge(cached, code: code))
            return
        }

        if let curated = CuratedPacks.pack(for: code) {
            let merged = Self.merge(curated, code: code)
            apply(merged)
            if Self.coversCatalog(merged) {
                translationProgress = nil
                return
            }
        } else {
            applyEnglish()
        }

        var translated: [String: String]?
        let languageName = Self.languageDisplayName(for: languageStorageKey)

        if await AppleTranslator.isAvailable(source: "en", target: code) {
            do {
                translated = try await translateWithApple(target: code, languageName: languageName)
            } catch {
                NSLog("L10n Apple Translation failed: %@", error.localizedDescription)
            }
        }
        if translated == nil || !Self.coversCatalog(Self.merge(translated ?? [:], code: code)) {
            if MistralKeyStore.hasKey() {
                do {
                    translated = try await translateWithMistral(target: code, languageName: languageName)
                } catch {
                    NSLog("L10n Mistral Translation failed: %@", error.localizedDescription)
                }
            }
        }
        translationProgress = nil
        guard let translated else { return }
        let merged = Self.merge(translated, code: code)
        apply(merged)
        Self.saveCache(code: code, strings: merged)
    }

    // MARK: - Pack code

    static func packCode(for locale: Locale) -> String {
        let lang = locale.language.languageCode?.identifier ?? "en"
        if lang == "zh" {
            let script = locale.language.script?.identifier ?? ""
            let region = locale.region?.identifier ?? ""
            if script == "Hans" || region == "CN" || region == "SG" {
                return "zh-Hans"
            }
            return "zh-Hant"
        }
        let region = locale.region?.identifier ?? ""
        let combined = region.isEmpty ? lang : "\(lang)-\(region)"
        let key = combined.lowercased()
        if let aliased = packAliases[key] { return aliased }
        if let aliased = packAliases[lang.lowercased()] { return aliased }
        return lang
    }

    // MARK: - Apply

    private func applyEnglish() {
        strings = EnglishCatalog.strings
        revision += 1
    }

    private func apply(_ map: [String: String]) {
        var next = EnglishCatalog.strings
        for (key, value) in map where !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            next[key] = value
        }
        for key in EnglishCatalog.criticalKeys {
            next[key] = EnglishCatalog.strings[key]
        }
        strings = next
        revision += 1
    }

    private static func merge(_ pack: [String: String], code: String) -> [String: String] {
        var merged = EnglishCatalog.strings
        if let curated = CuratedPacks.pack(for: code) {
            merged.merge(curated) { _, new in new }
        }
        merged.merge(pack) { _, new in new }
        for key in EnglishCatalog.criticalKeys {
            merged[key] = EnglishCatalog.strings[key]
        }
        return merged
    }

    private static func isComplete(_ pack: [String: String]) -> Bool {
        guard pack["__pack_generation"] == EnglishCatalog.generation else { return false }
        return Self.coversCatalog(pack)
    }

    private static func coversCatalog(_ pack: [String: String]) -> Bool {
        let needed = EnglishCatalog.strings.keys.filter { !EnglishCatalog.criticalKeys.contains($0) }
        return needed.allSatisfy { key in
            guard let value = pack[key] else { return false }
            return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    // MARK: - Apple Translation

    private static func translatableKeys() -> [String] {
        EnglishCatalog.strings.keys
            .filter { !EnglishCatalog.criticalKeys.contains($0) }
            .sorted()
    }

    private static func languageDisplayName(for storageKey: String) -> String {
        AppLanguages.option(for: storageKey).nativeName
    }

    private func translateWithApple(target: String, languageName: String) async throws -> [String: String] {
        let keys = Self.translatableKeys()
        let total = max(keys.count, 1)
        translationProgress = TranslationProgress(
            languageName: languageName,
            engineKey: "engineApple",
            done: 0,
            total: total
        )

        var result: [String: String] = [:]
        let chunk = 40
        var index = 0
        while index < keys.count {
            let slice = Array(keys[index..<min(index + chunk, keys.count)])
            var ids: [String] = []
            var texts: [String] = []
            var tokensByKey: [String: [String]] = [:]
            for key in slice {
                let (protected, tokens) = Self.protect(EnglishCatalog.strings[key] ?? "")
                tokensByKey[key] = tokens
                ids.append(key)
                texts.append(protected)
            }
            let raw = try await AppleTranslator.translateBatch(
                source: "en",
                target: target,
                ids: ids,
                texts: texts
            )
            for key in slice {
                if let text = raw[key], !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    result[key] = Self.restore(text, tokens: tokensByKey[key] ?? [])
                }
            }
            index += chunk
            translationProgress?.done = min(index, total)
        }
        return result
    }

    private func translateWithMistral(target: String, languageName: String) async throws -> [String: String] {
        let keys = Self.translatableKeys()
        let total = max(keys.count, 1)
        translationProgress = TranslationProgress(
            languageName: languageName,
            engineKey: "engineMistral",
            done: 0,
            total: total
        )

        var result: [String: String] = [:]
        let chunk = 40
        var index = 0
        while index < keys.count {
            let slice = Array(keys[index..<min(index + chunk, keys.count)])
            var payload: [String: String] = [:]
            var tokensByKey: [String: [String]] = [:]
            for key in slice {
                let (protected, tokens) = Self.protect(EnglishCatalog.strings[key] ?? "")
                tokensByKey[key] = tokens
                payload[key] = protected
            }
            let raw = try await MistralTranslator.translateUI(entries: payload, targetCode: target)
            for key in slice {
                if let text = raw[key], !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    result[key] = Self.restore(text, tokens: tokensByKey[key] ?? [])
                } else {
                    result[key] = EnglishCatalog.strings[key] ?? key
                }
            }
            index += chunk
            translationProgress?.done = min(index, total)
        }
        return result
    }

    private static func protect(_ input: String) -> (String, [String]) {
        var tokens: [String] = []
        var output = ""
        var index = input.startIndex
        while index < input.endIndex {
            if input[index] == "{",
               let end = input[index...].firstIndex(of: "}") {
                let token = String(input[index...end])
                let inner = token.dropFirst().dropLast()
                if !inner.isEmpty, inner.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "_" }) {
                    tokens.append(token)
                    output += "⟦T\(tokens.count - 1)⟧"
                    index = input.index(after: end)
                    continue
                }
            }
            output.append(input[index])
            index = input.index(after: index)
        }
        return (output, tokens)
    }

    private static func restore(_ input: String, tokens: [String]) -> String {
        var s = input
        for (i, token) in tokens.enumerated() {
            for marker in ["⟦T\(i)⟧", "<T\(i)>", "[T\(i)]", "(T\(i))"] {
                s = s.replacingOccurrences(of: marker, with: token)
            }
        }
        return s
    }

    // MARK: - Disk cache

    private static func cacheDirectory() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let dir = base.appendingPathComponent("EastmarkHK Invoice Reader/ui_l10n", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func loadCache(code: String) -> [String: String]? {
        let url = cacheDirectory().appendingPathComponent("\(code).json")
        guard let data = try? Data(contentsOf: url),
              let raw = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
            return nil
        }
        return raw
    }

    private static func saveCache(code: String, strings: [String: String]) {
        var payload = strings
        payload["__pack_generation"] = EnglishCatalog.generation
        let url = cacheDirectory().appendingPathComponent("\(code).json")
        guard let data = try? JSONSerialization.data(withJSONObject: payload, options: [.prettyPrinted]) else {
            return
        }
        try? data.write(to: url, options: .atomic)
    }
}
