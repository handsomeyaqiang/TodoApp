import SwiftUI
import SwiftData

struct TagPickerView: View {
    let allTags: [Tag]
    @Binding var selectedTags: [Tag]
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddTag = false
    @State private var newTagName = ""
    @State private var newTagColorHex = "#007AFF"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if allTags.isEmpty {
                Text("暂无标签，点击下方添加")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(allTags) { tag in
                        Button {
                            toggleTag(tag)
                        } label: {
                            TagChipView(tag: tag, isSelected: selectedTags.contains { $0.id == tag.id })
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button {
                showingAddTag = true
            } label: {
                Label("添加新标签", systemImage: "plus.circle")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
        }
        .sheet(isPresented: $showingAddTag) {
            QuickAddTagSheet(isPresented: $showingAddTag)
        }
    }

    private func toggleTag(_ tag: Tag) {
        if let idx = selectedTags.firstIndex(where: { $0.id == tag.id }) {
            selectedTags.remove(at: idx)
        } else {
            selectedTags.append(tag)
        }
    }
}

struct QuickAddTagSheet: View {
    @Binding var isPresented: Bool
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @State private var name = ""
    @State private var colorHex = "#007AFF"
    @State private var errorMessage: String?

    var selectedColor: Binding<Color> {
        Binding(
            get: { Color(hex: colorHex) ?? .blue },
            set: { colorHex = $0.toHex() }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("标签名称") {
                    TextField("输入标签名称", text: $name)
                }
                Section("标签颜色") {
                    ColorPicker("选择颜色", selection: selectedColor)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Color.tagColors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 28, height: 28)
                                    .overlay {
                                        if color.toHex() == colorHex {
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .onTapGesture { colorHex = color.toHex() }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                if let msg = errorMessage {
                    Section {
                        Text(msg).foregroundStyle(.red).font(.caption)
                    }
                }
            }
            .navigationTitle("新建标签")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { isPresented = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") { createTag() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func createTag() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if allTags.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            errorMessage = "标签「\(trimmed)」已存在"
            return
        }
        context.insert(Tag(name: trimmed, colorHex: colorHex))
        isPresented = false
    }

    private var context: ModelContext { modelContext }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 0
        var height: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if rowWidth + size.width + (rowWidth > 0 ? spacing : 0) > width {
                height += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                if rowWidth > 0 { rowWidth += spacing }
                rowWidth += size.width
                rowHeight = max(rowHeight, size.height)
            }
        }
        height += rowHeight
        return CGSize(width: width, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX && x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
