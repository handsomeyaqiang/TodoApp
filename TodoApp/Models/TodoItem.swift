import SwiftData
import SwiftUI
import Foundation

@Model
final class TodoItem {
    var id: UUID
    var title: String
    var notes: String
    var isCompleted: Bool
    var priorityRaw: Int
    var dueDate: Date?
    var createdAt: Date
    var updatedAt: Date

    var reminderDate: Date?
    var notificationID: String?

    @Relationship(deleteRule: .nullify, inverse: \Tag.todoItems)
    var tags: [Tag]

    var priority: Priority {
        get { Priority(rawValue: priorityRaw) ?? .medium }
        set { priorityRaw = newValue.rawValue }
    }

    enum Priority: Int, Codable, CaseIterable {
        case low = 0
        case medium = 1
        case high = 2

        var label: String {
            switch self {
            case .low: return "低"
            case .medium: return "中"
            case .high: return "高"
            }
        }

        var color: Color {
            switch self {
            case .low: return .green
            case .medium: return .orange
            case .high: return .red
            }
        }

        var systemImage: String {
            switch self {
            case .low: return "arrow.down.circle"
            case .medium: return "minus.circle"
            case .high: return "exclamationmark.circle"
            }
        }
    }

    init(title: String, notes: String = "", priority: Priority = .medium, dueDate: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.notes = notes
        self.isCompleted = false
        self.priorityRaw = priority.rawValue
        self.dueDate = dueDate
        self.createdAt = .now
        self.updatedAt = .now
        self.tags = []
    }
}
