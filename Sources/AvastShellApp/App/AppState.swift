import Foundation
import Observation

@Observable
final class AppState {
    var page: AppPage = .home
    /// 最近一次页面切换的方向，用于驱动左右滑动过渡动画。
    private(set) var navigationDirection: NavigationDirection = .forward
    var scanCenterTab: ScanCenterTab = .scanNow
    var scanTitle: String = "深度扫描"
    var scanProgress: Int = 0
    var historySnapshot: ScanHistorySnapshot

    let launchedAt: Date
    let lastUpdatedAt: Date
    var isCheckingForUpdates = false
    var hasCheckedForUpdates = false

    private let historyStore: HistoryStore
    private var activeScanKind: ScanRecord.Kind?

    init(historyStore: HistoryStore, launchedAt: Date = Date()) throws {
        self.launchedAt = launchedAt
        self.lastUpdatedAt = launchedAt.addingTimeInterval(-30 * 60)
        self.historyStore = historyStore
        var snapshot = try historyStore.load()
        snapshot.settings.lastLaunchedAt = launchedAt
        snapshot.settings.lastUpdatedAt = lastUpdatedAt
        self.historySnapshot = try historyStore.save(snapshot)
    }

    // Update checks are a short local simulation, consistent with the visual prototype.
    @MainActor
    func checkForUpdates() async {
        guard !isCheckingForUpdates else { return }
        isCheckingForUpdates = true
        defer { isCheckingForUpdates = false }
        do { try await Task.sleep(for: .milliseconds(650)) }
        catch { return }
        hasCheckedForUpdates = true
    }

    func showScanCenter(tab: ScanCenterTab = .scanNow) {
        scanCenterTab = tab
        navigationDirection = .forward
        page = .scanCenter
    }

    func showHome() {
        navigationDirection = .backward
        page = .home
    }

    func showScanHistory() {
        historySnapshot = (try? historyStore.load()) ?? historySnapshot
        navigationDirection = .forward
        page = .scanHistory
    }

    func startDeepScan() {
        startScan(kind: .deep)
    }

    func startScan(kind: ScanRecord.Kind) {
        activeScanKind = kind
        scanTitle = kind.rawValue
        scanProgress = 0
        navigationDirection = .forward
        page = .deepScanProgress
    }

    func advanceScanProgress(by amount: Int = 1) {
        scanProgress = min(100, scanProgress + amount)
    }

    func cancelActiveScan(now: Date, fileCount: Int? = nil) throws {
        guard let activeScanKind else {
            return
        }

        let record = ScanFactory.makeCanceledRecord(kind: activeScanKind, now: now, fileCount: fileCount)
        historySnapshot.records.insert(record, at: 0)
        historySnapshot = try historyStore.save(historySnapshot)

        self.activeScanKind = nil
        scanProgress = 0
        navigationDirection = .backward
        page = .scanCenter
    }

    func completeActiveScan(now: Date, fileCount: Int? = nil) throws {
        guard let activeScanKind else {
            return
        }

        let record = ScanFactory.makeCompletedRecord(kind: activeScanKind, now: now, fileCount: fileCount)
        historySnapshot.records.insert(record, at: 0)
        historySnapshot = try historyStore.save(historySnapshot)

        self.activeScanKind = nil
        scanProgress = 100
        navigationDirection = .forward
        page = .scanHistory
    }

    func deleteRecord(id: UUID) throws {
        historySnapshot = try historyStore.deleteRecord(id: id)
    }
}
