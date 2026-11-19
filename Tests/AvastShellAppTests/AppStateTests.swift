import Foundation
import Testing
@testable import AvastShellApp

struct AppStateTests {
    @Test
    func homeActionNavigatesToScanCenter() throws {
        let state = try makeState(now: fixedNow)

        state.showScanCenter()

        #expect(state.page == .scanCenter)
        #expect(state.navigationDirection == .forward)
    }

    @Test
    func returningHomeFromScanCenterMarksNavigationAsBackward() throws {
        let state = try makeState(now: fixedNow)

        state.showScanCenter()
        state.showHome()

        #expect(state.page == .home)
        #expect(state.navigationDirection == .backward)
    }

    @Test
    func openingScanHistoryMarksNavigationAsForward() throws {
        let state = try makeState(now: fixedNow)

        state.showScanHistory()

        #expect(state.page == .scanHistory)
        #expect(state.navigationDirection == .forward)
    }

    @Test
    func startingDeepScanSwitchesToProgressPageAndResetsProgress() throws {
        let state = try makeState(now: fixedNow)
        state.scanProgress = 57

        state.startDeepScan()

        #expect(state.page == .deepScanProgress)
        #expect(state.scanProgress == 0)
    }

    @Test
    func cancelingActiveScanCreatesCanceledHistoryEntryAndReturnsToScanCenter() throws {
        let state = try makeState(now: fixedNow)

        state.startDeepScan()
        try state.cancelActiveScan(now: fixedNow, fileCount: 33_000_000)

        #expect(state.page == .scanCenter)
        #expect(state.navigationDirection == .backward)
        #expect(state.historySnapshot.records.first?.status == .canceledNoThreats)
        #expect(state.historySnapshot.records.first?.kind == .deep)
    }

    @Test
    func completingActiveScanCreatesSuccessfulEntryAndSwitchesToHistory() throws {
        let state = try makeState(now: fixedNow)

        state.startDeepScan()
        try state.completeActiveScan(now: fixedNow, fileCount: 66_000_000)

        #expect(state.page == .scanHistory)
        #expect(state.historySnapshot.records.first?.status == .completedNoThreats)
        #expect(state.historySnapshot.records.first?.kind == .deep)
        #expect(state.historySnapshot.records.first?.fileCount == 66_000_000)
    }

    @Test
    func smartScanKeepsItsTypeWhenCompleted() throws {
        let state = try makeState(now: fixedNow)
        state.startScan(kind: .smart)
        #expect(state.scanTitle == "智能扫描")
        try state.completeActiveScan(now: fixedNow, fileCount: 42_000_000)
        #expect(state.historySnapshot.records.first?.kind == .smart)
        #expect(state.page == .scanHistory)
    }

    @Test
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

    private var fixedNow: Date {
        Date(timeIntervalSince1970: 1_781_621_000)
    }

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
