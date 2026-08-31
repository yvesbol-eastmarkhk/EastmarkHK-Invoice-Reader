import Foundation

enum PeppolParser {
    private static let cac = "urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2"
    private static let cbc = "urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2"

    static func parse(url: URL) throws -> PeppolInvoice {
        let data: Data
        do {
            data = try Data(contentsOf: url)
        } catch {
            throw PeppolParseError.invalidXML(error.localizedDescription)
        }

        let document: XMLDocument
        do {
            document = try XMLDocument(data: data, options: [.nodePreserveAll, .nodeCompactEmptyElement])
        } catch {
            throw PeppolParseError.invalidXML(error.localizedDescription)
        }

        guard let root = document.rootElement() else {
            throw PeppolParseError.missingRoot
        }

        let localName = root.localName ?? root.name ?? ""
        guard localName == "Invoice" || localName == "CreditNote" else {
            throw PeppolParseError.unsupportedDocument(localName)
        }

        var invoice = PeppolInvoice()
        invoice.documentType = localName == "CreditNote" ? "Credit Note" : "Invoice"
        invoice.sourcePath = url.path
        let rawContent = String(data: data, encoding: .utf8) ?? ""
        invoice.rawXML = prettyPrint(document: document)
        if invoice.rawXML.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            invoice.rawXML = rawContent
        }

        invoice.invoiceID = text(in: root, localName: "ID", namespace: cbc)
        invoice.issueDate = text(in: root, localName: "IssueDate", namespace: cbc)
        invoice.dueDate = text(in: root, localName: "DueDate", namespace: cbc)
        invoice.currency = text(in: root, localName: "DocumentCurrencyCode", namespace: cbc, default: "EUR")
        invoice.buyerReference = text(in: root, localName: "BuyerReference", namespace: cbc)
        invoice.note = text(in: root, localName: "Note", namespace: cbc)

        if let orderRef = firstElement(in: root, localName: "OrderReference", namespace: cac) {
            invoice.orderReference = text(in: orderRef, localName: "ID", namespace: cbc)
        }

        if let supplierParty = firstElement(
            in: root,
            path: [("AccountingSupplierParty", cac), ("Party", cac)]
        ) {
            invoice.supplier = parseParty(supplierParty)
        }

        if let customerParty = firstElement(
            in: root,
            path: [("AccountingCustomerParty", cac), ("Party", cac)]
        ) {
            invoice.customer = parseParty(customerParty)
        }

        for paymentMeans in allElements(in: root, localName: "PaymentMeans", namespace: cac) {
            invoice.payments.append(parsePaymentMeans(paymentMeans))
        }
        invoice.payment = invoice.payments.first ?? PaymentMeans()

        let lineTag = localName == "CreditNote" ? "CreditNoteLine" : "InvoiceLine"
        let qtyTag = localName == "CreditNote" ? "CreditedQuantity" : "InvoicedQuantity"
        for lineElement in elements(in: root, localName: lineTag, namespace: cac) {
            invoice.lines.append(parseLine(lineElement, quantityTag: qtyTag))
        }

        for subtotal in allElements(in: root, localName: "TaxSubtotal", namespace: cac) {
            invoice.taxBreakdown.append(parseTaxSubtotal(subtotal))
        }

        if let totals = firstElement(in: root, localName: "LegalMonetaryTotal", namespace: cac) {
            invoice.lineExtensionAmount = decimal(in: totals, localName: "LineExtensionAmount", namespace: cbc)
            invoice.taxExclusiveAmount = decimal(in: totals, localName: "TaxExclusiveAmount", namespace: cbc)
            invoice.taxInclusiveAmount = decimal(in: totals, localName: "TaxInclusiveAmount", namespace: cbc)
            invoice.prepaidAmount = decimal(in: totals, localName: "PrepaidAmount", namespace: cbc)
            invoice.payableAmount = decimal(in: totals, localName: "PayableAmount", namespace: cbc)
        }

        let embedded = extractEmbeddedPDF(from: root)
        invoice.embeddedPDF = embedded.0
        invoice.embeddedPDFFilename = embedded.1

        return invoice
    }

    /// PEPPOL suppliers often attach the real branded invoice PDF inside the XML.
    private static func extractEmbeddedPDF(from root: XMLElement) -> (Data?, String) {
        for docRef in allElements(in: root, localName: "AdditionalDocumentReference", namespace: cac) {
            guard let attachment = firstElement(in: docRef, localName: "Attachment", namespace: cac),
                  let binary = firstElement(in: attachment, localName: "EmbeddedDocumentBinaryObject", namespace: cbc),
                  let encoded = binary.stringValue?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !encoded.isEmpty else { continue }

            let mimeCode = binary.attribute(forName: "mimeCode")?.stringValue ?? ""
            let filename = binary.attribute(forName: "filename")?.stringValue ?? ""
            if mimeCode != "application/pdf" && !filename.lowercased().hasSuffix(".pdf") {
                continue
            }

            guard let data = Data(base64Encoded: encoded, options: .ignoreUnknownCharacters),
                  data.starts(with: Data("%PDF".utf8)) else { continue }

            return (data, filename)
        }
        return (nil, "")
    }

    private static func parseParty(_ partyElement: XMLElement) -> Party {
        var party = Party()

        if let legalEntity = firstElement(in: partyElement, localName: "PartyLegalEntity", namespace: cac) {
            party.name = text(in: legalEntity, localName: "RegistrationName", namespace: cbc)
            if party.name.isEmpty {
                party.name = text(in: legalEntity, localName: "CompanyID", namespace: cbc)
            }
            if party.vatNumber.isEmpty {
                party.vatNumber = text(in: legalEntity, localName: "CompanyID", namespace: cbc)
            }
        }

        if party.name.isEmpty,
           let partyName = firstElement(in: partyElement, localName: "PartyName", namespace: cac) {
            party.name = text(in: partyName, localName: "Name", namespace: cbc)
        }

        if let taxScheme = firstElement(in: partyElement, localName: "PartyTaxScheme", namespace: cac) {
            let vat = text(in: taxScheme, localName: "CompanyID", namespace: cbc)
            if !vat.isEmpty {
                party.vatNumber = vat
            }
        }

        if let address = firstElement(in: partyElement, localName: "PostalAddress", namespace: cac) {
            party.street = text(in: address, localName: "StreetName", namespace: cbc)
            if party.street.isEmpty {
                party.street = text(in: address, localName: "AdditionalStreetName", namespace: cbc)
            }
            party.city = text(in: address, localName: "CityName", namespace: cbc)
            party.postalZone = text(in: address, localName: "PostalZone", namespace: cbc)
            if let country = firstElement(in: address, localName: "Country", namespace: cac) {
                party.country = text(in: country, localName: "IdentificationCode", namespace: cbc)
            }
        }

        if let contact = firstElement(in: partyElement, localName: "Contact", namespace: cac) {
            party.email = text(in: contact, localName: "ElectronicMail", namespace: cbc)
            party.phone = text(in: contact, localName: "Telephone", namespace: cbc)
        }

        return party
    }

    private static func parseLine(_ lineElement: XMLElement, quantityTag: String) -> InvoiceLine {
        var line = InvoiceLine()
        line.lineID = text(in: lineElement, localName: "ID", namespace: cbc)
        line.lineTotal = decimal(in: lineElement, localName: "LineExtensionAmount", namespace: cbc)

        if let qtyElement = firstElement(in: lineElement, localName: quantityTag, namespace: cbc) {
            line.unitCode = qtyElement.attribute(forName: "unitCode")?.stringValue ?? ""
            line.quantity = decimal(from: qtyElement.stringValue ?? "0")
        }

        if let item = firstElement(in: lineElement, localName: "Item", namespace: cac) {
            line.itemName = text(in: item, localName: "Name", namespace: cbc)
            line.itemDescription = text(in: item, localName: "Description", namespace: cbc)
            if let sellersID = firstElement(in: item, localName: "SellersItemIdentification", namespace: cac) {
                line.itemReference = text(in: sellersID, localName: "ID", namespace: cbc)
            }
            if line.itemReference.isEmpty,
               let standardID = firstElement(in: item, localName: "StandardItemIdentification", namespace: cac) {
                line.itemReference = text(in: standardID, localName: "ID", namespace: cbc)
            }
            if let taxCategory = firstElement(in: item, localName: "ClassifiedTaxCategory", namespace: cac) {
                line.vatPercent = decimal(in: taxCategory, localName: "Percent", namespace: cbc)
            }
        }

        if let price = firstElement(in: lineElement, localName: "Price", namespace: cac) {
            line.unitPrice = decimal(in: price, localName: "PriceAmount", namespace: cbc)
        }

        return line
    }

    private static func parseTaxSubtotal(_ element: XMLElement) -> TaxBreakdown {
        var breakdown = TaxBreakdown()
        breakdown.taxableAmount = decimal(in: element, localName: "TaxableAmount", namespace: cbc)
        breakdown.taxAmount = decimal(in: element, localName: "TaxAmount", namespace: cbc)
        if let category = firstElement(in: element, localName: "TaxCategory", namespace: cac) {
            breakdown.percent = decimal(in: category, localName: "Percent", namespace: cbc)
            breakdown.category = text(in: category, localName: "ID", namespace: cbc)
        }
        return breakdown
    }

    private static func parsePaymentMeans(_ element: XMLElement) -> PaymentMeans {
        var payment = PaymentMeans()
        payment.paymentMeansCode = text(in: element, localName: "PaymentMeansCode", namespace: cbc)
        payment.paymentReference = text(in: element, localName: "PaymentID", namespace: cbc)

        if let account = firstElement(in: element, localName: "PayeeFinancialAccount", namespace: cac) {
            payment.iban = text(in: account, localName: "ID", namespace: cbc)
            if let branch = firstElement(in: account, localName: "FinancialInstitutionBranch", namespace: cac) {
                payment.bic = text(in: branch, localName: "ID", namespace: cbc)
            }
        }

        return payment
    }

    private static func prettyPrint(document: XMLDocument) -> String {
        let options: XMLNode.Options = [.nodePrettyPrint]
        let data = document.xmlData(options: options)
        guard let string = String(data: data, encoding: .utf8) else {
            return document.rootElement()?.xmlString ?? ""
        }
        return string
    }

    private static func firstElement(
        in parent: XMLElement,
        path: [(localName: String, namespace: String)]
    ) -> XMLElement? {
        var current: XMLElement? = parent
        for step in path {
            guard let element = current else { return nil }
            current = firstElement(in: element, localName: step.localName, namespace: step.namespace)
        }
        return current
    }

    private static func firstElement(
        in parent: XMLElement,
        localName: String,
        namespace: String
    ) -> XMLElement? {
        elements(in: parent, localName: localName, namespace: namespace).first
    }

    private static func elements(
        in parent: XMLElement,
        localName: String,
        namespace: String
    ) -> [XMLElement] {
        parent.children?.compactMap { node -> XMLElement? in
            guard let element = node as? XMLElement else { return nil }
            return matches(element, localName: localName, namespace: namespace) ? element : nil
        } ?? []
    }

    private static func allElements(
        in parent: XMLElement,
        localName: String,
        namespace: String
    ) -> [XMLElement] {
        var results: [XMLElement] = []
        for child in parent.children ?? [] {
            guard let element = child as? XMLElement else { continue }
            if matches(element, localName: localName, namespace: namespace) {
                results.append(element)
            }
            results.append(contentsOf: allElements(in: element, localName: localName, namespace: namespace))
        }
        return results
    }

    private static func matches(_ element: XMLElement, localName: String, namespace: String) -> Bool {
        guard element.localName == localName else { return false }
        guard let uri = element.uri else { return true }
        return uri == namespace
    }

    private static func text(
        in parent: XMLElement,
        localName: String,
        namespace: String,
        default defaultValue: String = ""
    ) -> String {
        guard let element = firstElement(in: parent, localName: localName, namespace: namespace) else {
            return defaultValue
        }
        return (element.stringValue ?? defaultValue).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func decimal(
        in parent: XMLElement,
        localName: String,
        namespace: String
    ) -> Decimal {
        guard let element = firstElement(in: parent, localName: localName, namespace: namespace) else {
            return 0
        }
        return decimal(from: element.stringValue ?? "0")
    }

    private static func decimal(from string: String) -> Decimal {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        return Decimal(string: trimmed) ?? 0
    }
}
