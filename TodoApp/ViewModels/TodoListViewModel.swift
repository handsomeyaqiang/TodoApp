import SwiftData
import Foundation

@MainActor
@Observable
final class TodoListViewModel {
    var searchText: String = ""
    var selectedTags: Set<PersistentIdentifier> = []
    var sortOrder: SortOrder = .byCreatedDate
    var showCompleted: Bool = true

    enum SortOrder: String, CaseIterable {
        case byCreatedDate = "创建时间"
        case byDueDate = "截止日期"
        case byPriority = "优先级"
        case byTitle = "标题"
    }

    func filteredItems(_ allItems: [TodoItem]) -> [TodoItem] {
        var items = allItems

        if !showCompleted {
            items = items.filter { !$0.isCompleted }
        }

        if !selectedTags.isEmpty {
            items = items.filter { item in
                let tagIDs = Set(item.tags.map { $0.persistentModelID })
                return !selectedTags.isDisjoint(with: tagIDs)
            }
        }

        if !searchText.isEmpty {
            let query = searchText.lowercased()
            items = items.filter {
                $0.title.lowercased().contains(query) ||
                $0.notes.lowercased().contains(query) ||
                $0.tags.contains { $0.name.lowercased().contains(query) }
            }
        }

        switch sortOrder {
        case .byCreatedDate:
            items.sort { $0.createdAt > $1.createdAt }
        case .byDueDate:
            items.sort {
                switch ($0.dueDate, $1.dueDate) {
                case (.some(let a), .some(let b)): return a < b
                case (.some, .none): return true
                case (.none, .some): return false
                case (.none, .none): return $0.createdAt > $1.createdAt
                }
            }
        case .byPriority:
            items.sort { $0.priorityRaw > $1.priorityRaw }
        case .byTitle:
            items.sort { $0.title < $1.title }
        }

        return items
    }

    func toggleTag(_ tag: Tag) {
        let id = tag.persistentModelID
        if selectedTags.contains(id) {
            selectedTags.remove(id)
        } else {
            selectedTags.insert(id)
        }
    }

    func isTagSelected(_ tag: Tag) -> Bool {
        selectedTags.contains(tag.persistentModelID)
    }

    func clearTagFilter() {
        selectedTags.removeAll()
    }

    func toggleCompletion(_ item: TodoItem) {
        item.isCompleted.toggle()
        item.updatedAt = .now
    }

    func deleteItems(_ items: [TodoItem], context: ModelContext) {
        let ids = items.compactMap { $0.notificationID }
        NotificationService.shared.cancelNotifications(ids: ids)
        items.forEach { context.delete($0) }
    }
}
