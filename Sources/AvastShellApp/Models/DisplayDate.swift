import Foundation

enum DisplayDate {
    static func string(_ date: Date, relativeTo now: Date = Date(), calendar: Calendar = .current) -> String {
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: now)).day
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = Locale(identifier: "zh_CN")
        switch days {
        case 0: formatter.dateFormat = "'今天' HH:mm"
        case 1: formatter.dateFormat = "'昨天' HH:mm"
        case 2: formatter.dateFormat = "'前天' HH:mm"
        default:
            formatter.dateFormat = calendar.component(.year, from: date) == calendar.component(.year, from: now)
                ? "M月d日 HH:mm" : "yyyy年M月d日 HH:mm"
        }
        return formatter.string(from: date)
    }
}
