import Foundation
import Testing
@testable import AvastShellApp

struct AppStateTests {
    @Test @MainActor
    func homeActionNavigatesToScanCenter() throws {
        let state = try makeState(now: fixedNow)

        state.showScanCenter()

        #expect(state.page == .scanCenter)
        #expect(state.navigationDirection == .forward)
    }

    @Test @MainActor
    func returningHomeFromScanCenterMarksNavigationAsBackward() throws {
        let state = try makeState(now: fixedNow)

        state.showScanCenter()
        state.showHome()

        #expect(state.page == .home)
        #expect(state.navigationDirection == .backward)
    }

    @Test @MainActor
    func openingScanHistoryMarksNavigationAsForward() throws {
        let state = try makeState(now: fixedNow)

        state.showScanHistory()

        #expect(state.page == .scanHistory)
        #expect(state.navigationDirection == .forward)
    }

    @Test @MainActor
    func startingDeepScanSwitchesToProgressPageAndResetsProgress() throws {
        let state = try makeState(now: fixedNow)
        state.scanProgress = 57

        state.startDeepScan()

        #expect(state.page == .deepScanProgress)
        #expect(state.scanProgress == 0)
    }

    @Test @MainActor
    func cancelingActiveScanCreatesCanceledHistoryEntryAndReturnsToScanCenter() throws {
        let state = try makeState(now: fixedNow)

        state.startDeepScan()
        try state.cancelActiveScan(now: fixedNow, fileCount: 33_000_000)

        #expect(state.page == .scanCenter)
        #expect(state.navigationDirection == .backward)
        #expect(state.historySnapshot.records.first?.status == .canceledNoThreats)
        #expect(state.historySnapshot.records.first?.kind == .deep)
    }

    @Test @MainActor
    func completingActiveScanCreatesSuccessfulEntryAndSwitchesToHistory() throws {
        let state = try makeState(now: fixedNow)

        state.startDeepScan()
        try state.completeActiveScan(now: fixedNow, fileCount: 66_000_000)

        #expect(state.page == .scanHistory)
        #expect(state.historySnapshot.records.first?.status == .completedNoThreats)
        #expect(state.historySnapshot.records.first?.kind == .deep)
        #expect(state.historySnapshot.records.first?.fileCount == 66_000_000)
    }

    @Test @MainActor
    func smartScanKeepsItsTypeWhenCompleted() throws {
        let state = try makeState(now: fixedNow)
        state.startScan(kind: .smart)
        #expect(state.scanTitle == "智能扫描")
        try state.completeActiveScan(now: fixedNow, fileCount: 42_000_000)
        #expect(state.historySnapshot.records.first?.kind == .smart)
        #expect(state.page == .scanHistory)
    }

    @Test @MainActor
    func deepScanSurvivesRelaunchWithOriginalTimestamp() throws {
        let yesterday = fixedNow.addingTimeInterval(-86_400)
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString)
        let firstLaunch = try AppState(historyStore: HistoryStore(fileURL: url, now: { yesterday }), launchedAt: yesterday)
        firstLaunch.startDeepScan()
        try firstLaunch.completeActiveScan(now: yesterday, fileCount: 42_000_000)
        let secondLaunch = try AppState(historyStore: HistoryStore(fileURL: url, now: { fixedNow }), launchedAt: fixedNow)
        let deep = secondLaunch.historySnapshot.records.first(where: { $0.kind == .deep })
        #expect(deep?.createdAt == yesterday)
        #expect(deep?.fileCount == 42_000_000)
        #expect(secondLaunch.historySnapshot.settings.lastLaunchedAt == fixedNow)
        #expect(secondLaunch.historySnapshot.settings.lastUpdatedAt == fixedNow.addingTimeInterval(-1800))
    }

    @Test @MainActor
    func updateCheckKeepsTheStartupMinusHalfAnHourTimestamp() async throws {
        let state = try makeState(now: fixedNow)
        #expect(state.lastUpdatedAt == fixedNow.addingTimeInterval(-1800))
        await state.checkForUpdates()
        #expect(state.hasCheckedForUpdates)
        #expect(!state.isCheckingForUpdates)
        #expect(state.lastUpdatedAt == fixedNow.addingTimeInterval(-1800))
    }

    @Test @MainActor
    func scanTabSwitchIsInstantWithoutSlideAnimation() throws {
        let state = try makeState(now: fixedNow)

        state.selectScanTab(.history)
        #expect(state.page == .scanHistory)
        #expect(state.navigationDirection == .instant)

        state.selectScanTab(.scanNow)
        #expect(state.page == .scanCenter)
        #expect(state.scanCenterTab == .scanNow)
        #expect(state.navigationDirection == .instant)
    }

    @Test @MainActor
    func scanResultFlowOpensFromHistoryAndReturnsToHistoryTab() throws {
        let state = try makeState(now: fixedNow)
        state.startDeepScan()
        try state.cancelActiveScan(now: fixedNow, fileCount: 423)
        let record = try #require(state.historySnapshot.records.first)

        state.showScanResult(record)
        #expect(state.page == .scanResult)
        #expect(state.displayedRecord == record)
        #expect(state.navigationDirection == .forward)

        state.isShowingScanDetails = true
        state.closeScanResult()
        #expect(state.page == .scanHistory)
        #expect(state.navigationDirection == .backward)
        #expect(state.isShowingScanDetails == false)
        // 关闭结果页时保留记录，以保证退场动画正常渲染
        #expect(state.displayedRecord == record)
    }

    @Test @MainActor
    func scanDurationIsRandomWithinTwoToFourHours() throws {
        let state = try makeState(now: fixedNow)
        state.startScan(kind: .deep)
        try state.cancelActiveScan(now: fixedNow, fileCount: 423)
        let duration = try #require(state.historySnapshot.records.first?.duration)
        #expect((7200.0...14400.0).contains(duration))
    }

    @Test @MainActor
    func deepScanSimulationCompletesAndSwitchesToHistory() async throws {
        let state = try makeState(now: fixedNow)
        state.scanSimulationSteps = 2
        state.scanSimulationStepInterval = .milliseconds(1)

        state.startDeepScan()
        try await waitUpTo(seconds: 3) { !state.isScanRunning }

        #expect(!state.isScanRunning)
        #expect(state.page == .scanHistory)
        #expect(state.historySnapshot.records.first?.status == .completedNoThreats)
        #expect(state.deepScanProgressFraction == nil)
    }

    @Test @MainActor
    func returningToScanCenterKeepsScanRunningWithProgress() async throws {
        let state = try makeState(now: fixedNow)
        state.scanSimulationSteps = 4
        state.scanSimulationStepInterval = .milliseconds(10)

        state.startDeepScan()
        state.showScanCenter() // 返回扫描中心，扫描继续
        try await waitUpTo(seconds: 2) { state.scanProgress > 0 }

        #expect(state.isScanRunning)
        #expect(state.scanProgress > 0)
        #expect(state.deepScanProgressFraction != nil)
        let pausedProgress = state.scanProgress

        state.deepScanTapped() // 重新进入进度页，不重置进度
        #expect(state.page == .deepScanProgress)
        #expect(state.scanProgress >= pausedProgress)

        try state.cancelActiveScan(now: fixedNow) // 清理：取消扫描
        #expect(!state.isScanRunning)
        #expect(state.page == .scanCenter)
        #expect(state.deepScanProgressFraction == nil)
    }

    @Test @MainActor
    func completingScanInBackgroundDoesNotForceNavigation() async throws {
        let state = try makeState(now: fixedNow)
        state.scanSimulationSteps = 2
        state.scanSimulationStepInterval = .milliseconds(1)

        state.startDeepScan()
        state.showScanCenter()
        try await waitUpTo(seconds: 3) { !state.isScanRunning }

        #expect(!state.isScanRunning)
        #expect(state.page == .scanCenter) // 不强制跳转到历史页
        #expect(state.historySnapshot.records.first?.status == .completedNoThreats)
        #expect(state.deepScanProgressFraction == nil)
    }

    private var fixedNow: Date {
        Date(timeIntervalSince1970: 1_781_621_000)
    }

    @MainActor
    private func waitUpTo(seconds: Double, until condition: () -> Bool) async throws {
        let deadline = Date().addingTimeInterval(seconds)
        while !condition() && Date() < deadline {
            try await Task.sleep(for: .milliseconds(10))
        }
    }

    @MainActor
    private func makeState(now: Date) throws -> AppState {
        try AppState(
            historyStore: HistoryStore(
                fileURL: URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent(UUID().uuidString)
                    .appendingPathExtension("json"),
                now: { now }
            ),
            launchedAt: now
        )
    }
}
