import SwiftUI

enum ScanCenterTab {
    case scanNow, scheduled, history
}

struct ScanHeaderView: View {
    let state: AppState
    let selectedTab: ScanCenterTab

    var body: some View {
        ZStack(alignment: .top) {
            Text("欢迎使用扫描中心！")
                .font(.system(size: 32, weight: .semibold))
                .padding(.top, 46)
            Text("确保 Mac 安全且不感染病毒所需的一切。我们将在恶意软件的可能藏身之处进行搜寻，并且根据您的时间计划表自动扫描。")
                .font(.system(size: 14))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 56)
                .padding(.top, 120)
            HStack(spacing: 0) {
                tab("立即扫描", .scanNow)
                tab("预定扫描", .scheduled)
                tab("扫描历史记录", .history)
            }
            .frame(height: 37)
            .frame(maxHeight: .infinity, alignment: .bottom)
            HStack {
                edgeButton("arrow.left", label: "返回") {
                    selectedTab == .history ? state.showScanCenter() : state.showHome()
                }
                Spacer()
                edgeButton("gearshape", label: "扫描设置") { state.showScanCenter(tab: .scheduled) }
            }
            .padding(.top, 26)
        }
        .foregroundStyle(.white)
        .frame(height: 207)
        .overlay(alignment: .bottom) {
            Rectangle().fill(.white.opacity(0.12)).frame(height: 1).padding(.horizontal, 56)
        }
    }

    private func tab(_ title: String, _ value: ScanCenterTab) -> some View {
        Button {
            state.selectScanTab(value)
        } label: {
            Text(title).font(.system(size: 14, weight: .medium))
                .foregroundStyle(selectedTab == value ? .white : AvastTheme.textSecondary)
                .padding(.horizontal, 13)
                .frame(height: 37)
                .background(.white.opacity(selectedTab == value && value == .history ? 0.07 : 0))
                .overlay(alignment: .bottom) {
                    if selectedTab == value { Rectangle().fill(AvastTheme.primary).frame(height: 3) }
                }
        }
        .buttonStyle(AvastHoverButtonStyle())
    }

    private func edgeButton(_ icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon).font(.system(size: 22, weight: .light))
                .frame(width: 40, height: 80)
                .background(Circle().fill(.white.opacity(0.07)).frame(width: 80, height: 80))
        }
        .buttonStyle(AvastHoverButtonStyle())
        .accessibilityLabel(label)
    }
}

struct ScanIconBadge: View {
    let kind: AvastIconKind
    /// 进度环数值（0…1）；nil 表示未在扫描中，不显示进度环。
    var progress: Double? = nil
    var body: some View {
        AvastIcon(kind: kind).frame(width: 24, height: 24)
            .frame(width: 40, height: 40)
            .background(Circle().fill(AvastTheme.accent))
            .overlay {
                if let progress {
                    Circle().trim(from: 0, to: progress)
                        .stroke(AvastTheme.primary, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: progress)
                }
            }
    }
}
