import AppKit
import SwiftUI

/// Transparent title bar with visible traffic-light buttons (macOS).
struct WindowChromeConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async {
            configure(window: view.window)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async {
            configure(window: nsView.window)
        }
    }

    private func configure(window: NSWindow?) {
        guard let window else { return }
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(.fullSizeContentView)
        window.isMovableByWindowBackground = true
        window.backgroundColor = NSColor.windowBackgroundColor
    }
}

/// Space reserved for macOS red/yellow/green buttons (~78 pt).
enum WindowChromeMetrics {
    static let trafficLightLeadingInset: CGFloat = 78
    static let chromeBarHeight: CGFloat = 38
}
