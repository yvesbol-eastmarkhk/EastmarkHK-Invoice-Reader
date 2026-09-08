import SwiftUI

struct XmlView: View {
    @EnvironmentObject private var l10n: L10n
    let xml: String
    var onOpen: (() -> Void)?

    var body: some View {
        if xml.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            VStack(spacing: 16) {
                ContentUnavailableView(
                    l10n.t("emptyInvoice"),
                    systemImage: "chevron.left.forwardslash.chevron.right",
                    description: Text(l10n.t("emptyInvoiceHint"))
                )
                if let onOpen {
                    AppActionButton(
                        title: l10n.t("actionOpenXml"),
                        icon: "doc.badge.plus",
                        variant: .primary,
                        action: onOpen
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            XmlTextView(text: xml)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct XmlTextView: NSViewRepresentable {
    let text: String

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = true

        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isRichText = false
        textView.importsGraphics = false
        textView.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .regular)
        textView.textColor = .textColor
        textView.backgroundColor = .textBackgroundColor
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = true
        textView.autoresizingMask = [.width, .height]
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.textContainer?.widthTracksTextView = false
        textView.textContainer?.containerSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude,
            height: CGFloat.greatestFiniteMagnitude
        )
        textView.string = text

        scrollView.documentView = textView
        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
            textView.scrollToBeginningOfDocument(nil)
        }
    }
}
