import AppKit
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case summary
    case lines
    case xml
    case pdf

    var id: String { rawValue }

    var l10nKey: String {
        switch self {
        case .summary: return "tabSummary"
        case .lines: return "tabLines"
        case .xml: return "tabXml"
        case .pdf: return "tabPdf"
        }
    }

    var icon: String {
        switch self {
        case .summary: return "doc.text"
        case .lines: return "list.bullet.rectangle"
        case .xml: return "chevron.left.forwardslash.chevron.right"
        case .pdf: return "doc.richtext"
        }
    }
}

/// Single top row: traffic lights inset · logo · tabs · actions · settings.
struct AppChromeBar: View {
    @EnvironmentObject private var l10n: L10n
    @Environment(\.openSettings) private var openSettings
    @Binding var selectedTab: AppTab
    var onOpen: () -> Void
    var onSave: () -> Void
    var saveDisabled: Bool

    var body: some View {
        HStack(spacing: 0) {
            Color.clear
                .frame(width: WindowChromeMetrics.trafficLightLeadingInset)
                .accessibilityHidden(true)

            if let logo = NSImage(named: "eastmarkhk_logo") {
                Image(nsImage: logo)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(height: 22)
                    .padding(.trailing, 14)
            }

            HStack(spacing: 4) {
                ForEach(AppTab.allCases) { tab in
                    ChromeTabButton(
                        title: l10n.t(tab.l10nKey),
                        icon: tab.icon,
                        isSelected: selectedTab == tab
                    ) {
                        selectedTab = tab
                    }
                }
            }

            Spacer(minLength: 12)

            HStack(spacing: 8) {
                AppActionButton(
                    title: l10n.t("actionOpenXml"),
                    icon: "doc.badge.plus",
                    variant: .primary,
                    action: onOpen
                )
                AppActionButton(
                    title: l10n.t("actionSavePdf"),
                    icon: "arrow.down.doc.fill",
                    variant: .secondary,
                    disabled: saveDisabled,
                    action: onSave
                )
                AppIconButton(
                    icon: "gearshape.fill",
                    help: l10n.t("actionSettings"),
                    action: { openSettings() }
                )
            }
            .padding(.trailing, 12)
        }
        .frame(height: WindowChromeMetrics.chromeBarHeight)
        .background(AppTheme.greenLight)
    }
}

private struct ChromeTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .medium))
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
            }
            .foregroundStyle(isSelected ? AppTheme.greenDark : Color.primary.opacity(0.55))
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.72) : Color.clear)
            )
            .overlay(alignment: .bottom) {
                if isSelected {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(AppTheme.green)
                        .frame(height: 2)
                        .padding(.horizontal, 8)
                        .offset(y: 4)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct AppIconButton: View {
    let icon: String
    let help: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(AppTheme.greenDark)
                .frame(width: 22, height: 22)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.white.opacity(0.85))
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .strokeBorder(AppTheme.greenBorder, lineWidth: 0.8)
                )
        )
        .help(help)
    }
}
