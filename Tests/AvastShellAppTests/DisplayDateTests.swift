import Foundation
import Testing
@testable import AvastShellApp

struct DisplayDateTests {
    @Test
    func labelsPreviousDaysAndCrossMidnightUpdateCorrectly() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let now = calendar.date(from: DateComponents(year: 2026, month: 11, day: 10, hour: 0, minute: 10))!
        #expect(DisplayDate.string(now, relativeTo: now, calendar: calendar) == "今天 00:10")
        #expect(DisplayDate.string(now.addingTimeInterval(-1800), relativeTo: now, calendar: calendar) == "昨天 23:40")
        #expect(DisplayDate.string(now.addingTimeInterval(-172_800), relativeTo: now, calendar: calendar) == "前天 00:10")
        #expect(DisplayDate.string(now.addingTimeInterval(-259_200), relativeTo: now, calendar: calendar) == "11月7日 00:10")
    }
}
