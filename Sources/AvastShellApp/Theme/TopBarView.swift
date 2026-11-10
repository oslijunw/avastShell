import SwiftUI

struct TopBarView: View {
    let state: AppState
    @State private var showingMenu = false
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
                    .popover(isPresented: $showingMenu, arrowEdge: .top) {
                        Button {
                            Task { await state.checkForUpdates() }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: state.hasCheckedForUpdates ? "checkmark.circle" : "arrow.clockwise")
                                    .foregroundStyle(AvastTheme.primary)
                                Text(state.isCheckingForUpdates ? "正在检查更新…" : state.hasCheckedForUpdates ? "已是最新版本" : "检查更新")
                                    .font(.system(size: 14))
                                Spacer(minLength: 0)
                            }
                            .foregroundStyle(.white)
                            .padding(16)
                            .frame(width: 190)
                            .background(AvastTheme.backgroundGradient)
                        }
                        .buttonStyle(AvastHoverButtonStyle())
                        .disabled(state.isCheckingForUpdates)
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

    private func item(_ symbol: String, _ title: String) -> some View {
        Button {} label: {
            HStack(spacing: 10) {
                Image(systemName: symbol).font(.system(size: 18, weight: .light))
                Text(title).font(.system(size: 14))
            }
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
