import AppKit
import CoreImage
import Foundation

enum QRCodeGenerator {
    static func epcPaymentString(invoice: PeppolInvoice) -> String {
        let bic = invoice.payment.bic.replacingOccurrences(of: " ", with: "")
        let iban = invoice.payment.iban.replacingOccurrences(of: " ", with: "")
        let amount = NSDecimalNumber(decimal: invoice.payableAmount)
        let amountString = String(format: "%.2f", amount.doubleValue)
        let beneficiary = String(invoice.supplier.name.prefix(70))
        let reference = invoice.payment.paymentReference.isEmpty ? invoice.invoiceID : invoice.payment.paymentReference
        return "BCD\n002\n1\nSCT\n\(bic)\n\(beneficiary)\n\(iban)\nEUR\(amountString)\n\n\(reference)\n"
    }

    static func makeImage(from string: String, side: CGFloat) -> NSImage? {
        guard let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let output = filter.outputImage else { return nil }
        let scale = side / output.extent.width
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let rep = NSCIImageRep(ciImage: scaled)
        let image = NSImage(size: NSSize(width: side, height: side))
        image.addRepresentation(rep)
        return image
    }
}
