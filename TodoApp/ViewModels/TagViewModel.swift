import SwiftData
import SwiftUI
import Foundation

@MainActor
@Observable
final class TagViewModel {
    var newTagName: String = ""
    var newTagColorHex: String = "#007AFF"
    var errorMessage: String?

    var newTagColor: Color {
        get { Color(hex: newTagColorHex) ?? .blue }
        set { newTagColorHex = newValue.toHex() }
    }

    func createTag(context: ModelContext, allTags: [Tag]) {
        let trimmed = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let isDuplicate = allTags.contains { $0.name.lowercased() == trimmed.lowercased() }
        if isDuplicate {
            errorMessage = "标签「\(trimmed)」已存在"
            return
        }

        let tag = Tag(name: trimmed, colorHex: newTagColorHex)
        context.insert(tag)
        newTagName = ""
        newTagColorHex = Color.tagColors.randomElement()?.toHex() ?? "#007AFF"
        errorMessage = nil
    }

    func deleteTag(_ tag: Tag, context: ModelContext) {
        context.delete(tag)
    }

    func renameTag(_ tag: Tag, to name: String, allTags: [Tag]) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let isDuplicate = allTags.contains { $0.id != tag.id && $0.name.lowercased() == trimmed.lowercased() }
        guard !isDuplicate else { return }
        tag.name = trimmed
    }
}
