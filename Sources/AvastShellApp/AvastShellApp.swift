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
                    Group {
                        switch state.page {
                        case .home: HomeView(state: state)
                        case .scanCenter: ScanCenterView(state: state)
                        case .deepScanProgress: DeepScanProgressView(state: state)
                        case .scanHistory: ScanHistoryView(state: state)
                        }
                    }
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
