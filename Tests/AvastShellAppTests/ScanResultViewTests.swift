import Foundation
import Testing
@testable import AvastShellApp

struct ScanResultViewTests {
    @Test
    func durationTextFormatsHoursMinutesSeconds() {
        #expect(ScanResultView.durationText(9526) == "2小时38分钟46秒钟")
        #expect(ScanResultView.durationText(125) == "2分钟5秒钟")
        #expect(ScanResultView.durationText(59) == "59秒钟")
    }
}
