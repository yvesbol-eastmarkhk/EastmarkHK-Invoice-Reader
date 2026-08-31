import SwiftUI

@main
struct EastmarkHK_Invoice_ReaderApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(L10n.shared)
        }
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(after: .appSettings) {
                Button("Settings…") {
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
