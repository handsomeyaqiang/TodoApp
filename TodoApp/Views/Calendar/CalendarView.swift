import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allItems: [TodoItem]
    @State private var displayedMonth: Date = Calendar.current.startOfMonth(for: .now)
    @State private var selectedDate: Date = .now
    @State private var showingAddItem = false

    private let calendar = Calendar.current

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                monthNavigationBar
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                CalendarGridView(
                    displayedMonth: displayedMonth,
                    selectedDate: selectedDate,
                    itemsForDate: { itemsFor(date: $0) },
                    onSelectDate: { selectedDate = $0 }
                )
                .padding(.horizontal, 8)

                Divider().padding(.top, 8)

                selectedDayHeader
                    .padding(.horizontal)
                    .padding(.vertical, 8)

                let dayItems = itemsFor(date: selectedDate)
                if dayItems.isEmpty {
                    ContentUnavailableView(
                        "当日暂无事项",
                        systemImage: "calendar.badge.plus",
                        description: Text("点击右上角 + 添加事项")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(dayItems) { item in
                            NavigationLink {
                                TodoDetailView(item: item)
                            } label: {
                                TodoRowView(item: item) {
                                    item.isCompleted.toggle()
                                    item.updatedAt = .now
                                }
                            }
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    if let id = item.notificationID {
                                        NotificationService.shared.cancelNotification(id: id)
                                    }
                                    modelContext.delete(item)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("日历")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddItem = true } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("今天") {
                        withAnimation {
                            displayedMonth = calendar.startOfMonth(for: .now)
                            selectedDate = .now
                        }
                    }
                    .disabled(calendar.isDate(displayedMonth, equalTo: calendar.startOfMonth(for: .now), toGranularity: .month))
                }
            }
            .sheet(isPresented: $showingAddItem) {
                TodoEditView(prefillDueDate: selectedDate)
            }
        }
    }

    private var monthNavigationBar: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .fontWeight(.semibold)
            }

            Spacer()

            Text(displayedMonth, format: .dateTime.year().month(.wide))
                .font(.headline)

            Spacer()

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .fontWeight(.semibold)
            }
        }
    }

    private var selectedDayHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(selectedDate, format: .dateTime.month(.wide).day())
                    .font(.subheadline.weight(.semibold))
                let count = itemsFor(date: selectedDate).count
                Text(count == 0 ? "无事项" : "\(count) 个事项")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
    }

    private func itemsFor(date: Date) -> [TodoItem] {
        allItems.filter { item in
            guard let dueDate = item.dueDate else { return false }
            return calendar.isDate(dueDate, inSameDayAs: date)
        }
        .sorted { $0.priorityRaw > $1.priorityRaw }
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps) ?? date
    }
}

#Preview {
    CalendarView()
        .modelContainer(PreviewData.container)
}
