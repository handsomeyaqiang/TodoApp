import SwiftData
import SwiftUI
import Foundation

@Model
final class Tag {
    var id: UUID
    var name: String
    var colorHex: String
    var createdAt: Date

    @Relationship(deleteRule: .nullify)
    var todoItems: [TodoItem]

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    init(name: String, colorHex: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.colorHex = colorHex
        self.createdAt = .now
        self.todoItems = []
    }
}
