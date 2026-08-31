import AppKit
import SwiftUI

/// Fixed footer matching EastmarkHK e-Invoicing: © year + EastmarkHK (tappable).
struct EastmarkFooter: View {
    private var copyrightYear: String {
        // Plain digits — never locale-formatted (avoids "2.026" in fr_BE).
        String(Calendar.current.component(.year, from: Date()))
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            Button(action: openWebsite) {
                HStack(spacing: 0) {
                    Text(verbatim: "© \(copyrightYear) ")
                        .foregroundStyle(Color.primary.opacity(0.75))
                    Text(verbatim: EastmarkBrand.companyName)
                        .foregroundStyle(AppTheme.green)
                        .fontWeight(.bold)
                }
                .font(.system(size: 11))
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .frame(height: 26)
            .background(Color(nsColor: .windowBackgroundColor))
        }
    }

    private func openWebsite() {
        NSWorkspace.shared.open(EastmarkBrand.websiteURL)
    }
}
