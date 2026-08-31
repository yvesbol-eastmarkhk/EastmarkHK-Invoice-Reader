import SwiftUI

enum AppTheme {
    static let green = Color(red: 0.18, green: 0.55, blue: 0.42)
    static let greenDark = Color(red: 0.12, green: 0.38, blue: 0.30)
    static let greenLight = Color(red: 0.93, green: 0.96, blue: 0.95)
    static let greenBorder = Color(red: 0.18, green: 0.55, blue: 0.42).opacity(0.35)
}

enum AppButtonVariant {
    case primary
    case secondary
    case destructive
    case subtle
}

struct AppActionButton: View {
    let title: String
    let icon: String
    var variant: AppButtonVariant = .primary
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .labelStyle(AppButtonLabelStyle())
        }
        .buttonStyle(AppButtonStyle(variant: variant))
        .disabled(disabled)
    }
}

private struct AppButtonLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 7) {
            configuration.icon
                .font(.system(size: 13, weight: .semibold))
                .frame(width: 16)
            configuration.title
                .font(.system(size: 13, weight: .semibold))
        }
    }
}

struct AppButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    var variant: AppButtonVariant

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(background(isPressed: configuration.isPressed))
            .overlay(border)
            .foregroundStyle(foreground)
            .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))
            .shadow(
                color: shadowColor.opacity(isEnabled ? 1 : 0),
                radius: configuration.isPressed ? 1 : 3,
                y: configuration.isPressed ? 0 : 1
            )
            .opacity(isEnabled ? 1 : 0.45)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.985 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch variant {
        case .primary:
            return .white
        case .secondary:
            return AppTheme.greenDark
        case .destructive:
            return Color(red: 0.72, green: 0.18, blue: 0.16)
        case .subtle:
            return AppTheme.greenDark
        }
    }

    @ViewBuilder
    private func background(isPressed: Bool) -> some View {
        switch variant {
        case .primary:
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.green.opacity(isPressed ? 0.88 : 1),
                            AppTheme.greenDark.opacity(isPressed ? 0.92 : 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        case .secondary:
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(isPressed ? AppTheme.greenLight.opacity(0.95) : Color.white.opacity(0.92))
        case .destructive:
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(isPressed ? Color.red.opacity(0.08) : Color.white.opacity(0.92))
        case .subtle:
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(isPressed ? AppTheme.greenLight : Color.clear)
        }
    }

    @ViewBuilder
    private var border: some View {
        switch variant {
        case .primary:
            EmptyView()
        case .secondary:
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(AppTheme.greenBorder, lineWidth: 1)
        case .destructive:
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(Color.red.opacity(0.35), lineWidth: 1)
        case .subtle:
            EmptyView()
        }
    }

    private var shadowColor: Color {
        switch variant {
        case .primary:
            return AppTheme.green.opacity(0.28)
        case .secondary, .destructive:
            return Color.black.opacity(0.08)
        case .subtle:
            return .clear
        }
    }
}
