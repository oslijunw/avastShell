import AppKit
import SwiftUI

@main
struct AvastShellApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var appState: AppState

    init() {
        let store = HistoryStore(fileURL: HistoryStore.applicationFileURL)
        try? store.migrateLegacyHistory(from: [
            URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("scan-history.json"),
            Self.fallbackHistoryFileURL(),
            FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("AvastShell/scan-history.json"),
            Bundle.main.bundleURL.deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("scan-history.json")
        ])
        let initialState: AppState
        do {
            initialState = try AppState(historyStore: store)
        } catch {
            NSApplication.shared.setActivationPolicy(.regular)
            let alert = NSAlert()
            alert.messageText = "无法读取或保存 avast.jsonl"
            alert.informativeText = error.localizedDescription
            alert.addButton(withTitle: "退出")
            alert.runModal()
            exit(EXIT_FAILURE)
        }

        _appState = State(initialValue: initialState)
    }

    var body: some Scene {
        WindowGroup {
            RootShellView(state: appState)
                .frame(minWidth: 860, minHeight: 574)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 1008, height: 672)
        .windowResizability(.contentSize)
    }

    private static func fallbackHistoryFileURL() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("AvastShellApp")
            .appendingPathComponent("scan-history.json")
    }
}

private final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        DispatchQueue.main.async {
            for window in NSApp.windows {
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
                window.isMovableByWindowBackground = true
                window.backgroundColor = NSColor(red: 0.04, green: 0.02, blue: 0.2, alpha: 1)
            }
        }
    }
}

private struct RootShellView: View {
    let state: AppState

    var body: some View {
        GeometryReader { geometry in
            let scale = min(geometry.size.width / 1008, geometry.size.height / 672)
            ZStack {
                AvastTheme.backgroundGradient
                VStack(spacing: 0) {
                    TopBarView(state: state)
                    PageSwitcher(state: state)
                        .frame(height: 634)
                }
                .frame(width: 1008, height: 672)
                .scaleEffect(scale)
                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
    }
}

/// 页面切换容器。
/// 前进：新页面从右缘滑入（从右到左），旧页面向左滑出，两页整体同步推移。
/// 后退：新页面从左缘滑入（从左到右）并覆盖原地不动的旧页面。
private struct PageSwitcher: View {
    let state: AppState

    @State private var current: AppPage = .home
    @State private var incoming: AppPage?
    @State private var isForward = true
    @State private var slideOffset: CGFloat = 0

    private static let pageWidth: CGFloat = 1008
    private static let slideDuration: TimeInterval = 0.28

    var body: some View {
        ZStack {
            pageView(current)
                .offset(x: currentOffset)
            if let incoming {
                pageView(incoming)
                    .zIndex(1)
                    .offset(x: slideOffset)
            }
        }
        .frame(width: Self.pageWidth, height: 634)
        .clipped()
        .onChange(of: state.page) { _, newValue in
            guard newValue != current else { return }
            if incoming != nil {
                // 上一次过渡尚未结束又发生跳转：直接定位到最新页面
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                    current = newValue
                    incoming = nil
                    slideOffset = 0
                }
                return
            }
            isForward = state.navigationDirection == .forward
            incoming = newValue
            slideOffset = isForward ? Self.pageWidth : -Self.pageWidth
            withAnimation(.easeInOut(duration: Self.slideDuration)) {
                slideOffset = 0
            } completion: {
                current = newValue
                incoming = nil
            }
        }
    }

    private var currentOffset: CGFloat {
        guard incoming != nil else { return 0 }
        // 前进：旧页随新页同步向左滑出；后退：旧页随新页同步向右滑出。
        return isForward ? slideOffset - Self.pageWidth : slideOffset + Self.pageWidth
    }

    @ViewBuilder
    private func pageView(_ page: AppPage) -> some View {
        Group {
            switch page {
            case .home: HomeView(state: state)
            case .scanCenter: ScanCenterView(state: state)
            case .deepScanProgress: DeepScanProgressView(state: state)
            case .scanHistory: ScanHistoryView(state: state)
            }
        }
        .frame(width: Self.pageWidth)
        .background(AvastTheme.backgroundGradient)
    }
}
