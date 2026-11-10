import SwiftUI

struct FeatureTile: View {
    let icon: AvastIconKind
    let title: String
    var isScanning = false
    var hasAIBadge = false
    var showLock = false
    let action: () -> Void
    @State private var hovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                AvastIcon(kind: icon)
                    .frame(width: 42, height: 42)
                    .overlay(alignment: .bottomTrailing) {
                        if showLock {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(Color(red: 0.05, green: 0.03, blue: 0.2))
                                .frame(width: 23, height: 23)
                                .background(Circle().fill(AvastTheme.warning))
                                .offset(x: 4, y: 3)
                        }
                    }
                Text(title).font(.system(size: 13, weight: .medium)).foregroundStyle(.white)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 96)
            .background(RoundedRectangle(cornerRadius: 5).fill(.white.opacity(hovered ? 0.16 : 0.115)))
            .overlay {
                if hasAIBadge {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(LinearGradient(colors: [AvastTheme.primary, AvastTheme.accent], startPoint: .leading, endPoint: .trailing), lineWidth: 2)
                }
            }
            .overlay(alignment: .topLeading) {
                if hasAIBadge {
                    Text("AI 赋能")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(red: 0.03, green: 0.03, blue: 0.16))
                        .frame(width: 63, height: 35)
                        .background(RoundedRectangle(cornerRadius: 4).fill(LinearGradient(colors: [AvastTheme.primary, AvastTheme.accent], startPoint: .leading, endPoint: .trailing)))
                        .offset(x: 16, y: -18)
                }
            }
            .overlay(alignment: .bottom) {
                if isScanning {
                    ZStack(alignment: .leading) {
                        Rectangle().fill(.white.opacity(0.12))
                        Rectangle().fill(AvastTheme.primary).frame(width: 90).offset(x: 50)
                    }
                    .frame(height: 3)
                    .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 5, bottomTrailingRadius: 5))
                }
            }
        }
        .buttonStyle(AvastHoverButtonStyle())
        .onHover { hovered = $0 }
    }
}
