import AppKit

/// Single-window app: closing the main window quits (App Store Guideline 4).
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

extension Notification.Name {
    static let openInvoiceXML = Notification.Name("eastmarkhk.openInvoiceXML")
    static let saveInvoicePDF = Notification.Name("eastmarkhk.saveInvoicePDF")
}
