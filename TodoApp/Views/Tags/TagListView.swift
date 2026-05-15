import SwiftUI
import SwiftData

struct TagListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @State private var viewModel = TagViewModel()
    @State private var showingAddTag = false
    @State private var editingTag: Tag?
    @State private var editingName = ""

    var body: some View {
        List {
            if allTags.isEmpty {
                ContentUnavailableView(
                    "暂无标签",
                    systemImage: "tag.slash",
                    description: Text("点击右上角 + 创建第一个标签")
                )
            } else {
                ForEach(allTags) { tag in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(tag.color)
                            .frame(width: 12, height: 12)
                        Text(tag.name)
                            .font(.body)
                        Spacer()
                        Text("\(tag.todoItems.count) 个事项")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingTag = tag
                        editingName = tag.name
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.deleteTag(tag, context: modelContext)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("标签管理")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAddTag = true } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddTag) {
            AddTagSheet(isPresented: $showingAddTag, allTags: allTags)
        }
        .sheet(item: $editingTag) { tag in
            EditTagSheet(tag: tag, allTags: allTags)
        }
    }
}

struct AddTagSheet: View {
    @Binding var isPresented: Bool
    let allTags: [Tag]
    @Environment(\.modelContext) private var modelContext
    @State private var name = ""
    @State private var colorHex = "#007AFF"
    @State private var errorMessage: String?

    var selectedColor: Binding<Color> {
        Binding(get: { Color(hex: colorHex) ?? .blue }, set: { colorHex = $0.toHex() })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("标签名称") {
                    TextField("输入名称", text: $name)
                }
                Section("颜色") {
                    ColorPicker("自定义颜色", selection: selectedColor)
                    presetColorsRow
                }
                if let msg = errorMessage {
                    Section { Text(msg).foregroundStyle(.red).font(.caption) }
                }
                previewSection
            }
            .navigationTitle("新建标签")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { isPresented = false } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("创建") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var presetColorsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Color.tagColors, id: \.self) { color in
                    Circle().fill(color).frame(width: 28, height: 28)
                        .overlay {
                            if color.toHex() == colorHex {
                                Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.white)
                            }
                        }
                        .onTapGesture { colorHex = color.toHex() }
                }
            }.padding(.vertical, 4)
        }
    }

    private var previewSection: some View {
        Section("预览") {
            if let previewTag = makePreviewTag() {
                TagChipView(tag: previewTag)
            }
        }
    }

    private func makePreviewTag() -> Tag? {
        let n = name.trimmingCharacters(in: .whitespaces)
        guard !n.isEmpty else { return nil }
        return Tag(name: n, colorHex: colorHex)
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if allTags.contains(where: { $0.name.lowercased() == trimmed.lowercased() }) {
            errorMessage = "标签「\(trimmed)」已存在"; return
        }
        modelContext.insert(Tag(name: trimmed, colorHex: colorHex))
        isPresented = false
    }
}

struct EditTagSheet: View {
    let tag: Tag
    let allTags: [Tag]
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var colorHex: String
    @State private var errorMessage: String?

    init(tag: Tag, allTags: [Tag]) {
        self.tag = tag
        self.allTags = allTags
        _name = State(initialValue: tag.name)
        _colorHex = State(initialValue: tag.colorHex)
    }

    var selectedColor: Binding<Color> {
        Binding(get: { Color(hex: colorHex) ?? .blue }, set: { colorHex = $0.toHex() })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("标签名称") {
                    TextField("标签名称", text: $name)
                }
                Section("颜色") {
                    ColorPicker("自定义颜色", selection: selectedColor)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Color.tagColors, id: \.self) { color in
                                Circle().fill(color).frame(width: 28, height: 28)
                                    .overlay {
                                        if color.toHex() == colorHex {
                                            Image(systemName: "checkmark").font(.caption.bold()).foregroundStyle(.white)
                                        }
                                    }
                                    .onTapGesture { colorHex = color.toHex() }
                            }
                        }.padding(.vertical, 4)
                    }
                }
                if let msg = errorMessage {
                    Section { Text(msg).foregroundStyle(.red).font(.caption) }
                }
            }
            .navigationTitle("编辑标签")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("取消") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if allTags.contains(where: { $0.id != tag.id && $0.name.lowercased() == trimmed.lowercased() }) {
            errorMessage = "标签「\(trimmed)」已存在"; return
        }
        tag.name = trimmed
        tag.colorHex = colorHex
        dismiss()
    }
}
