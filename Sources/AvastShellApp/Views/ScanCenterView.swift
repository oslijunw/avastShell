import SwiftUI

struct ScanCenterView: View {
    let state: AppState
    var body: some View {
        VStack(spacing: 24) {
            ScanHeaderView(state: state, selectedTab: state.scanCenterTab)
            if state.scanCenterTab == .scheduled {
                HStack(spacing: 18) {
                    ScanIconBadge(kind: .deep)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("每周自动扫描").font(.system(size: 16, weight: .semibold))
                        Text("每周一次").font(.system(size: 14)).foregroundStyle(AvastTheme.textSecondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill").font(.system(size: 22)).foregroundStyle(AvastTheme.primary)
                }
                .padding(24).avastCard().padding(.horizontal, 56)
            } else {
                HStack(alignment: .top, spacing: 32) {
                    smartScanCard.frame(width: 288, height: 288)
                    VStack(spacing: 16) {
                        scanRow(.deep, "深度扫描", "对恶意软件运行深度扫描，包括分析存储驱动器和系统内存。", progress: true)
                        scanRow(.folder, "定向扫描", "扫描 Mac 上的特定文件或文件夹以查找恶意软件。")
                        scanRow(.usb, "外部存储扫描", "扫描连接到 Mac 的任何 USB、外置驱动器或其他存储设备以查找恶意软件。")
                    }
                }
                .padding(.horizontal, 56)
            }
            Spacer(minLength: 0)
        }
    }

    private var smartScanCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScanIconBadge(kind: .brain).padding(.bottom, 22)
            Text("智能扫描").font(.system(size: 16, weight: .semibold)).padding(.bottom, 14)
            Text("发现并删除 Mac 中最容易受到攻击的区域中的恶意软件，并解决常见的隐私和性能问题。")
                .font(.system(size: 14)).foregroundStyle(AvastTheme.textSecondary)
                .lineSpacing(6).fixedSize(horizontal: false, vertical: true)
            Spacer()
            Button("立即扫描") { state.startScan(kind: .smart) }
                .buttonStyle(AvastPrimaryButtonStyle())
        }
        .foregroundStyle(.white)
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .avastCard()
    }

    private func scanRow(_ icon: AvastIconKind, _ title: String, _ subtitle: String, progress: Bool = false) -> some View {
        Button { state.startDeepScan() } label: {
            HStack(alignment: .top, spacing: 12) {
                ScanIconBadge(kind: icon, progress: progress)
                VStack(alignment: .leading, spacing: 14) {
                    Text(title).font(.system(size: 16, weight: .semibold)).foregroundStyle(.white)
                    Text(subtitle).font(.system(size: 14)).foregroundStyle(AvastTheme.textSecondary)
                        .lineSpacing(4).fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 4)
                Spacer(minLength: 10)
                Image(systemName: "arrow.right").font(.system(size: 25, weight: .light))
                    .foregroundStyle(AvastTheme.primary).frame(maxHeight: .infinity)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: icon == .usb ? 116 : 92, alignment: .leading)
            .avastCard()
        }
        .buttonStyle(AvastHoverButtonStyle())
    }
}
