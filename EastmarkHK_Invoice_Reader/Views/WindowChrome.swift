import AppKit
import SwiftUI

/// Transparent title bar with visible traffic-light buttons (macOS).
/// Interactive controls must sit *below* the titlebar drag region — see AppChromeBar.
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
        // Keep false so SwiftUI buttons in content are not stolen by window-drag hit testing.
        // The system titlebar strip (traffic lights / empty header) remains draggable.
        window.isMovableByWindowBackground = false
        window.backgroundColor = NSColor.windowBackgroundColor
    }
}

/// Space reserved for macOS red/yellow/green buttons (~78 pt).
enum WindowChromeMetrics {
    static let trafficLightLeadingInset: CGFloat = 78
    /// Height of the non-interactive titlebar strip (drag + traffic lights).
    static let titlebarHeight: CGFloat = 28
    static let chromeBarHeight: CGFloat = 44
}
