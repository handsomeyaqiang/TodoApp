import SwiftUI

private let detailTimestampFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .medium
    return f
}()

struct TodoDetailView: View {
    let item: TodoItem
    @State private var showingEdit = false

    var body: some View {
        List {
            Section {
                HStack(spacing: 8) {
                    Image(systemName: item.priority.systemImage)
                        .foregroundStyle(item.priority.color)
                    Text(item.priority.label + "优先级")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                    if item.isCompleted {
                        Label("已完成", systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                    }
                }
            }

            if !item.notes.isEmpty {
                Section("备注") {
                    Text(item.notes)
                        .font(.body)
                }
            }

            if let dueDate = item.dueDate {
                Section("截止日期") {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(dueDate.isOverdue && !item.isCompleted ? .red : .blue)
                        Text(dueDate.todoDisplayString)
                        if dueDate.isOverdue && !item.isCompleted {
                            Spacer()
                            Text("已逾期")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
            }

            if let reminderDate = item.reminderDate {
                Section("提醒") {
                    HStack {
                        Image(systemName: reminderDate.isOverdue ? "bell.slash" : "bell.fill")
                            .foregroundStyle(reminderDate.isOverdue ? Color.secondary : Color.orange)
                        Text(detailTimestampFormatter.string(from: reminderDate))
                            .font(.subheadline)
                        Spacer()
                        Text(reminderDate.isOverdue ? "已触发" : "待提醒")
                            .font(.caption)
                            .foregroundStyle(reminderDate.isOverdue ? Color.secondary : Color.orange)
                    }
                }
            }

            if !item.tags.isEmpty {
                Section("标签") {
                    FlowLayout(spacing: 8) {
                        ForEach(item.tags) { tag in
                            TagChipView(tag: tag)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("时间信息") {
                LabeledContent("创建时间") {
                    Text(detailTimestampFormatter.string(from: item.createdAt))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                LabeledContent("最后更新") {
                    Text(detailTimestampFormatter.string(from: item.updatedAt))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("编辑") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            TodoEditView(existingItem: item)
        }
    }
}
