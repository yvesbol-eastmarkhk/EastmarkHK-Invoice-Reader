import Foundation

/// Native language names for the settings picker (aligned with EastmarkHK e-Invoicing).
enum AppLanguages {
    /// `id` is stored in UserDefaults; `nil` id means follow system language.
    struct Option: Identifiable, Hashable {
        var id: String { storageKey }
        let storageKey: String
        let packLocale: Locale?
        let nativeName: String
        let flag: String
    }

    static let system = Option(
        storageKey: "system",
        packLocale: nil,
        nativeName: "System language",
        flag: "🌐"
    )

    static let all: [Option] = [
        system,
        Option(storageKey: "en", packLocale: Locale(identifier: "en"), nativeName: "English", flag: "🇺🇸"),
        Option(storageKey: "en_GB", packLocale: Locale(identifier: "en_GB"), nativeName: "English (UK)", flag: "🇬🇧"),
        Option(storageKey: "en_AU", packLocale: Locale(identifier: "en_AU"), nativeName: "English (Australia)", flag: "🇦🇺"),
        Option(storageKey: "fr", packLocale: Locale(identifier: "fr"), nativeName: "Français", flag: "🇫🇷"),
        Option(storageKey: "fr_BE", packLocale: Locale(identifier: "fr_BE"), nativeName: "Français (Belgique)", flag: "🇧🇪"),
        Option(storageKey: "fr_CH", packLocale: Locale(identifier: "fr_CH"), nativeName: "Français (Suisse)", flag: "🇨🇭"),
        Option(storageKey: "fr_CA", packLocale: Locale(identifier: "fr_CA"), nativeName: "Français (Canada)", flag: "🇨🇦"),
        Option(storageKey: "nl", packLocale: Locale(identifier: "nl"), nativeName: "Nederlands", flag: "🇳🇱"),
        Option(storageKey: "nl_BE", packLocale: Locale(identifier: "nl_BE"), nativeName: "Nederlands (België)", flag: "🇧🇪"),
        Option(storageKey: "de", packLocale: Locale(identifier: "de"), nativeName: "Deutsch", flag: "🇩🇪"),
        Option(storageKey: "de_BE", packLocale: Locale(identifier: "de_BE"), nativeName: "Deutsch (Belgien)", flag: "🇧🇪"),
        Option(storageKey: "de_CH", packLocale: Locale(identifier: "de_CH"), nativeName: "Deutsch (Schweiz)", flag: "🇨🇭"),
        Option(storageKey: "es", packLocale: Locale(identifier: "es"), nativeName: "Español", flag: "🇪🇸"),
        Option(storageKey: "es_MX", packLocale: Locale(identifier: "es_MX"), nativeName: "Español (México)", flag: "🇲🇽"),
        Option(storageKey: "pt", packLocale: Locale(identifier: "pt"), nativeName: "Português", flag: "🇵🇹"),
        Option(storageKey: "pt_BR", packLocale: Locale(identifier: "pt_BR"), nativeName: "Português (Brasil)", flag: "🇧🇷"),
        Option(storageKey: "it", packLocale: Locale(identifier: "it"), nativeName: "Italiano", flag: "🇮🇹"),
        Option(storageKey: "it_CH", packLocale: Locale(identifier: "it_CH"), nativeName: "Italiano (Svizzera)", flag: "🇨🇭"),
        Option(storageKey: "ca", packLocale: Locale(identifier: "ca"), nativeName: "Català", flag: "🇪🇸"),
        Option(storageKey: "da", packLocale: Locale(identifier: "da"), nativeName: "Dansk", flag: "🇩🇰"),
        Option(storageKey: "sv", packLocale: Locale(identifier: "sv"), nativeName: "Svenska", flag: "🇸🇪"),
        Option(storageKey: "nb", packLocale: Locale(identifier: "nb"), nativeName: "Norsk bokmål", flag: "🇳🇴"),
        Option(storageKey: "fi", packLocale: Locale(identifier: "fi"), nativeName: "Suomi", flag: "🇫🇮"),
        Option(storageKey: "pl", packLocale: Locale(identifier: "pl"), nativeName: "Polski", flag: "🇵🇱"),
        Option(storageKey: "cs", packLocale: Locale(identifier: "cs"), nativeName: "Čeština", flag: "🇨🇿"),
        Option(storageKey: "sk", packLocale: Locale(identifier: "sk"), nativeName: "Slovenčina", flag: "🇸🇰"),
        Option(storageKey: "hu", packLocale: Locale(identifier: "hu"), nativeName: "Magyar", flag: "🇭🇺"),
        Option(storageKey: "ro", packLocale: Locale(identifier: "ro"), nativeName: "Română", flag: "🇷🇴"),
        Option(storageKey: "bg", packLocale: Locale(identifier: "bg"), nativeName: "Български", flag: "🇧🇬"),
        Option(storageKey: "hr", packLocale: Locale(identifier: "hr"), nativeName: "Hrvatski", flag: "🇭🇷"),
        Option(storageKey: "sl", packLocale: Locale(identifier: "sl"), nativeName: "Slovenščina", flag: "🇸🇮"),
        Option(storageKey: "el", packLocale: Locale(identifier: "el"), nativeName: "Ελληνικά", flag: "🇬🇷"),
        Option(storageKey: "tr", packLocale: Locale(identifier: "tr"), nativeName: "Türkçe", flag: "🇹🇷"),
        Option(storageKey: "uk", packLocale: Locale(identifier: "uk"), nativeName: "Українська", flag: "🇺🇦"),
        Option(storageKey: "ru", packLocale: Locale(identifier: "ru"), nativeName: "Русский", flag: "🇷🇺"),
        Option(storageKey: "he", packLocale: Locale(identifier: "he"), nativeName: "עברית", flag: "🇮🇱"),
        Option(storageKey: "ar", packLocale: Locale(identifier: "ar"), nativeName: "العربية", flag: "🇸🇦"),
        Option(storageKey: "hi", packLocale: Locale(identifier: "hi"), nativeName: "हिन्दी", flag: "🇮🇳"),
        Option(storageKey: "th", packLocale: Locale(identifier: "th"), nativeName: "ไทย", flag: "🇹🇭"),
        Option(storageKey: "vi", packLocale: Locale(identifier: "vi"), nativeName: "Tiếng Việt", flag: "🇻🇳"),
        Option(storageKey: "id", packLocale: Locale(identifier: "id"), nativeName: "Bahasa Indonesia", flag: "🇮🇩"),
        Option(storageKey: "ms", packLocale: Locale(identifier: "ms"), nativeName: "Bahasa Melayu", flag: "🇲🇾"),
        Option(storageKey: "ja", packLocale: Locale(identifier: "ja"), nativeName: "日本語", flag: "🇯🇵"),
        Option(storageKey: "ko", packLocale: Locale(identifier: "ko"), nativeName: "한국어", flag: "🇰🇷"),
        Option(storageKey: "zh_Hans", packLocale: Locale(identifier: "zh-Hans"), nativeName: "简体中文", flag: "🇨🇳"),
        Option(storageKey: "zh_Hant", packLocale: Locale(identifier: "zh-Hant"), nativeName: "繁體中文", flag: "🇹🇼"),
        Option(storageKey: "zh_HK", packLocale: Locale(identifier: "zh-HK"), nativeName: "繁體中文（香港）", flag: "🇭🇰"),
        Option(storageKey: "zh_TW", packLocale: Locale(identifier: "zh-TW"), nativeName: "繁體中文（台灣）", flag: "🇹🇼"),
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

    static func labeledTitle(for option: Option, systemLabel: String) -> String {
        "\(option.flag)  \(displayName(for: option.storageKey, systemLabel: systemLabel))"
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
