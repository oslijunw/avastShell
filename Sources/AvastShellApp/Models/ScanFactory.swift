import Foundation

enum ScanFactory {
    static let fileCountRange = 20_000_000...90_000_000

    static func makeCompletedRecord(
        kind: ScanRecord.Kind,
        now: Date,
        fileCount: Int? = nil
    ) -> ScanRecord {
        ScanRecord(
            id: UUID(),
            kind: kind,
            status: .completedNoThreats,
            createdAt: now,
            fileCount: fileCount ?? Int.random(in: fileCountRange)
        )
    }

    static func makeCanceledRecord(
        kind: ScanRecord.Kind,
        now: Date,
        fileCount: Int? = nil
    ) -> ScanRecord {
        ScanRecord(
            id: UUID(),
            kind: kind,
            status: .canceledNoThreats,
            createdAt: now,
            fileCount: fileCount ?? Int.random(in: fileCountRange)
        )
    }

    static func makeWeeklyAutoRecord(
        now: Date,
        fileCount: Int? = nil
    ) -> ScanRecord {
        makeCompletedRecord(kind: .weeklyAutomatic, now: now, fileCount: fileCount)
    }
}
