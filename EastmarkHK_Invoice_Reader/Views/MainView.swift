import AppKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class InvoiceDocument: ObservableObject {
    struct Status: Equatable {
        var key: String
        var args: [String: String] = [:]
    }

    @Published var invoice: PeppolInvoice?
    @Published var pdfData: Data?
    @Published var status = Status(key: "statusReady")
    @Published var errorMessage: String?

    func open(url: URL) {
        do {
            let parsed = try PeppolParser.parse(url: url)
            invoice = parsed

            if let embedded = parsed.embeddedPDF {
                pdfData = embedded
                let name = parsed.embeddedPDFFilename.isEmpty ? "attachment" : parsed.embeddedPDFFilename
                status = Status(key: "statusLoadedEmbedded", args: [
                    "filename": url.lastPathComponent,
                    "name": name,
                ])
            } else {
                pdfData = PDFBuilder.build(invoice: parsed)
                status = Status(key: "statusLoadedGenerated", args: [
                    "filename": url.lastPathComponent,
                ])
            }
            errorMessage = nil
        } catch let error as PeppolParseError {
            invoice = nil
            pdfData = nil
            errorMessage = error.localizedMessage()
        } catch {
            invoice = nil
            pdfData = nil
            errorMessage = error.localizedDescription
        }
    }

    func savePDF(to url: URL) throws {
        guard let pdfData else { return }
        try pdfData.write(to: url)
        status = Status(key: "statusSaved", args: ["filename": url.lastPathComponent])
    }

    func refreshGeneratedPDFIfNeeded() {
        guard let invoice, !invoice.hasEmbeddedPDF else { return }
        pdfData = PDFBuilder.build(invoice: invoice)
    }
}

struct MainView: View {
    @EnvironmentObject private var l10n: L10n
    @StateObject private var document = InvoiceDocument()
    @State private var selectedTab: AppTab = .summary

    var body: some View {
        VStack(spacing: 0) {
            AppChromeBar(
                selectedTab: $selectedTab,
                onOpen: openXML,
                onSave: savePDF,
                saveDisabled: document.pdfData == nil
            )
            Divider()
            tabContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()
            Text(l10n.t(document.status.key, document.status.args))
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            EastmarkFooter()
        }
        .frame(minWidth: 1100, minHeight: 720)
        .background(WindowChromeConfigurator())
        .alert(l10n.t("alertOpenFailed"), isPresented: Binding(
            get: { document.errorMessage != nil },
            set: { if !$0 { document.errorMessage = nil } }
        )) {
            Button(l10n.t("actionOK"), role: .cancel) {}
        } message: {
            Text(document.errorMessage ?? "")
        }
        .task {
            await l10n.refreshForStoredLanguage()
        }
        .onChange(of: l10n.revision) {
            document.refreshGeneratedPDFIfNeeded()
        }
        .overlay {
            if let progress = l10n.translationProgress {
                TranslationProgressOverlay(progress: progress)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: l10n.translationProgress != nil)
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .summary:
            SummaryView(invoice: document.invoice)
        case .lines:
            LinesView(invoice: document.invoice)
        case .xml:
            XmlView(xml: document.invoice?.rawXML ?? "")
        case .pdf:
            PdfPreviewView(data: document.pdfData)
        }
    }

    private func openXML() {
        let panel = NSOpenPanel()
        panel.title = l10n.t("panelOpenTitle")
        panel.allowedContentTypes = [.xml]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        document.open(url: url)
    }

    private func savePDF() {
        guard let invoice = document.invoice, document.pdfData != nil else { return }
        let panel = NSSavePanel()
        panel.title = l10n.t("panelSaveTitle")
        panel.allowedContentTypes = [.pdf]
        let fallback = l10n.t("defaultInvoiceFilename")
        panel.nameFieldStringValue = "\(invoice.invoiceID.isEmpty ? fallback : invoice.invoiceID).pdf"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try document.savePDF(to: url)
        } catch {
            document.errorMessage = error.localizedDescription
        }
    }
}
