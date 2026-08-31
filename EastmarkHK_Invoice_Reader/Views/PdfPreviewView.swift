import PDFKit
import SwiftUI

struct PdfPreviewView: View {
    @EnvironmentObject private var l10n: L10n
    let data: Data?

    var body: some View {
        if let data {
            PDFKitRepresentable(data: data)
        } else {
            ContentUnavailableView(
                l10n.t("emptyPdf"),
                systemImage: "doc.richtext",
                description: Text(l10n.t("emptyInvoiceHint"))
            )
        }
    }
}

private struct PDFKitRepresentable: NSViewRepresentable {
    let data: Data

    func makeNSView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.document = PDFDocument(data: data)
        return view
    }

    func updateNSView(_ nsView: PDFView, context: Context) {
        nsView.document = PDFDocument(data: data)
    }
}
