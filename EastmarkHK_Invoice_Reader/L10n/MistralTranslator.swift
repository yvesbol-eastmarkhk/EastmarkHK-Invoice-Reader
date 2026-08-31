import Foundation

/// Mistral chat completions — fallback when Apple Translation is unavailable.
enum MistralTranslator {
    private static let endpoint = URL(string: "https://api.mistral.ai/v1/chat/completions")!
    private static let model = "mistral-small-latest"

    static func languageName(for code: String) -> String {
        let locale = Locale(identifier: "en")
        if let name = locale.localizedString(forIdentifier: code), !name.isEmpty {
            return name
        }
        if let name = locale.localizedString(forLanguageCode: code.split(separator: "-").first.map(String.init) ?? code) {
            return name
        }
        return code
    }

    static func translateUI(
        entries: [String: String],
        targetCode: String
    ) async throws -> [String: String] {
        let apiKey = MistralKeyStore.load()
        guard !apiKey.isEmpty else { throw MistralKeyError.missing }

        let language = languageName(for: targetCode)
        let system = """
        You are a professional UI localizer for a business invoicing app.
        Translate each JSON string value from English to \(language) (locale \(targetCode)).
        Rules:
        - Return ONE JSON object only: same keys as the input, values translated.
        - Keep placeholders like {name}, {filename}, {amount} exactly as-is.
        - Keep markers like ⟦T0⟧, ⟦T1⟧ exactly as-is.
        - Keep brand names EastmarkHK, PEPPOL, Mistral, PDF, XML, UBL, IBAN, BIC unchanged.
        - Do not add explanations or markdown.
        - Invoice glossary: Invoice = tax invoice (FR: Facture; DE: Rechnung; NL: Factuur).
          Supplier = seller (FR: Fournisseur). Customer = buyer (FR: Client).
          VAT = value-added tax (FR: TVA; DE: MwSt.; NL: btw).
        """

        let payload: [String: Any] = [
            "model": model,
            "temperature": 0.1,
            "response_format": ["type": "json_object"],
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": jsonObject(entries)],
            ],
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.timeoutInterval = 120
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard (200..<300).contains(status) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw MistralKeyError.requestFailed("Mistral error \(status): \(body)")
        }

        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = root["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw MistralKeyError.requestFailed("Mistral returned no choices.")
        }

        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let contentData = trimmed.data(using: .utf8),
              let decoded = try JSONSerialization.jsonObject(with: contentData) as? [String: Any] else {
            throw MistralKeyError.requestFailed("Mistral UI translation: expected a JSON object.")
        }

        var out: [String: String] = [:]
        for (key, value) in decoded {
            let text = "\(value)".trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty {
                out[key] = text
            }
        }
        return out
    }

    private static func jsonObject(_ entries: [String: String]) -> String {
        let data = (try? JSONSerialization.data(withJSONObject: entries, options: [.sortedKeys])) ?? Data()
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
