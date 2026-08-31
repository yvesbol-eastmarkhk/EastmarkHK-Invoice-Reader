import Foundation

struct Party: Equatable {
    var name = ""
    var vatNumber = ""
    var street = ""
    var city = ""
    var postalZone = ""
    var country = ""
    var email = ""
    var phone = ""

    var addressLines: [String] {
        var lines: [String] = []
        if !street.isEmpty { lines.append(street) }
        let cityLine = [postalZone, city].filter { !$0.isEmpty }.joined(separator: " ")
        if !cityLine.isEmpty { lines.append(cityLine) }
        if !country.isEmpty { lines.append(country) }
        return lines
    }
}

struct InvoiceLine: Identifiable, Equatable {
    var id: String { lineID }
    var lineID = ""
    var itemName = ""
    var itemDescription = ""
    var itemReference = ""
    var quantity: Decimal = 0
    var unitCode = ""
    var unitPrice: Decimal = 0
    var lineTotal: Decimal = 0
    var vatPercent: Decimal = 0

    var lineTotalInclVAT: Decimal {
        let hundred = Decimal(100)
        let factor = Decimal(1) + (vatPercent / hundred)
        return lineTotal * factor
    }

    var pdfDescription: String {
        if !itemDescription.isEmpty { return itemDescription }
        if !itemName.isEmpty { return itemName }
        return EnglishCatalog.strings["emptyDash"] ?? "—"
    }

    var pdfTitle: String {
        if !itemName.isEmpty, !itemDescription.isEmpty, itemName != itemDescription {
            return itemName
        }
        return ""
    }

    var quantityLabel: String {
        PeppolFormatting.quantity(quantity)
    }
}

struct TaxBreakdown: Equatable {
    var taxableAmount: Decimal = 0
    var taxAmount: Decimal = 0
    var percent: Decimal = 0
    var category = ""
}

struct PaymentMeans: Equatable {
    var paymentMeansCode = ""
    var iban = ""
    var bic = ""
    var paymentReference = ""
}

struct PeppolInvoice: Equatable {
    var invoiceID = ""
    var documentType = "Invoice"
    var issueDate = ""
    var dueDate = ""
    var currency = "EUR"
    var buyerReference = ""
    var orderReference = ""
    var note = ""

    var supplier = Party()
    var customer = Party()

    var lines: [InvoiceLine] = []
    var taxBreakdown: [TaxBreakdown] = []
    var payment = PaymentMeans()
    var payments: [PaymentMeans] = []

    var lineExtensionAmount: Decimal = 0
    var taxExclusiveAmount: Decimal = 0
    var taxInclusiveAmount: Decimal = 0
    var prepaidAmount: Decimal = 0
    var payableAmount: Decimal = 0

    var rawXML = ""
    var sourcePath = ""

    /// PDF already attached inside the PEPPOL XML (base64). When present, do not generate one.
    var embeddedPDF: Data?
    var embeddedPDFFilename = ""

    var hasEmbeddedPDF: Bool { embeddedPDF != nil }

    var totalVAT: Decimal {
        taxInclusiveAmount - taxExclusiveAmount
    }
}

enum PeppolParseError: LocalizedError {
    case invalidXML(String)
    case missingRoot
    case unsupportedDocument(String)

    var errorDescription: String? {
        switch self {
        case .invalidXML(let detail):
            return interpolate(EnglishCatalog.strings["errorInvalidXML"], ["detail": detail])
        case .missingRoot:
            return EnglishCatalog.strings["errorMissingRoot"]
        case .unsupportedDocument(let name):
            return interpolate(EnglishCatalog.strings["errorUnsupportedDocument"], ["name": name])
        }
    }

    @MainActor
    func localizedMessage() -> String {
        switch self {
        case .invalidXML(let detail):
            return L10n.shared.t("errorInvalidXML", ["detail": detail])
        case .missingRoot:
            return L10n.shared.t("errorMissingRoot")
        case .unsupportedDocument(let name):
            return L10n.shared.t("errorUnsupportedDocument", ["name": name])
        }
    }

    private func interpolate(_ template: String?, _ args: [String: String]) -> String {
        var value = template ?? ""
        for (name, replacement) in args {
            value = value.replacingOccurrences(of: "{\(name)}", with: replacement)
        }
        return value
    }
}

enum PeppolFormatting {
    static func displayDate(_ isoDate: String) -> String {
        let trimmed = isoDate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return EnglishCatalog.strings["emptyDash"] ?? "—" }
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.dateFormat = "yyyy-MM-dd"
        let output = DateFormatter()
        output.locale = Locale.autoupdatingCurrent
        output.dateStyle = .short
        output.timeStyle = .none
        if let date = input.date(from: trimmed) {
            return output.string(from: date)
        }
        return trimmed
    }

    static func frenchDate(_ isoDate: String) -> String {
        displayDate(isoDate)
    }

    static func euro(_ amount: Decimal) -> String {
        money(amount, currency: "EUR")
    }

    static func quantity(_ amount: Decimal) -> String {
        let number = NSDecimalNumber(decimal: amount)
        let formatter = NumberFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: number) ?? number.stringValue
    }

    static func formatVAT(_ vat: String) -> String {
        let cleaned = vat.replacingOccurrences(of: " ", with: "")
        if cleaned.hasPrefix("BE"), cleaned.count >= 12 {
            let digits = cleaned.dropFirst(2)
            let grouped = digits.enumerated().map { index, char -> String in
                (index > 0 && index % 3 == 0) ? ".\(char)" : String(char)
            }.joined()
            return "BE \(grouped)"
        }
        return vat
    }

    static func formatIBAN(_ iban: String) -> String {
        let cleaned = iban.replacingOccurrences(of: " ", with: "")
        guard !cleaned.isEmpty else { return iban }
        return stride(from: 0, to: cleaned.count, by: 4).map { start in
            let index = cleaned.index(cleaned.startIndex, offsetBy: start)
            let end = cleaned.index(index, offsetBy: min(4, cleaned.count - start))
            return String(cleaned[index..<end])
        }.joined(separator: " ")
    }

    static func formatAddress(_ party: Party) -> [String] {
        var lines: [String] = []
        if !party.street.isEmpty { lines.append(party.street) }
        var cityLine = ""
        if !party.country.isEmpty && !party.postalZone.isEmpty {
            cityLine = "\(party.country)-\(party.postalZone) \(party.city)"
        } else {
            cityLine = [party.postalZone, party.city].filter { !$0.isEmpty }.joined(separator: " ")
        }
        if !cityLine.isEmpty { lines.append(cityLine) }
        return lines
    }

    static func money(_ amount: Decimal, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSDecimalNumber(decimal: amount))
            ?? "\(NSDecimalNumber(decimal: amount).stringValue) \(currency)"
    }

    static func percent(_ value: Decimal) -> String {
        let number = NSDecimalNumber(decimal: value)
        let formatter = NumberFormatter()
        formatter.locale = Locale.autoupdatingCurrent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        let formatted = formatter.string(from: number) ?? number.stringValue
        return "\(formatted)%"
    }
}
