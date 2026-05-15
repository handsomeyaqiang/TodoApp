import SwiftData
import SwiftUI
import Foundation

@MainActor
@Observable
final class TodoDetailViewModel {
    var title: String = ""
    var notes: String = ""
    var priorityRaw: Int = TodoItem.Priority.medium.rawValue
    var dueDate: Date = Date()
    var hasDueDate: Bool = false
    var selectedTags: [Tag] = []
    var reminderDate: Date = Date()
    var hasReminder: Bool = false

    var priority: TodoItem.Priority {
        get { TodoItem.Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func populate(from item: TodoItem) {
        title = item.title
        notes = item.notes
        priorityRaw = item.priorityRaw
        if let date = item.dueDate {
            dueDate = date
            hasDueDate = true
        } else {
            dueDate = Date()
            hasDueDate = false
        }
        if let reminder = item.reminderDate {
            reminderDate = reminder
            hasReminder = true
        } else {
            reminderDate = defaultReminderDate()
            hasReminder = false
        }
        selectedTags = item.tags
    }

    func save(existingItem: TodoItem?, context: ModelContext) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        let item: TodoItem
        if let existing = existingItem {
            existing.title = trimmedTitle
            existing.notes = notes
            existing.priorityRaw = priorityRaw
            existing.dueDate = hasDueDate ? dueDate : nil
            existing.tags = selectedTags
            existing.updatedAt = .now
            item = existing
        } else {
            let newItem = TodoItem(
                title: trimmedTitle,
                notes: notes,
                priority: priority,
                dueDate: hasDueDate ? dueDate : nil
            )
            newItem.tags = selectedTags
            context.insert(newItem)
            item = newItem
        }

        // 处理提醒通知
        if hasReminder {
            item.reminderDate = reminderDate
            Task {
                let newID = await NotificationService.shared.scheduleNotification(for: item)
                item.notificationID = newID
            }
        } else {
            if let oldID = item.notificationID {
                NotificationService.shared.cancelNotification(id: oldID)
                item.notificationID = nil
            }
            item.reminderDate = nil
        }
    }

    func defaultReminderDate() -> Date {
        if hasDueDate {
            // 截止日期当天 09:00
            return Calendar.current.date(
                bySettingHour: 9, minute: 0, second: 0, of: dueDate
            ) ?? dueDate
        }
        // 当前时间 + 1 小时
        return Date().addingTimeInterval(3600)
    }
}
