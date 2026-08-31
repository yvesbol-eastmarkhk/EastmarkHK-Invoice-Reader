import SwiftUI

/// Modal progress while the UI is translated (same idea as EastmarkHK e-Invoicing).
struct TranslationProgressOverlay: View {
    @EnvironmentObject private var l10n: L10n
    let progress: TranslationProgress

    var body: some View {
        ZStack {
            Color.black.opacity(0.28)
                .ignoresSafeArea()
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.small)
                    Text(l10n.t("uiTranslateProgressTitle", ["language": progress.languageName]))
                        .font(.headline)
                }
                HStack(spacing: 6) {
                    Image(systemName: progress.engineKey == "engineMistral" ? "cloud" : "sparkles")
                        .font(.system(size: 13))
                        .foregroundStyle(AppTheme.green)
                    Text(l10n.t("uiTranslateUsingEngine", ["engine": l10n.t(progress.engineKey)]))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Text("\(progress.done) / \(progress.total)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ProgressView(value: progress.fraction)
                    .tint(AppTheme.green)
            }
            .padding(20)
            .frame(width: 360)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: .windowBackgroundColor))
            )
            .shadow(color: .black.opacity(0.15), radius: 16, y: 4)
        }
        .transition(.opacity)
    }
}
