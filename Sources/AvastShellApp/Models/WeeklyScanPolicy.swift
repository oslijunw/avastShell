import Foundation

enum WeeklyScanPolicy {
    private static let weeklyInterval: TimeInterval = 7 * 24 * 60 * 60

    static func shouldGenerateWeeklyScan(lastGeneratedAt: Date?, now: Date) -> Bool {
        guard let lastGeneratedAt else {
            return true
        }

        return now.timeIntervalSince(lastGeneratedAt) >= weeklyInterval
    }
}
