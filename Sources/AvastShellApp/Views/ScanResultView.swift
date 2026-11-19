import SwiftUI

/// 扫描结果页：从扫描历史「显示结果」进入，展示单次扫描的结果摘要。
struct ScanResultView: View {
    let state: AppState

    var body: some View {
        Group {
            if let record = state.displayedRecord {
                content(record)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(.white)
    }

    private func content(_ record: ScanRecord) -> some View {
        VStack(spacing: 0) {
            Spacer()
            resultIcon
            Text("未发现威胁")
                .font(.system(size: 34, weight: .semibold))
                .padding(.top, 30)
            HStack(spacing: 6) {
                Text(summaryText(record))
                Button("显示详细信息") { state.isShowingScanDetails = true }
                    .buttonStyle(.plain)
                    .underline()
            }
            .font(.system(size: 14))
            .padding(.top, 26)
            Spacer()
            Button("完成") { state.closeScanResult() }
                .buttonStyle(AvastOutlineButtonStyle())
                .frame(width: 120)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var resultIcon: some View {
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
    }

    private func summaryText(_ record: ScanRecord) -> String {
        let statusText = record.status == .canceledNoThreats ? "已取消" : record.status.rawValue
        var text = "\(record.kind.rawValue) \(statusText)。"
        if let duration = record.duration {
            text += "已在 \(Self.durationText(duration)) 内扫描 \(record.fileCount.formatted()) 个文件。"
        } else {
            text += "已扫描 \(record.fileCount.formatted()) 个文件。"
        }
        return text
    }

    static func durationText(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let hours = total / 3600
        let minutes = total % 3600 / 60
        let seconds = total % 60
        if hours > 0 { return "\(hours)小时\(minutes)分钟\(seconds)秒钟" }
        if minutes > 0 { return "\(minutes)分钟\(seconds)秒钟" }
        return "\(seconds)秒钟"
    }
}

/// 扫描详细信息浮层：结果页点击「显示详细信息」弹出，覆盖整个窗口。
struct ScanResultDetailsSheet: View {
    let record: ScanRecord
    var onClose: () -> Void

    private struct DetailOption: Identifiable {
        let id: String
        let title: String
        var subtitle: String? = nil
        var indent = false
        var defaultValue = false
    }

    private static let options: [DetailOption] = [
        .init(id: "pup", title: "通知我有关可能不需要的程序",
              subtitle: "有些程序可以在您不知情的情况下安装（例如，它们与其他程序捆绑在一起时）。",
              defaultValue: true),
        .init(id: "tools", title: "扫描工具",
              subtitle: "工具即可用于访问、控制或可能损害计算机的应用程序。",
              indent: true),
        .init(id: "allFiles", title: "测试所有文件",
              subtitle: "扫描所有文件，而不是只扫描通常受恶意代码影响的部分。扫描更大的文件需要更长的时间。"),
        .init(id: "external", title: "扫描外部驱动器"),
        .init(id: "network", title: "扫描安装的网络卷"),
        .init(id: "timeMachine", title: "扫描所有 Time Machine 备份"),
        .init(id: "archives", title: "扫描存档 (RAR、ZIP 等)", defaultValue: true),
    ]

    @State private var checked: [String: Bool] = Dictionary(
        uniqueKeysWithValues: ScanResultDetailsSheet.options.map { ($0.id, $0.defaultValue) }
    )

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(record.kind.rawValue)
                            .font(.system(size: 34, weight: .semibold))
                        Text("扫描详细信息")
                            .font(.system(size: 19, weight: .semibold))
                            .padding(.top, 40)
                        detailLines
                            .padding(.top, 26)
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(Self.options) { option in
                                checkbox(option)
                            }
                        }
                        .padding(.top, 38)
                        Text("例外")
                            .font(.system(size: 22, weight: .semibold))
                            .padding(.top, 44)
                        Text("深度扫描永远不会扫描下面指定的文件和目录")
                            .font(.system(size: 14))
                            .foregroundStyle(AvastTheme.textSecondary)
                            .padding(.top, 24)
                        Text("例外路径")
                            .font(.system(size: 14))
                            .padding(.top, 32)
                        Rectangle()
                            .fill(.white.opacity(0.15))
                            .frame(height: 1)
                            .padding(.top, 14)
                    }
                    .padding(.horizontal, 40)
                    .padding(.top, 44)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollIndicators(.hidden)
                footer
            }
            .frame(width: 790, height: 612)
            .background(Color(red: 0.12, green: 0.08, blue: 0.36))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.white)
        }
    }

    private var detailLines: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(record.status == .canceledNoThreats ? "扫描已取消" : "扫描已完成")
            if let duration = record.duration {
                Text("已在 \(ScanResultView.durationText(duration)) 内扫描 \(record.fileCount.formatted()) 个文件。")
            } else {
                Text("已扫描 \(record.fileCount.formatted()) 个文件。")
            }
            Text("扫描开始时间：\(startTimeText)")
            Text("扫描类型：\(record.kind.rawValue)")
        }
        .font(.system(size: 15))
    }

    private var footer: some View {
        Rectangle()
            .fill(Color.black.opacity(0.25))
            .frame(height: 92)
            .overlay {
                Button("完成") { onClose() }
                    .buttonStyle(AvastPrimaryButtonStyle())
                    .frame(width: 160)
            }
    }

    private func checkbox(_ option: DetailOption) -> some View {
        Button {
            checked[option.id]?.toggle()
        } label: {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: (checked[option.id] ?? false) ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20))
                    .foregroundStyle((checked[option.id] ?? false) ? Color.white.opacity(0.9) : Color.white.opacity(0.5))
                VStack(alignment: .leading, spacing: 7) {
                    Text(option.title).font(.system(size: 16, weight: .medium))
                    if let subtitle = option.subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundStyle(AvastTheme.textSecondary)
                    }
                }
                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.leading, option.indent ? 40 : 0)
    }

    private var startTimeText: String {
        let offset = TimeZone.current.secondsFromGMT(for: record.createdAt)
        let hours = offset / 3600
        let sign = hours >= 0 ? "+" : "-"
        return "\(Self.dateFormatter.string(from: record.createdAt))GMT\(sign)\(abs(hours)) \(Self.timeFormatter.string(from: record.createdAt))"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "y年M月d日 EEEE"
        return formatter
    }()

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()
}
