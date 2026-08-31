import Foundation

/// Native language names for the settings picker (aligned with EastmarkHK e-Invoicing).
enum AppLanguages {
    /// `id` is stored in UserDefaults; `nil` id means follow system language.
    struct Option: Identifiable, Hashable {
        var id: String { storageKey }
        let storageKey: String
        let packLocale: Locale?
        let nativeName: String
    }

    static let system = Option(storageKey: "system", packLocale: nil, nativeName: "System language")

    static let all: [Option] = [
        system,
        Option(storageKey: "en", packLocale: Locale(identifier: "en"), nativeName: "English"),
        Option(storageKey: "en_GB", packLocale: Locale(identifier: "en_GB"), nativeName: "English (UK)"),
        Option(storageKey: "en_AU", packLocale: Locale(identifier: "en_AU"), nativeName: "English (Australia)"),
        Option(storageKey: "fr", packLocale: Locale(identifier: "fr"), nativeName: "Français"),
        Option(storageKey: "fr_BE", packLocale: Locale(identifier: "fr_BE"), nativeName: "Français (Belgique)"),
        Option(storageKey: "fr_CH", packLocale: Locale(identifier: "fr_CH"), nativeName: "Français (Suisse)"),
        Option(storageKey: "fr_CA", packLocale: Locale(identifier: "fr_CA"), nativeName: "Français (Canada)"),
        Option(storageKey: "nl", packLocale: Locale(identifier: "nl"), nativeName: "Nederlands"),
        Option(storageKey: "nl_BE", packLocale: Locale(identifier: "nl_BE"), nativeName: "Nederlands (België)"),
        Option(storageKey: "de", packLocale: Locale(identifier: "de"), nativeName: "Deutsch"),
        Option(storageKey: "de_BE", packLocale: Locale(identifier: "de_BE"), nativeName: "Deutsch (Belgien)"),
        Option(storageKey: "de_CH", packLocale: Locale(identifier: "de_CH"), nativeName: "Deutsch (Schweiz)"),
        Option(storageKey: "es", packLocale: Locale(identifier: "es"), nativeName: "Español"),
        Option(storageKey: "es_MX", packLocale: Locale(identifier: "es_MX"), nativeName: "Español (México)"),
        Option(storageKey: "pt", packLocale: Locale(identifier: "pt"), nativeName: "Português"),
        Option(storageKey: "pt_BR", packLocale: Locale(identifier: "pt_BR"), nativeName: "Português (Brasil)"),
        Option(storageKey: "it", packLocale: Locale(identifier: "it"), nativeName: "Italiano"),
        Option(storageKey: "it_CH", packLocale: Locale(identifier: "it_CH"), nativeName: "Italiano (Svizzera)"),
        Option(storageKey: "ca", packLocale: Locale(identifier: "ca"), nativeName: "Català"),
        Option(storageKey: "da", packLocale: Locale(identifier: "da"), nativeName: "Dansk"),
        Option(storageKey: "sv", packLocale: Locale(identifier: "sv"), nativeName: "Svenska"),
        Option(storageKey: "nb", packLocale: Locale(identifier: "nb"), nativeName: "Norsk bokmål"),
        Option(storageKey: "fi", packLocale: Locale(identifier: "fi"), nativeName: "Suomi"),
        Option(storageKey: "pl", packLocale: Locale(identifier: "pl"), nativeName: "Polski"),
        Option(storageKey: "cs", packLocale: Locale(identifier: "cs"), nativeName: "Čeština"),
        Option(storageKey: "sk", packLocale: Locale(identifier: "sk"), nativeName: "Slovenčina"),
        Option(storageKey: "hu", packLocale: Locale(identifier: "hu"), nativeName: "Magyar"),
        Option(storageKey: "ro", packLocale: Locale(identifier: "ro"), nativeName: "Română"),
        Option(storageKey: "bg", packLocale: Locale(identifier: "bg"), nativeName: "Български"),
        Option(storageKey: "hr", packLocale: Locale(identifier: "hr"), nativeName: "Hrvatski"),
        Option(storageKey: "sl", packLocale: Locale(identifier: "sl"), nativeName: "Slovenščina"),
        Option(storageKey: "el", packLocale: Locale(identifier: "el"), nativeName: "Ελληνικά"),
        Option(storageKey: "tr", packLocale: Locale(identifier: "tr"), nativeName: "Türkçe"),
        Option(storageKey: "uk", packLocale: Locale(identifier: "uk"), nativeName: "Українська"),
        Option(storageKey: "ru", packLocale: Locale(identifier: "ru"), nativeName: "Русский"),
        Option(storageKey: "he", packLocale: Locale(identifier: "he"), nativeName: "עברית"),
        Option(storageKey: "ar", packLocale: Locale(identifier: "ar"), nativeName: "العربية"),
        Option(storageKey: "hi", packLocale: Locale(identifier: "hi"), nativeName: "हिन्दी"),
        Option(storageKey: "th", packLocale: Locale(identifier: "th"), nativeName: "ไทย"),
        Option(storageKey: "vi", packLocale: Locale(identifier: "vi"), nativeName: "Tiếng Việt"),
        Option(storageKey: "id", packLocale: Locale(identifier: "id"), nativeName: "Bahasa Indonesia"),
        Option(storageKey: "ms", packLocale: Locale(identifier: "ms"), nativeName: "Bahasa Melayu"),
        Option(storageKey: "ja", packLocale: Locale(identifier: "ja"), nativeName: "日本語"),
        Option(storageKey: "ko", packLocale: Locale(identifier: "ko"), nativeName: "한국어"),
        Option(storageKey: "zh_Hans", packLocale: Locale(identifier: "zh-Hans"), nativeName: "简体中文"),
        Option(storageKey: "zh_Hant", packLocale: Locale(identifier: "zh-Hant"), nativeName: "繁體中文"),
        Option(storageKey: "zh_HK", packLocale: Locale(identifier: "zh-HK"), nativeName: "繁體中文（香港）"),
        Option(storageKey: "zh_TW", packLocale: Locale(identifier: "zh-TW"), nativeName: "繁體中文（台灣）"),
    ]

    static func option(for storageKey: String) -> Option {
        all.first { $0.storageKey == storageKey } ?? system
    }

    static func displayName(for storageKey: String, systemLabel: String) -> String {
        if storageKey == system.storageKey {
            return systemLabel
        }
        return option(for: storageKey).nativeName
    }
}

enum LocalePreferences {
    private static let key = "ui_language_storage_key"

    static func load() -> String {
        UserDefaults.standard.string(forKey: key) ?? AppLanguages.system.storageKey
    }

    static func save(_ storageKey: String) {
        UserDefaults.standard.set(storageKey, forKey: key)
    }
}
