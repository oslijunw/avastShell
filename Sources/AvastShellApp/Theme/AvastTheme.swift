import SwiftUI

enum AvastTheme {
    static let pageInset: CGFloat = 56
    static let backgroundGradient = LinearGradient(
        colors: [Color(red: 0.035, green: 0.018, blue: 0.19),
                 Color(red: 0.09, green: 0.055, blue: 0.29),
                 Color(red: 0.22, green: 0.14, blue: 0.46)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    static let cardFill = Color.white.opacity(0.105)
    static let primary = Color(red: 0.19, green: 0.92, blue: 0.58)
    static let accent = Color(red: 0.43, green: 0.30, blue: 1)
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.79, green: 0.77, blue: 0.88)
    static let textTertiary = Color.white.opacity(0.55)
    static let warning = Color(red: 1, green: 0.85, blue: 0.18)
}

extension View {
    func avastCard(radius: CGFloat = 9) -> some View {
        background(RoundedRectangle(cornerRadius: radius).fill(AvastTheme.cardFill))
    }
}

struct AvastPrimaryButtonStyle: ButtonStyle {
    var compact = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: compact ? 13 : 14, weight: .semibold))
            .foregroundStyle(Color(red: 0.025, green: 0.035, blue: 0.16))
            .padding(.horizontal, compact ? 16 : 22)
            .frame(height: compact ? 28 : 40)
            .background(Capsule().fill(AvastTheme.primary))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct AvastOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .frame(height: 34)
            .background(Capsule().fill(.white.opacity(configuration.isPressed ? 0.1 : 0)))
            .overlay(Capsule().stroke(AvastTheme.textSecondary, lineWidth: 1.2))
    }
}

struct AvastHoverButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.opacity(configuration.isPressed ? 0.7 : 1)
    }
}
