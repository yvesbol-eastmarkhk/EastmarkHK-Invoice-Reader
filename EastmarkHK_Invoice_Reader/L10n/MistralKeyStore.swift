import Foundation
import Security

/// Stores the Mistral API key the same way as EastmarkHK e-Invoicing:
/// Application Support file is the source of truth; Keychain is best-effort.
enum MistralKeyStore {
    static let consoleURL = URL(string: "https://console.mistral.ai/?profile_dialog=api-keys")!

    private static let account = "mistral_api_key"
    private static let service = "com.eastmarkhk.peppol-invoice-reader"
    private static let fileName = ".mistral_secret"

    static func load() -> String {
        if let fallback = readFallback(), !fallback.isEmpty {
            syncKeychain(fallback)
            return fallback
        }
        if let keychain = readKeychain(), !keychain.isEmpty {
            writeFallback(keychain)
            return keychain
        }
        if let imported = importFromEInvoicing(), !imported.isEmpty {
            try? save(imported)
            return imported
        }
        return ""
    }

    static func hasKey() -> Bool {
        !load().isEmpty
    }

    static func save(_ key: String) throws {
        let value = key.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty {
            delete()
            return
        }
        try assertPlausible(value)
        writeFallback(value)
        syncKeychain(value)
    }

    static func delete() {
        deleteFallback()
        deleteKeychain()
    }

    private static func assertPlausible(_ value: String) throws {
        if value.contains(where: { $0.isWhitespace }) || value.unicodeScalars.contains(where: { $0.value > 127 }) {
            throw MistralKeyError.invalid
        }
    }

    // MARK: - Application Support file

    private static func supportDirectory() -> URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
        let dir = base.appendingPathComponent("EastmarkHK Invoice Reader", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func fallbackFile() -> URL {
        supportDirectory().appendingPathComponent(fileName)
    }

    private static func writeFallback(_ key: String) {
        let data = Data(key.utf8).base64EncodedData()
        try? data.write(to: fallbackFile(), options: .atomic)
    }

    private static func readFallback() -> String? {
        decodeSecretFile(fallbackFile())
    }

    private static func deleteFallback() {
        try? FileManager.default.removeItem(at: fallbackFile())
    }

    private static func decodeSecretFile(_ url: URL) -> String? {
        guard let data = try? Data(contentsOf: url), !data.isEmpty else { return nil }
        let raw = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !raw.isEmpty, let decoded = Data(base64Encoded: raw),
              let key = String(data: decoded, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !key.isEmpty else {
            return nil
        }
        return key
    }

    /// Reuse the key already saved by EastmarkHK e-Invoicing on this Mac.
    private static func importFromEInvoicing() -> String? {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let folders = [
            "eastmarkhk_einvoicing",
            "EastmarkHK e-Invoicing",
            "EMHK e-Inv",
            "com.eastmarkhk.einvoicing",
        ]
        for folder in folders {
            if let support,
               let key = decodeSecretFile(support.appendingPathComponent(folder).appendingPathComponent(fileName)) {
                return key
            }
        }
        return nil
    }

    // MARK: - Keychain (best-effort)

    private static func readKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data,
              let key = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
              !key.isEmpty else {
            return nil
        }
        return key
    }

    private static func syncKeychain(_ key: String) {
        deleteKeychain()
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: Data(key.utf8),
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock,
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    private static func deleteKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
        SecItemDelete(query as CFDictionary)
    }
}

enum MistralKeyError: LocalizedError {
    case invalid
    case missing
    case requestFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalid:
            return EnglishCatalog.strings["settingsMistralInvalid"]
        case .missing:
            return EnglishCatalog.strings["settingsMistralMissing"]
        case .requestFailed(let detail):
            return detail
        }
    }
}
