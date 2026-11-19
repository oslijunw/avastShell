import Foundation
import Observation

@MainActor
@Observable
final class AppState {
    var page: AppPage = .home
    /// 最近一次页面切换的方向，用于驱动左右滑动过渡动画。
    private(set) var navigationDirection: NavigationDirection = .forward
    var scanCenterTab: ScanCenterTab = .scanNow
    /// 当前在结果页查看的历史记录（关闭结果页时保留，以保证退场动画正常渲染）。
    private(set) var displayedRecord: ScanRecord?
    /// 是否显示扫描详细信息浮层。
    var isShowingScanDetails = false
    var scanTitle: String = "深度扫描"
    var scanProgress: Int = 0
    /// 扫描模拟的步数与步长，测试中可调小以加速。
    var scanSimulationSteps = 40
    var scanSimulationStepInterval: Duration = .milliseconds(90)
    var historySnapshot: ScanHistorySnapshot

    let launchedAt: Date
    let lastUpdatedAt: Date
    var isCheckingForUpdates = false
    var hasCheckedForUpdates = false

    private let historyStore: HistoryStore
    private var activeScanKind: ScanRecord.Kind?
    private var scanTask: Task<Void, Never>?

    /// 是否有扫描正在进行（含用户已返回其他页面的后台扫描）。
    var isScanRunning: Bool { activeScanKind != nil }

    /// 深度扫描运行中的进度环数值（0…1）；未运行时为 nil，不显示进度环。
    var deepScanProgressFraction: Double? {
        guard activeScanKind == .deep else { return nil }
        return Double(scanProgress) / 100
    }

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

    /// 从扫描历史打开某条记录的结果页。
    func showScanResult(_ record: ScanRecord) {
        displayedRecord = record
        isShowingScanDetails = false
        navigationDirection = .forward
        page = .scanResult
    }

    /// 关闭结果页，返回扫描历史页（进入结果页前的页面）。
    func closeScanResult() {
        isShowingScanDetails = false
        navigationDirection = .backward
        page = .scanHistory
    }

    /// 扫描中心内部 tab 切换（立即扫描/预定扫描/扫描历史记录）：直接切换内容，不播放滑动动画。
    func selectScanTab(_ tab: ScanCenterTab) {
        scanCenterTab = tab
        navigationDirection = .instant
        if tab == .history {
            historySnapshot = (try? historyStore.load()) ?? historySnapshot
        }
        page = tab == .history ? .scanHistory : .scanCenter
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
        startScanSimulation()
    }

    /// 扫描进行中再次点击深度扫描：仅回到进度页，不重置进度。
    func deepScanTapped() {
        if activeScanKind == .deep {
            navigationDirection = .forward
            page = .deepScanProgress
        } else {
            startDeepScan()
        }
    }

    func advanceScanProgress(by amount: Int = 1) {
        scanProgress = min(100, scanProgress + amount)
    }

    func cancelActiveScan(now: Date, fileCount: Int? = nil) throws {
        scanTask?.cancel()
        scanTask = nil
        guard let activeScanKind else {
            return
        }

        let duration = scanDuration()
        let record = ScanFactory.makeCanceledRecord(kind: activeScanKind, now: now, fileCount: fileCount, duration: duration)
        historySnapshot.records.insert(record, at: 0)
        historySnapshot = try historyStore.save(historySnapshot)

        self.activeScanKind = nil
        scanProgress = 0
        navigationDirection = .backward
        page = .scanCenter
    }

    func completeActiveScan(now: Date, fileCount: Int? = nil) throws {
        scanTask?.cancel()
        scanTask = nil
        guard let activeScanKind else {
            return
        }

        let duration = scanDuration()
        let record = ScanFactory.makeCompletedRecord(kind: activeScanKind, now: now, fileCount: fileCount, duration: duration)
        historySnapshot.records.insert(record, at: 0)
        historySnapshot = try historyStore.save(historySnapshot)

        self.activeScanKind = nil
        scanProgress = 100
        // 用户已返回其他页面时不再强制跳转到历史页
        if page == .deepScanProgress {
            navigationDirection = .forward
            page = .scanHistory
        }
    }

    /// 扫描耗时：视觉模拟采用 2-4 小时内的随机值。
    private func scanDuration() -> TimeInterval {
        TimeInterval.random(in: 7200...14400)
    }

    // 视觉模拟：无真实文件扫描，仅驱动进度推进与历史记录生成；离开进度页后继续在后台运行。
    private func startScanSimulation() {
        scanTask?.cancel()
        let kind = activeScanKind
        scanTask = Task { [weak self] in
            guard let self else { return }
            for step in 1...scanSimulationSteps {
                do { try await Task.sleep(for: scanSimulationStepInterval) }
                catch { return }
                guard !Task.isCancelled, activeScanKind == kind else { return }
                scanProgress = min(100, step * 100 / scanSimulationSteps)
            }
            do { try await Task.sleep(for: .milliseconds(250)) }
            catch { return }
            guard !Task.isCancelled, activeScanKind == kind else { return }
            try? completeActiveScan(now: Date())
        }
    }

    func deleteRecord(id: UUID) throws {
        historySnapshot = try historyStore.deleteRecord(id: id)
    }
}
