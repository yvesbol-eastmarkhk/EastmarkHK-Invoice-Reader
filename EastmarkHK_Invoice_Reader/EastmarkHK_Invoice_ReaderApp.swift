import AppKit
import SwiftUI

@main
struct EastmarkHK_Invoice_ReaderApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(L10n.shared)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button(L10n.shared.t("actionOpenXml")) {
                    NotificationCenter.default.post(name: .openInvoiceXML, object: nil)
                }
                .keyboardShortcut("o", modifiers: .command)

                Button(L10n.shared.t("actionSavePdf")) {
                    NotificationCenter.default.post(name: .saveInvoicePDF, object: nil)
                }
                .keyboardShortcut("s", modifiers: .command)
            }
            CommandGroup(after: .appSettings) {
                Button(L10n.shared.t("actionSettings")) {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }

        Settings {
            SettingsView()
                .environmentObject(L10n.shared)
        }
    }
}
