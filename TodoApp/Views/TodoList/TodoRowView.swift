import SwiftUI

struct TodoRowView: View {
    let item: TodoItem
    let onToggle: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: item.priority.systemImage)
                        .font(.caption)
                        .foregroundStyle(item.priority.color)

                    Text(item.title)
                        .font(.body)
                        .strikethrough(item.isCompleted)
                        .foregroundStyle(item.isCompleted ? .secondary : .primary)
                        .lineLimit(2)

                    if item.reminderDate != nil {
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                }

                if let dueDate = item.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(dueDate.todoDisplayString)
                            .font(.caption)
                    }
                    .foregroundStyle(dueDate.isOverdue && !item.isCompleted ? .red : .secondary)
                }

                if !item.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 4) {
                            ForEach(item.tags.prefix(3)) { tag in
                                TagChipView(tag: tag, isSmall: true)
                            }
                            if item.tags.count > 3 {
                                Text("+\(item.tags.count - 3)")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
