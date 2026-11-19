import AppKit
import SwiftUI

/// 「首选项」独立窗口：顶部图标 tab 栏 + 分页设置内容。
struct PreferencesWindowView: View {
    let state: AppState

    @State private var selectedTab: PreferencesTab = .general
    @State private var generalOptions: Set<String> = ["autoUpdate", "menuBarIcon"]
    @State private var privacyOptions: Set<String> = ["shareSamples", "thirdPartyAnalytics", "personalOffers"]
    @State private var notificationOptions: Set<String> = ["fullscreenNotifications"]

    var body: some View {
        VStack(spacing: 0) {
            // 隐藏标题栏仍会保留顶部安全区，整体上移以贴齐参考窗口。
            HStack {
                Spacer()
                Text("首选项")
                    .font(.system(size: 15, weight: .medium))
                Spacer()
            }
            .frame(height: 18)
            tabBar
            Rectangle()
                .fill(.white.opacity(0.15))
                .frame(height: 1)
            Group {
                switch selectedTab {
                case .general: generalPane
                case .subscription: subscriptionPane
                case .privacy: privacyPane
                case .notifications: notificationsPane
                default: placeholderPane
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(width: 800, height: 620)
        .background(AvastTheme.backgroundGradient)
        .foregroundStyle(.white)
        .preferredColorScheme(.dark)
        .task {
            // 隐藏标题栏后窗口无法从标题栏拖动，启用背景拖动
            for _ in 0..<50 {
                if let window = NSApp.windows.first(where: { $0.title == "首选项" }) {
                    window.isMovableByWindowBackground = true
                    break
                }
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
    }

    // MARK: - Tab 栏

    private var tabBar: some View {
        HStack(spacing: 16) {
            ForEach(PreferencesTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 22, weight: .light))
                            .frame(height: 25)
                        Text(tab.title).font(.system(size: 14))
                        Capsule()
                            .fill(AvastTheme.primary)
                            .frame(width: 44, height: 4)
                            .opacity(selectedTab == tab ? 1 : 0)
                    }
                    .foregroundStyle(selectedTab == tab ? .white : .white.opacity(0.72))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .focusable(false)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 22)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    // MARK: - 通用

    private var generalPane: some View {
        VStack(spacing: 0) {
            VStack(spacing: 18) {
                Text("Avast Security (16.5.0)")
                    .font(.system(size: 23, weight: .semibold))
                Text("已是最新版本!").font(.system(size: 14))
                Text("上次更新于: \(lastUpdateText)").font(.system(size: 14))
                Button {
                    Task { await state.checkForUpdates() }
                } label: {
                    Text(state.isCheckingForUpdates ? "正在检查更新…" : "立即更新")
                        .font(.system(size: 14))
                        .frame(width: 150, height: 40)
                }
                .buttonStyle(AvastPrimaryButtonStyle())
                .disabled(state.isCheckingForUpdates)
            }
            .padding(.top, 46)
            .padding(.bottom, 38)
            Rectangle()
                .fill(.white.opacity(0.12))
                .frame(height: 1)
            VStack(alignment: .leading, spacing: 22) {
                checkRow("autoUpdate", "打开自动更新", options: $generalOptions)
                checkRow("menuBarIcon", "在菜单栏显示 Avast 图标", options: $generalOptions)
                checkRow("launchAtLogin", "电脑启动时打开 Avast Security", options: $generalOptions)
                checkRow("virusDefinitionNotice", "病毒定义更新后通知我", options: $generalOptions)
                checkRow("betaProgram", "加入我们的测试版程序", options: $generalOptions)
            }
            .padding(.horizontal, 52)
            .padding(.vertical, 34)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    /// 「上次更新于」时间文案：今天 HH:mm；非当天显示月日。
    private var lastUpdateText: String {
        let date = state.lastUpdatedAt
        if Calendar.current.isDateInToday(date) {
            return "今天 " + Self.timeFormatter.string(from: date)
        }
        return Self.dateFormatter.string(from: date)
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        return formatter
    }()

    // MARK: - 订阅

    private var subscriptionPane: some View {
        VStack(alignment: .leading, spacing: 26) {
            Text("这台 Mac 上的订阅")
                .font(.system(size: 19, weight: .semibold))
            Button("激活付费功能") {}
                .buttonStyle(AvastOutlineButtonStyle())
                .font(.system(size: 12))
                .frame(width: 120)
            HStack(spacing: 8) {
                Text("欧盟客户可在 14 天内撤销购买。")
                Text("取消合同").underline()
            }
            .font(.system(size: 12))
            HStack(spacing: 16) {
                AvastBrandMark().frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 5) {
                    Text("Avast Security").font(.system(size: 15, weight: .semibold))
                    Text("激活").font(.system(size: 12)).foregroundStyle(AvastTheme.primary)
                    Text("免费版本永不过期").font(.system(size: 12))
                }
                Spacer()
                Button("进入 PREMIUM") {}
                    .buttonStyle(AvastPrimaryButtonStyle())
                    .font(.system(size: 12))
                    .frame(width: 130)
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(AvastTheme.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(.horizontal, 40)
        .padding(.top, 44)
    }

    // MARK: - 隐私

    private var privacyPane: some View {
        VStack(alignment: .leading, spacing: 26) {
            Text("个人隐私").font(.system(size: 19, weight: .semibold))
            (Text("阅读我们的 ")
             + Text("一般隐私声明").underline().foregroundStyle(AvastTheme.primary)
             + Text("，了解我们如何处理您的数据。查看我们在")
             + Text("产品隐私声明").underline().foregroundStyle(AvastTheme.primary)
             + Text("中处理的数据类别。这些设置适用于 Avast Security。"))
                .font(.system(size: 12))
            Text("改进").font(.system(size: 15, weight: .semibold))
            checkRow("shareSamples", "与我们共享可疑文件样本，帮助提升所有用户的安全性",
                     subtitle: "为明确起见，我们将始终分析威胁检测元数据，以保障设备安全（无论是否已禁用此功能）。",
                     options: $privacyOptions)
            checkRow("thirdPartyAnalytics", "允许我们在第三方工具中分析应用使用数据,以帮助改进我们的产品和业务流程。",
                     subtitle: "查看我们的产品隐私声明，了解我们所用的工具。",
                     options: $privacyOptions)
            Text("专属优惠").font(.system(size: 15, weight: .semibold))
            checkRow("personalOffers", "允许我们使用有关您、您的设备和应用使用情况的数据,为您量身定制产品价格折扣",
                     subtitle: "如果关闭，您将无法享受任何专属折扣。详细了解我们的具体做法。",
                     options: $privacyOptions)
            Spacer()
        }
        .padding(.horizontal, 44)
        .padding(.top, 40)
    }

    // MARK: - 通知

    private var notificationsPane: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("通知").font(.system(size: 19, weight: .semibold))
            Text("控制何时显示非关键通知。").font(.system(size: 12))
            checkRow("focusModeMute", "处于专注模式时禁用通知", options: $notificationOptions)
            checkRow("fullscreenNotifications", "处于全屏模式时禁用通知", options: $notificationOptions)
            Text("电子邮件防护").font(.system(size: 15, weight: .semibold))
            checkRow("weeklyDigest", "接收每周汇总报告",
                     subtitle: "这将启用即时检测提示",
                     options: $notificationOptions)
            Spacer()
        }
        .padding(.horizontal, 44)
        .padding(.top, 44)
    }

    // MARK: - 其余 tab 占位

    private var placeholderPane: some View {
        VStack(spacing: 14) {
            Image(systemName: selectedTab.symbol)
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.white.opacity(0.4))
            Text("此板块的设置项即将推出")
                .font(.system(size: 14))
                .foregroundStyle(AvastTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 复选框行

    private func checkRow(_ id: String, _ title: String, subtitle: String? = nil, options: Binding<Set<String>>) -> some View {
        Button {
            if options.wrappedValue.contains(id) { options.wrappedValue.remove(id) }
            else { options.wrappedValue.insert(id) }
        } label: {
            HStack(alignment: .top, spacing: 14) {
                let checked = options.wrappedValue.contains(id)
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(.white.opacity(0.5), lineWidth: 1.5)
                        .background(RoundedRectangle(cornerRadius: 5).fill(.white.opacity(0.04)))
                    if checked {
                        RoundedRectangle(cornerRadius: 5).fill(AvastTheme.primary)
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color(red: 0.08, green: 0.04, blue: 0.22))
                    }
                }
                .frame(width: 20, height: 20)
                VStack(alignment: .leading, spacing: 6) {
                    Text(title).font(.system(size: 15))
                    if let subtitle {
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
    }
}

/// 首选项窗口的 9 个设置分类。
enum PreferencesTab: String, CaseIterable, Identifiable {
    case general, subscription, privacy, notifications, scan
    case networkScan, emailProtection, ransomwareProtection, coreProtection

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: "通用"
        case .subscription: "订阅"
        case .privacy: "隐私"
        case .notifications: "通知"
        case .scan: "扫描"
        case .networkScan: "网络检测程序"
        case .emailProtection: "电子邮件保护"
        case .ransomwareProtection: "勒索软件防护"
        case .coreProtection: "核心防护"
        }
    }

    var symbol: String {
        switch self {
        case .general: "laptopcomputer"
        case .subscription: "creditcard"
        case .privacy: "person"
        case .notifications: "bell"
        case .scan: "magnifyingglass"
        case .networkScan: "house"
        case .emailProtection: "envelope"
        case .ransomwareProtection: "dollarsign.square"
        case .coreProtection: "shield"
        }
    }
}
