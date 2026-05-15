import Foundation

extension DateFormatter {
    static let todoDisplay: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
}

extension Date {
    var isOverdue: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let dueDay = calendar.startOfDay(for: self)
        return dueDay < today
    }

    var todoDisplayString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) { return "今天" }
        if calendar.isDateInTomorrow(self) { return "明天" }
        if calendar.isDateInYesterday(self) { return "昨天" }
        return DateFormatter.todoDisplay.string(from: self)
    }
}
