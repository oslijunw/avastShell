import SwiftUI

struct TopBarView: View {
    let state: AppState
    @State private var showingMenu = false
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        ZStack {
            HStack {
                Button("进入 PREMIUM") {}
                    .buttonStyle(AvastPrimaryButtonStyle(compact: true))
                    .padding(.leading, 92)
                Spacer()
                HStack(spacing: 24) {
                    item("cart", "商店")
                    item("bell", "通知")
                    Button { showingMenu.toggle() } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "line.3.horizontal").font(.system(size: 18, weight: .light))
                            Text("菜单").font(.system(size: 14))
                        }
                    }
                    .buttonStyle(AvastHoverButtonStyle())
                    .overlay(alignment: .bottomTrailing) {
                        // 与面板等宽的透明锚点：popover 水平居中于锚点，
                        // 因此面板右缘对齐按钮右缘，不会超出窗口
                        Color.clear
                            .frame(width: 340, height: 2)
                            .popover(isPresented: $showingMenu, arrowEdge: .bottom) {
                                menuPanel
                            }
                    }
                }
                .padding(.trailing, 16)
            }
            HStack(spacing: 9) {
                AvastBrandMark().frame(width: 24, height: 24)
                Text("Avast Security").font(.system(size: 15, weight: .medium))
            }
        }
        .foregroundStyle(.white)
        .frame(height: 38)
    }

    /// 「菜单」下拉面板，右对齐锚定在窗口内，不超出窗口边界。
    private var menuPanel: some View {
        VStack(spacing: 0) {
            // 登录区块
            VStack(spacing: 20) {
                Text("登录到 Avast 以同步您的订阅等内容。")
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                Button("登录") {}
                    .buttonStyle(AvastPrimaryButtonStyle())
                    .frame(width: 140)
            }
            .padding(.horizontal, 36)
            .padding(.vertical, 28)
            Rectangle()
                .fill(.white.opacity(0.12))
                .frame(height: 1)
            VStack(alignment: .leading, spacing: 0) {
                menuRow("creditcard", "我的订阅")
                menuRow("gearshape", "首选项", action: {
                    showingMenu = false
                    openWindow(id: "preferences")
                })
                menuRow("cart", "Avast 商店")
                menuRow("chart.line.uptrend.xyaxis", "统计")
                menuRow("questionmark.circle", "帮助")
                menuRow("info.circle", "关于")
                // 保留原有检查更新入口
                menuRow(
                    state.hasCheckedForUpdates ? "checkmark.circle" : "arrow.clockwise",
                    state.isCheckingForUpdates ? "正在检查更新…" : state.hasCheckedForUpdates ? "已是最新版本" : "检查更新",
                    action: { Task { await state.checkForUpdates() } }
                )
                .disabled(state.isCheckingForUpdates)
            }
            .padding(.vertical, 12)
        }
        .frame(width: 340)
        .background(AvastTheme.backgroundGradient)
        .foregroundStyle(.white)
    }

    private func item(_ symbol: String, _ title: String) -> some View {
        Button {} label: {
            HStack(spacing: 10) {
                Image(systemName: symbol).font(.system(size: 18, weight: .light))
                Text(title).font(.system(size: 14))
            }
        }
        .buttonStyle(AvastHoverButtonStyle())
    }

    /// 菜单下拉面板中的单行菜单项。
    private func menuRow(_ symbol: String, _ title: String, action: (() -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 18) {
                Image(systemName: symbol)
                    .font(.system(size: 17, weight: .light))
                    .foregroundStyle(.white.opacity(0.85))
                    .frame(width: 22)
                Text(title).font(.system(size: 15))
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 36)
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(AvastHoverButtonStyle())
    }
}

struct AvastBrandMark: View {
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 1, green: 0.51, blue: 0))
            Canvas { context, size in
                var petals = Path()
                petals.move(to: CGPoint(x: 20, y: 21))
                petals.addQuadCurve(to: CGPoint(x: 12, y: 3), control: CGPoint(x: 4, y: -1))
                petals.addQuadCurve(to: CGPoint(x: 20, y: 21), control: CGPoint(x: 18, y: 2))
                petals.move(to: CGPoint(x: 19, y: 21))
                petals.addQuadCurve(to: CGPoint(x: 4, y: 10), control: CGPoint(x: -1, y: 6))
                petals.addQuadCurve(to: CGPoint(x: 19, y: 21), control: CGPoint(x: 6, y: 16))
                petals.move(to: CGPoint(x: 18, y: 21))
                petals.addQuadCurve(to: CGPoint(x: 4, y: 18), control: CGPoint(x: -2, y: 16))
                petals.addQuadCurve(to: CGPoint(x: 18, y: 21), control: CGPoint(x: 3, y: 23))
                context.scaleBy(x: size.width / 24, y: size.height / 24)
                context.fill(petals, with: .color(.white))
            }
        }
        .accessibilityLabel("Avast")
    }
}
