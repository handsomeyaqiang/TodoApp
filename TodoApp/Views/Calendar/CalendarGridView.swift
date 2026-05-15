import SwiftUI

struct CalendarGridView: View {
    let displayedMonth: Date
    let selectedDate: Date
    let itemsForDate: (Date) -> [TodoItem]
    let onSelectDate: (Date) -> Void

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    private let weekdaySymbols = ["日", "一", "二", "三", "四", "五", "六"]

    var body: some View {
        VStack(spacing: 0) {
            // 星期表头
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 6)

            // 日期网格
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(Array(calendarDays.enumerated()), id: \.offset) { index, date in
                    if let date {
                        DayCell(
                            date: date,
                            isToday: calendar.isDateInToday(date),
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isCurrentMonth: calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month),
                            dots: priorityDots(for: date)
                        )
                        .onTapGesture { onSelectDate(date) }
                        .id(date)
                    } else {
                        Color.clear.frame(height: 44)
                    }
                }
            }
        }
    }

    private var calendarDays: [Date?] {
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)),
              let monthRange = calendar.range(of: .day, in: .month, for: monthStart)
        else { return [] }

        let firstWeekday = (calendar.component(.weekday, from: monthStart) - 1 + 7) % 7
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)

        for day in monthRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        // 补齐最后一行
        let remainder = days.count % 7
        if remainder > 0 { days += Array(repeating: nil, count: 7 - remainder) }
        return days
    }

    private func priorityDots(for date: Date) -> [Color] {
        let items = itemsForDate(date)
        guard !items.isEmpty else { return [] }
        return Array(
            items.prefix(3).map { $0.priority.color }
        )
    }
}

private struct DayCell: View {
    let date: Date
    let isToday: Bool
    let isSelected: Bool
    let isCurrentMonth: Bool
    let dots: [Color]

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                if isSelected {
                    Circle().fill(Color.blue).frame(width: 30, height: 30)
                } else if isToday {
                    Circle().strokeBorder(Color.blue, lineWidth: 1.5).frame(width: 30, height: 30)
                }
                Text(dayNumber)
                    .font(.system(size: 14, weight: isToday ? .semibold : .regular))
                    .foregroundStyle(textColor)
            }
            // 优先级圆点
            HStack(spacing: 3) {
                ForEach(Array(dots.enumerated()), id: \.offset) { _, color in
                    Circle().fill(color).frame(width: 5, height: 5)
                }
            }
            .frame(height: 6)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
    }

    private var dayNumber: String {
        let day = Calendar.current.component(.day, from: date)
        return "\(day)"
    }

    private var textColor: Color {
        if isSelected { return .white }
        if !isCurrentMonth { return .secondary.opacity(0.4) }
        return .primary
    }
}
