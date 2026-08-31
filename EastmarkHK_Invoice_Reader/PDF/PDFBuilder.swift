import AppKit
import Foundation

@MainActor
enum PDFBuilder {
    private static func s(_ key: String, _ args: [String: String] = [:]) -> String {
        L10n.shared.t(key, args)
    }

    private static let pageWidth: CGFloat = 595.28
    private static let pageHeight: CGFloat = 841.89
    private static let margin: CGFloat = 40
    private static let contentWidth: CGFloat = pageWidth - margin * 2

    private static let green = NSColor(calibratedRed: 0.18, green: 0.55, blue: 0.42, alpha: 1)
    private static let greenLight = NSColor(calibratedRed: 0.93, green: 0.97, blue: 0.95, alpha: 1)
    private static let greenDark = NSColor(calibratedRed: 0.12, green: 0.38, blue: 0.30, alpha: 1)
    private static let textDark = NSColor(calibratedRed: 0.12, green: 0.14, blue: 0.16, alpha: 1)
    private static let textMuted = NSColor(calibratedWhite: 0.45, alpha: 1)
    private static let border = NSColor(calibratedWhite: 0.82, alpha: 1)
    private static let rowAlt = NSColor(calibratedWhite: 0.97, alpha: 1)

    static func build(invoice: PeppolInvoice) -> Data {
        let data = NSMutableData()
        var mediaBox = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        guard let consumer = CGDataConsumer(data: data as CFMutableData),
              let context = CGContext(consumer: consumer, mediaBox: &mediaBox, nil) else {
            return Data()
        }

        var y = pageHeight - margin
        context.beginPDFPage(nil)

        y = drawTopBanner(context: context, y: y)
        y = drawTitleBlock(context: context, invoice: invoice, y: y)
        y = drawPartyBoxes(context: context, invoice: invoice, y: y)
        y = drawLinesTable(context: context, invoice: invoice, y: y, mediaBox: &mediaBox)
        y = drawTotalsBlock(context: context, invoice: invoice, y: y, mediaBox: &mediaBox)
        y = drawPaymentSection(context: context, invoice: invoice, y: y, mediaBox: &mediaBox)
        _ = drawFooter(context: context, invoice: invoice, y: y)

        context.endPDFPage()
        context.closePDF()
        return data as Data
    }

    // MARK: - Header

    private static func drawTopBanner(context: CGContext, y: CGFloat) -> CGFloat {
        fillRect(CGRect(x: margin, y: y - 52, width: contentWidth, height: 52), color: greenLight, context: context)
        strokeRect(CGRect(x: margin, y: y - 52, width: contentWidth, height: 52), color: green.withAlphaComponent(0.25), context: context)

        let badgeRect = CGRect(x: margin + contentWidth - 170, y: y - 40, width: 156, height: 28)
        fillRect(badgeRect, color: green, context: context)
        drawCenteredText(s("pdfPeppolBadge"), in: badgeRect, font: .boldSystemFont(ofSize: 10), color: .white, context: context)

        return y - 64
    }

    private static func drawTitleBlock(context: CGContext, invoice: PeppolInvoice, y: CGFloat) -> CGFloat {
        let cursorY = drawText(s("pdfInvoice"), at: CGPoint(x: margin, y: y - 28), font: .boldSystemFont(ofSize: 26), color: greenDark, context: context)

        let metaY = cursorY - 8
        let metaItems: [(String, String)] = [
            (s("pdfNumber"), invoice.invoiceID.isEmpty ? s("emptyDash") : invoice.invoiceID),
            (s("pdfDate"), PeppolFormatting.displayDate(invoice.issueDate)),
            (s("pdfDue"), PeppolFormatting.displayDate(invoice.dueDate)),
        ]
        var x = margin
        for (index, item) in metaItems.enumerated() {
            drawText(item.0, at: CGPoint(x: x, y: metaY - 12), font: .boldSystemFont(ofSize: 10), color: textMuted, context: context)
            let labelWidth = (item.0 as NSString).size(withAttributes: [.font: NSFont.boldSystemFont(ofSize: 10)]).width
            drawText(item.1, at: CGPoint(x: x + labelWidth + 4, y: metaY - 12), font: .systemFont(ofSize: 10), color: textDark, context: context)
            x += labelWidth + ((item.1 as NSString).size(withAttributes: [.font: NSFont.systemFont(ofSize: 10)]).width) + 28
            if index < metaItems.count - 1 { x += 8 }
        }

        context.setStrokeColor(green.withAlphaComponent(0.35).cgColor)
        context.setLineWidth(1)
        context.move(to: CGPoint(x: margin, y: metaY - 24))
        context.addLine(to: CGPoint(x: margin + contentWidth, y: metaY - 24))
        context.strokePath()

        return metaY - 36
    }

    // MARK: - Parties

    private static func drawPartyBoxes(context: CGContext, invoice: PeppolInvoice, y: CGFloat) -> CGFloat {
        let gap: CGFloat = 16
        let boxWidth = (contentWidth - gap) / 2
        let leftRect = CGRect(x: margin, y: y - 130, width: boxWidth, height: 130)
        let rightRect = CGRect(x: margin + boxWidth + gap, y: y - 130, width: boxWidth, height: 130)

        drawPartyBox(title: s("pdfSupplier"), party: invoice.supplier, rect: leftRect, context: context)
        drawPartyBox(title: s("pdfCustomer"), party: invoice.customer, rect: rightRect, context: context)

        return y - 146
    }

    private static func drawPartyBox(title: String, party: Party, rect: CGRect, context: CGContext) {
        fillRect(rect, color: .white, context: context)
        strokeRect(rect, color: border, context: context)
        fillRect(CGRect(x: rect.minX, y: rect.maxY - 24, width: rect.width, height: 24), color: green, context: context)
        drawText(title, at: CGPoint(x: rect.minX + 10, y: rect.maxY - 18), font: .boldSystemFont(ofSize: 9), color: .white, context: context)

        var cursorY = rect.maxY - 38
        let lines = partyContent(party)
        for (index, line) in lines.enumerated() {
            drawText(
                line,
                at: CGPoint(x: rect.minX + 10, y: cursorY - 12),
                font: index == 0 ? .boldSystemFont(ofSize: 10) : .systemFont(ofSize: 9.5),
                color: textDark,
                context: context
            )
            cursorY -= 13
        }
    }

    private static func partyContent(_ party: Party) -> [String] {
        var lines: [String] = []
        if !party.name.isEmpty { lines.append(party.name) }
        lines.append(contentsOf: PeppolFormatting.formatAddress(party))
        if !party.vatNumber.isEmpty {
            lines.append(s("pdfVat", ["value": PeppolFormatting.formatVAT(party.vatNumber)]))
        }
        if !party.phone.isEmpty {
            lines.append(s("pdfPhone", ["value": party.phone]))
        }
        if !party.email.isEmpty {
            lines.append(s("pdfEmail", ["value": party.email]))
        }
        return lines.isEmpty ? [s("emptyDash")] : lines
    }

    // MARK: - Lines table

    private static func drawLinesTable(context: CGContext, invoice: PeppolInvoice, y: CGFloat, mediaBox: inout CGRect) -> CGFloat {
        var cursorY = y
        let columns: [(String, CGFloat, NSTextAlignment)] = [
            (s("pdfColNumber"), 24, .center),
            (s("pdfColDescription"), 200, .left),
            (s("pdfColQty"), 42, .right),
            (s("pdfColUnitPrice"), 68, .right),
            (s("pdfColTotalExcl"), 68, .right),
            (s("pdfColTotalIncl"), 68, .right),
        ]

        cursorY = drawTableHeader(columns: columns, y: cursorY, context: context)

        for (index, line) in invoice.lines.enumerated() {
            let description = line.pdfDescription
            let title = line.pdfTitle
            let fullText = title.isEmpty ? description : "\(title)\n\(description)"
            let descHeight = heightForWrappedText(fullText, width: columns[1].1 - 8, font: .systemFont(ofSize: 8.5))
            let rowHeight = max(28, descHeight + 10)

            if cursorY - rowHeight < margin + 180 {
                context.endPDFPage()
                context.beginPDFPage(nil)
                cursorY = pageHeight - margin
                cursorY = drawTableHeader(columns: columns, y: cursorY, context: context)
            }

            let rowRect = CGRect(x: margin, y: cursorY - rowHeight, width: contentWidth, height: rowHeight)
            if index.isMultiple(of: 2) {
                fillRect(rowRect, color: rowAlt, context: context)
            }
            strokeRect(rowRect, color: border, context: context)

            var x = margin
            let values = [
                line.lineID,
                fullText,
                PeppolFormatting.quantity(line.quantity),
                PeppolFormatting.money(line.unitPrice, currency: invoice.currency),
                PeppolFormatting.money(line.lineTotal, currency: invoice.currency),
                PeppolFormatting.money(line.lineTotalInclVAT, currency: invoice.currency),
            ]

            for (columnIndex, column) in columns.enumerated() {
                if columnIndex == 1 {
                    _ = drawWrappedText(
                        values[columnIndex],
                        origin: CGPoint(x: x + 4, y: cursorY - 12),
                        width: column.1 - 8,
                        font: .systemFont(ofSize: 8.5),
                        color: textDark,
                        context: context
                    )
                } else {
                    drawAlignedText(
                        values[columnIndex],
                        rect: CGRect(x: x, y: cursorY - rowHeight + 6, width: column.1, height: rowHeight - 8),
                        font: .systemFont(ofSize: 8.5),
                        color: textDark,
                        alignment: column.2,
                        context: context
                    )
                }
                x += column.1
            }

            cursorY -= rowHeight
        }

        return cursorY - 14
    }

    private static func drawTableHeader(
        columns: [(String, CGFloat, NSTextAlignment)],
        y: CGFloat,
        context: CGContext
    ) -> CGFloat {
        let rowHeight: CGFloat = 22
        fillRect(CGRect(x: margin, y: y - rowHeight, width: contentWidth, height: rowHeight), color: green, context: context)
        var x = margin
        for column in columns {
            drawAlignedText(
                column.0,
                rect: CGRect(x: x + 2, y: y - rowHeight + 5, width: column.1 - 4, height: rowHeight - 6),
                font: .boldSystemFont(ofSize: 8.5),
                color: .white,
                alignment: column.2,
                context: context
            )
            x += column.1
        }
        return y - rowHeight
    }

    // MARK: - Totals

    private static func drawTotalsBlock(context: CGContext, invoice: PeppolInvoice, y: CGFloat, mediaBox: inout CGRect) -> CGFloat {
        var currentY = y
        if currentY < margin + 160 {
            context.endPDFPage()
            context.beginPDFPage(nil)
            currentY = pageHeight - margin
        }

        let boxWidth: CGFloat = 240
        let boxX = margin + contentWidth - boxWidth
        var cursorY = currentY

        let vatRate = invoice.taxBreakdown.first?.percent ?? invoice.lines.first?.vatPercent ?? 0
        let rows: [(String, String, Bool)] = [
            (s("pdfTotalExcl"), PeppolFormatting.money(invoice.taxExclusiveAmount, currency: invoice.currency), false),
            (s("pdfVatWithRate", ["percent": PeppolFormatting.percent(vatRate)]), PeppolFormatting.money(invoice.totalVAT, currency: invoice.currency), false),
            (s("pdfTotalIncl"), PeppolFormatting.money(invoice.taxInclusiveAmount, currency: invoice.currency), true),
        ]

        for row in rows {
            let rowRect = CGRect(x: boxX, y: cursorY - 22, width: boxWidth, height: 22)
            if row.2 {
                fillRect(rowRect, color: greenLight, context: context)
            }
            drawText(row.0, at: CGPoint(x: boxX + 10, y: cursorY - 16), font: row.2 ? .boldSystemFont(ofSize: 11) : .systemFont(ofSize: 10), color: textDark, context: context)
            drawAlignedText(
                row.1,
                rect: CGRect(x: boxX + 90, y: cursorY - 20, width: boxWidth - 100, height: 16),
                font: row.2 ? .boldSystemFont(ofSize: 11) : .systemFont(ofSize: 10),
                color: row.2 ? greenDark : textDark,
                alignment: .right,
                context: context
            )
            if row.2 {
                strokeRect(rowRect, color: green.withAlphaComponent(0.4), context: context)
            }
            cursorY -= 24
        }

        return cursorY - 10
    }

    // MARK: - Payment + QR

    private static func drawPaymentSection(context: CGContext, invoice: PeppolInvoice, y: CGFloat, mediaBox: inout CGRect) -> CGFloat {
        var currentY = y
        if currentY < margin + 200 {
            context.endPDFPage()
            context.beginPDFPage(nil)
            currentY = pageHeight - margin
        }

        let sectionHeight: CGFloat = 190
        let sectionRect = CGRect(x: margin, y: currentY - sectionHeight, width: contentWidth, height: sectionHeight)
        fillRect(sectionRect, color: greenLight, context: context)
        strokeRect(sectionRect, color: green.withAlphaComponent(0.3), context: context)

        var cursorY = currentY - 18
        drawText(s("pdfPaymentTitle"), at: CGPoint(x: margin + 14, y: cursorY - 12), font: .boldSystemFont(ofSize: 10), color: greenDark, context: context)
        cursorY -= 28

        let leftX = margin + 14
        let paymentLines: [String] = [
            s("pdfDueDate", ["date": PeppolFormatting.displayDate(invoice.dueDate)]),
            s("pdfIban", ["iban": PeppolFormatting.formatIBAN(invoice.payment.iban)]),
            s("pdfBic", ["bic": invoice.payment.bic]),
            s("pdfCommunication", ["ref": invoice.payment.paymentReference.isEmpty ? invoice.invoiceID : invoice.payment.paymentReference]),
            s("pdfAmount", ["amount": PeppolFormatting.money(invoice.payableAmount, currency: invoice.currency)]),
        ]
        for line in paymentLines where !line.hasSuffix(": ") && !line.hasSuffix(": —") {
            drawText(line, at: CGPoint(x: leftX, y: cursorY - 11), font: .systemFont(ofSize: 9.5), color: textDark, context: context)
            cursorY -= 14
        }

        cursorY -= 4
        drawText(s("pdfLateFee"), at: CGPoint(x: leftX, y: cursorY - 10), font: .systemFont(ofSize: 8.5), color: textMuted, context: context)
        cursorY -= 14
        drawText(s("pdfQrStandard"), at: CGPoint(x: leftX, y: cursorY - 10), font: .systemFont(ofSize: 8), color: textMuted, context: context)

        if !invoice.payment.iban.isEmpty {
            let qrString = QRCodeGenerator.epcPaymentString(invoice: invoice)
            if let qrImage = QRCodeGenerator.makeImage(from: qrString, side: 110) {
                let qrRect = CGRect(x: margin + contentWidth - 130, y: currentY - sectionHeight + 36, width: 110, height: 110)
                fillRect(qrRect.insetBy(dx: -4, dy: -4), color: .white, context: context)
                strokeRect(qrRect.insetBy(dx: -4, dy: -4), color: border, context: context)
                drawImage(qrImage, in: qrRect, context: context)
                drawCenteredText(
                    s("pdfScanToPay"),
                    in: CGRect(x: qrRect.minX - 10, y: qrRect.minY - 22, width: qrRect.width + 20, height: 14),
                    font: .boldSystemFont(ofSize: 7.5),
                    color: greenDark,
                    context: context
                )
                drawCenteredText(
                    s("pdfBelgianBanks"),
                    in: CGRect(x: qrRect.minX - 10, y: qrRect.minY - 34, width: qrRect.width + 20, height: 12),
                    font: .systemFont(ofSize: 7),
                    color: textMuted,
                    context: context
                )
            }
        }

        return currentY - sectionHeight - 12
    }

    // MARK: - Footer

    private static func drawFooter(context: CGContext, invoice: PeppolInvoice, y: CGFloat) -> CGFloat {
        var cursorY = max(y, margin + 60)
        context.setStrokeColor(border.cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: margin, y: cursorY))
        context.addLine(to: CGPoint(x: margin + contentWidth, y: cursorY))
        context.strokePath()
        cursorY -= 14

        let supplier = invoice.supplier
        let footer1 = "\(supplier.name) • \(supplier.street)"
        drawCenteredText(footer1, in: CGRect(x: margin, y: cursorY - 10, width: contentWidth, height: 12), font: .systemFont(ofSize: 8), color: textMuted, context: context)
        cursorY -= 14

        let footer2 = "\(s("pdfVatNumber", ["value": PeppolFormatting.formatVAT(supplier.vatNumber)])) • \(s("pdfCompliant"))"
        drawCenteredText(footer2, in: CGRect(x: margin, y: cursorY - 10, width: contentWidth, height: 12), font: .systemFont(ofSize: 8), color: textMuted, context: context)
        cursorY -= 14

        if !invoice.payments.isEmpty {
            let bankParts = invoice.payments.enumerated().map { index, payment in
                let label = index == 0 ? s("pdfBanks") : s("pdfBanksN", ["n": "\(index + 1)"])
                let parts = [
                    payment.paymentMeansCode.isEmpty ? nil : nil,
                    payment.bic.isEmpty ? nil : s("pdfBicShort", ["value": payment.bic]),
                    payment.iban.isEmpty ? nil : s("pdfIbanShort", ["value": PeppolFormatting.formatIBAN(payment.iban)]),
                ].compactMap { $0 }
                return "\(label): \(parts.joined(separator: " | "))"
            }
            let footer3 = bankParts.joined(separator: " | ")
            drawCenteredText(footer3, in: CGRect(x: margin, y: cursorY - 10, width: contentWidth, height: 12), font: .systemFont(ofSize: 7.5), color: textMuted, context: context)
        }

        return cursorY
    }

    // MARK: - Drawing helpers

    private static func drawCenteredText(
        _ text: String,
        in rect: CGRect,
        font: NSFont,
        color: NSColor,
        context: CGContext
    ) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph,
        ]
        let attributed = NSAttributedString(string: text, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        let path = CGPath(rect: rect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: attributed.length), path, nil)
        CTFrameDraw(frame, context)
    }

    @discardableResult
    private static func drawText(
        _ text: String,
        at point: CGPoint,
        font: NSFont,
        color: NSColor,
        context: CGContext
    ) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
        let line = CTLineCreateWithAttributedString(NSAttributedString(string: text, attributes: attributes))
        context.saveGState()
        context.textMatrix = .identity
        context.textPosition = point
        CTLineDraw(line, context)
        context.restoreGState()
        return point.y
    }

    private static func drawAlignedText(
        _ text: String,
        rect: CGRect,
        font: NSFont,
        color: NSColor,
        alignment: NSTextAlignment,
        context: CGContext
    ) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = alignment
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraph,
        ]
        let attributed = NSAttributedString(string: text, attributes: attributes)
        let framesetter = CTFramesetterCreateWithAttributedString(attributed)
        let path = CGPath(rect: rect, transform: nil)
        let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: attributed.length), path, nil)
        CTFrameDraw(frame, context)
    }

    @discardableResult
    private static func drawWrappedText(
        _ text: String,
        origin: CGPoint,
        width: CGFloat,
        font: NSFont,
        color: NSColor,
        context: CGContext
    ) -> CGFloat {
        let height = heightForWrappedText(text, width: width, font: font)
        drawAlignedText(
            text,
            rect: CGRect(x: origin.x, y: origin.y - height, width: width, height: height),
            font: font,
            color: color,
            alignment: .left,
            context: context
        )
        return origin.y - height
    }

    private static func heightForWrappedText(_ text: String, width: CGFloat, font: NSFont) -> CGFloat {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .paragraphStyle: paragraph]
        let bounding = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: attributes
        )
        return ceil(bounding.height) + 2
    }

    private static func fillRect(_ rect: CGRect, color: NSColor, context: CGContext) {
        context.setFillColor(color.cgColor)
        context.fill(rect)
    }

    private static func strokeRect(_ rect: CGRect, color: NSColor, context: CGContext) {
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(0.5)
        context.stroke(rect)
    }

    private static func drawImage(_ image: NSImage, in rect: CGRect, context: CGContext) {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        context.draw(cgImage, in: rect)
    }
}
