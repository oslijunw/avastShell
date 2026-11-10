import Foundation
import Testing
@testable import AvastShellApp

@Test
func generatesWeeklyScanWhenNoPreviousRunExists() {
    let now = Date(timeIntervalSince1970: 1_781_621_000)
    let lastGeneratedAt: Date? = nil

    #expect(WeeklyScanPolicy.shouldGenerateWeeklyScan(lastGeneratedAt: lastGeneratedAt, now: now))
}

@Test
func doesNotGenerateWeeklyScanBeforeSevenDays() {
    let now = Date(timeIntervalSince1970: 1_781_621_000)
    let lastGeneratedAt = now.addingTimeInterval(-(6 * 24 * 60 * 60))

    #expect(!WeeklyScanPolicy.shouldGenerateWeeklyScan(lastGeneratedAt: lastGeneratedAt, now: now))
}

@Test
func generatesWeeklyScanAtSevenDaysOrLater() {
    let now = Date(timeIntervalSince1970: 1_781_621_000)
    let lastGeneratedAt = now.addingTimeInterval(-(7 * 24 * 60 * 60))

    #expect(WeeklyScanPolicy.shouldGenerateWeeklyScan(lastGeneratedAt: lastGeneratedAt, now: now))
}

@Test
func generatedWeeklyScanUsesTensOfMillionsFileCounts() {
    let now = Date(timeIntervalSince1970: 1_781_621_000)
    let record = ScanFactory.makeWeeklyAutoRecord(now: now)

    #expect(record.kind == .weeklyAutomatic)
    #expect(record.status == .completedNoThreats)
    #expect(record.fileCount >= 20_000_000)
    #expect(record.fileCount <= 90_000_000)
}
