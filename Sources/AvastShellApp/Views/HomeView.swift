import SwiftUI

struct HomeView: View {
    let state: AppState

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                ZStack {
                    Circle().stroke(AvastTheme.primary, lineWidth: 4)
                    Path { p in
                        p.move(to: CGPoint(x: 26, y: 46))
                        p.addLine(to: CGPoint(x: 39, y: 59))
                        p.addLine(to: CGPoint(x: 65, y: 32))
                    }
                    .stroke(.white, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                }
                .frame(width: 88, height: 88)
                .padding(.top, 55)

                (Text("这台 Mac 处于") + Text("受保护").foregroundColor(AvastTheme.primary) + Text("模式"))
                    .font(.system(size: 34, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.top, 30)

                Button {
                    Task { await state.checkForUpdates() }
                } label: {
                    Text(state.isCheckingForUpdates
                         ? "正在检查更新…"
                         : "已是最新版本！ 上次更新于: \(DisplayDate.string(state.lastUpdatedAt))")
                        .font(.system(size: 13))
                        .foregroundStyle(AvastTheme.textSecondary)
                }
                .buttonStyle(AvastHoverButtonStyle())
                .disabled(state.isCheckingForUpdates)
                .help("检查更新")
                .padding(.top, 27)

                Button("运行智能扫描") { state.startScan(kind: .smart) }
                    .buttonStyle(AvastPrimaryButtonStyle())
                    .padding(.top, 27)

                Grid(horizontalSpacing: 18, verticalSpacing: 12) {
                    GridRow {
                        FeatureTile(icon: .search, title: "病毒扫描", isScanning: true) { state.showScanCenter() }
                        FeatureTile(icon: .scam, title: "反诈卫士", hasAIBadge: true) {}
                        FeatureTile(icon: .globe, title: "流量监测程序") {}
                        FeatureTile(icon: .network, title: "网络检测程序") {}
                    }
                    GridRow {
                        FeatureTile(icon: .mail, title: "电子邮件保护") {}
                        FeatureTile(icon: .ransomware, title: "勒索软件防护", showLock: true) {}
                        FeatureTile(icon: .shield, title: "核心防护") {}
                        FeatureTile(icon: .quarantine, title: "隔离") {}
                    }
                }
                .padding(.horizontal, AvastTheme.pageInset)
                .padding(.top, 24)
                Spacer(minLength: 0)
            }
            warningStrip
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var warningStrip: some View {
        HStack(spacing: 16) {
            AvastIcon(kind: .network)
                .frame(width: 46, height: 46)
                .overlay(alignment: .bottomTrailing) {
                    Text("!").font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(red: 0.1, green: 0.05, blue: 0.25))
                        .frame(width: 18, height: 22)
                        .background(Capsule().fill(Color(red: 1, green: 0.23, blue: 0.43)))
                }
            VStack(alignment: .leading, spacing: 7) {
                Text("您的网络没有威胁监测功能").font(.system(size: 13, weight: .semibold))
                Text("这只是 Avast 发现的 3 个安全问题之一。")
                    .font(.system(size: 14)).foregroundStyle(AvastTheme.textSecondary)
            }
            Spacer()
            Button("解决") {}.buttonStyle(AvastPrimaryButtonStyle(compact: true))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 24)
        .frame(height: 80)
        .background(UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12).fill(Color(red: 0.07, green: 0.04, blue: 0.25).opacity(0.7)))
        .padding(.horizontal, 35)
    }
}
