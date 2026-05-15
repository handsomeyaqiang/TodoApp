import SwiftUI
import SwiftData
import Charts

struct OverviewView: View {
    @Query private var allItems: [TodoItem]

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    statsGrid
                    prioritySection
                    trendSection
                    upcomingSection
                }
                .padding()
            }
            .navigationTitle("概览")
        }
    }

    // MARK: - 统计卡片

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(
                title: "全部事项",
                value: "\(allItems.count)",
                icon: "checklist",
                color: .blue
            )
            StatCard(
                title: "今日到期",
                value: "\(todayDueCount)",
                icon: "calendar.circle",
                color: .orange
            )
            StatCard(
                title: "已完成",
                value: "\(completedCount)",
                subtitle: completionRate,
                icon: "checkmark.circle.fill",
                color: .green
            )
            StatCard(
                title: "逾期未完成",
                value: "\(overdueCount)",
                icon: "exclamationmark.circle.fill",
                color: overdueCount > 0 ? .red : .secondary
            )
        }
    }

    // MARK: - 优先级分布

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("优先级分布")
                .font(.headline)

            let pending = allItems.filter { !$0.isCompleted }
            let total = pending.count

            if total == 0 {
                Text("暂无待完成事项")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                ForEach(TodoItem.Priority.allCases.reversed(), id: \.self) { p in
                    let count = pending.filter { $0.priority == p }.count
                    PriorityBar(
                        label: p.label,
                        count: count,
                        total: total,
                        color: p.color
                    )
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 7 天完成趋势

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("近 7 天完成趋势")
                .font(.headline)

            let data = last7DaysData()
            if data.allSatisfy({ $0.count == 0 }) {
                Text("近 7 天暂无完成记录")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8)
            } else {
                Chart(data) { entry in
                    BarMark(
                        x: .value("日期", entry.label),
                        y: .value("完成数", entry.count)
                    )
                    .foregroundStyle(Color.green.gradient)
                    .cornerRadius(4)
                }
                .frame(height: 120)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                        AxisValueLabel()
                            .font(.caption2)
                        AxisGridLine()
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - 即将到期

    private var upcomingSection: some View {
        let items = upcomingItems()
        return Group {
            if !items.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("未来 3 天到期")
                        .font(.headline)
                    ForEach(items) { item in
                        NavigationLink {
                            TodoDetailView(item: item)
                        } label: {
                            UpcomingItemRow(item: item)
                        }
                        .buttonStyle(.plain)
                        if item.id != items.last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    // MARK: - 计算属性

    private var todayDueCount: Int {
        allItems.filter { item in
            guard let d = item.dueDate else { return false }
            return calendar.isDateInToday(d) && !item.isCompleted
        }.count
    }

    private var completedCount: Int { allItems.filter { $0.isCompleted }.count }

    private var completionRate: String {
        guard !allItems.isEmpty else { return "0%" }
        let rate = Double(completedCount) / Double(allItems.count) * 100
        return String(format: "%.0f%%", rate)
    }

    private var overdueCount: Int {
        allItems.filter { item in
            guard let d = item.dueDate else { return false }
            return d.isOverdue && !item.isCompleted
        }.count
    }

    private func last7DaysData() -> [DayEntry] {
        (0..<7).reversed().map { offset -> DayEntry in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let count = allItems.filter { item in
                item.isCompleted && calendar.isDate(item.updatedAt, inSameDayAs: date)
            }.count
            let label = offset == 0 ? "今" : "\(calendar.component(.day, from: date))日"
            return DayEntry(label: label, count: count)
        }
    }

    private func upcomingItems() -> [TodoItem] {
        let now = Date()
        guard let threeDaysLater = calendar.date(byAdding: .day, value: 3, to: now) else { return [] }
        return allItems.filter { item in
            guard let d = item.dueDate, !item.isCompleted else { return false }
            return d >= now && d <= threeDaysLater
        }
        .sorted { ($0.dueDate ?? .now) < ($1.dueDate ?? .now) }
    }
}

// MARK: - 子组件

private struct StatCard: View {
    let title: String
    let value: String
    var subtitle: String? = nil
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
                Spacer()
            }
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let sub = subtitle {
                    Text(sub)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(color)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct PriorityBar: View {
    let label: String
    let count: Int
    let total: Int
    let color: Color

    var ratio: Double { total > 0 ? Double(count) / Double(total) : 0 }

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.15)).frame(height: 8)
                    Capsule().fill(color)
                        .frame(width: max(geo.size.width * ratio, ratio > 0 ? 6 : 0), height: 8)
                }
            }
            .frame(height: 8)
            Text("\(count)")
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 24, alignment: .trailing)
        }
    }
}

private struct UpcomingItemRow: View {
    let item: TodoItem

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(item.priority.color)
                .frame(width: 8, height: 8)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline)
                    .lineLimit(1)
                if let d = item.dueDate {
                    Text(d.todoDisplayString)
                        .font(.caption)
                        .foregroundStyle(d.isOverdue ? .red : .secondary)
                }
            }
            Spacer()
            if !item.tags.isEmpty {
                TagChipView(tag: item.tags[0], isSmall: true)
            }
            Image(systemName: "chevron.right")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

private struct DayEntry: Identifiable {
    let id = UUID()
    let label: String
    let count: Int
}

#Preview {
    OverviewView()
        .modelContainer(PreviewData.container)
}
