import SwiftUI
import SwiftData

struct TodoEditView: View {
    var existingItem: TodoItem?
    var prefillDueDate: Date?
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @State private var viewModel = TodoDetailViewModel()

    init(existingItem: TodoItem? = nil, prefillDueDate: Date? = nil) {
        self.existingItem = existingItem
        self.prefillDueDate = prefillDueDate
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("事项标题") {
                    TextField("输入待办事项标题", text: $viewModel.title)
                }

                Section("优先级") {
                    Picker("优先级", selection: $viewModel.priority) {
                        ForEach(TodoItem.Priority.allCases, id: \.self) { p in
                            Label(p.label, systemImage: p.systemImage)
                                .foregroundStyle(p.color)
                                .tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("截止日期") {
                    Toggle("设置截止日期", isOn: $viewModel.hasDueDate)
                    if viewModel.hasDueDate {
                        DatePicker("截止日期",
                                   selection: $viewModel.dueDate,
                                   displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .onChange(of: viewModel.dueDate) { _, newDate in
                                if viewModel.hasReminder {
                                    viewModel.reminderDate = Calendar.current.date(
                                        bySettingHour: 9, minute: 0, second: 0, of: newDate
                                    ) ?? newDate
                                }
                            }
                    }
                }

                Section("提醒") {
                    Toggle("设置提醒", isOn: $viewModel.hasReminder)
                        .onChange(of: viewModel.hasReminder) { _, on in
                            if on {
                                viewModel.reminderDate = viewModel.defaultReminderDate()
                            }
                        }
                    if viewModel.hasReminder {
                        DatePicker("提醒时间",
                                   selection: $viewModel.reminderDate,
                                   in: Date()...,
                                   displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(.compact)
                        if viewModel.reminderDate <= Date() {
                            Label("提醒时间已过，通知将不会发出", systemImage: "exclamationmark.triangle")
                                .font(.caption)
                                .foregroundStyle(.orange)
                        }
                    }
                }

                Section("标签") {
                    TagPickerView(allTags: allTags, selectedTags: $viewModel.selectedTags)
                }

                Section("备注") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle(existingItem == nil ? "新建事项" : "编辑事项")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let item = existingItem {
                    viewModel.populate(from: item)
                } else if let prefill = prefillDueDate {
                    viewModel.hasDueDate = true
                    viewModel.dueDate = prefill
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        viewModel.save(existingItem: existingItem, context: modelContext)
                        dismiss()
                    }
                    .disabled(!viewModel.isValid)
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
