import SwiftUI

struct ScanHistoryView: View {
    let state: AppState

    var body: some View {
        VStack(spacing: 24) {
            ScanHeaderView(state: state, selectedTab: .history)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(state.historySnapshot.records) { record in
                        historyRow(record)
                    }
                }
                .background(alignment: .leading) {
                    Rectangle().fill(.white.opacity(0.1)).frame(width: 1.5).padding(.leading, 23)
                }
                .padding(.horizontal, 56)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
        }
    }

    private func historyRow(_ record: ScanRecord) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ScanIconBadge(kind: record.kind == .smart ? .brain : .deep)
                .scaleEffect(1.2).frame(width: 48, height: 48)
                .overlay(alignment: .bottomTrailing) {
                    // 两种状态（完成/取消）均为未发现威胁，统一显示绿色对勾
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(Color(red: 0.08, green: 0.04, blue: 0.22))
                        .frame(width: 16, height: 16)
                        .background(Circle().fill(AvastTheme.primary))
                }
            VStack(alignment: .leading, spacing: 9) {
                Text("\(record.kind.rawValue) \(record.status.rawValue)。")
                    .font(.system(size: 14, weight: .semibold))
                Text(DisplayDate.string(record.createdAt))
                    .font(.system(size: 14))
                    .foregroundStyle(AvastTheme.textSecondary)
                HStack(spacing: 14) {
                    Button("显示结果") { state.showScanResult(record) }
                        .buttonStyle(AvastOutlineButtonStyle())
                    Button { try? state.deleteRecord(id: record.id) } label: {
                        Image(systemName: "trash").font(.system(size: 21, weight: .light)).frame(width: 28, height: 30)
                    }
                    .buttonStyle(AvastHoverButtonStyle())
                    .accessibilityLabel("删除记录")
                }
            }
            .padding(.top, 3)
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(.bottom, 20)
    }

}
