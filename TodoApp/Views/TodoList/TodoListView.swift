import SwiftUI
import SwiftData

struct TodoListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TodoItem.createdAt, order: .reverse) private var allItems: [TodoItem]
    @Query(sort: \Tag.name) private var allTags: [Tag]
    @State private var viewModel = TodoListViewModel()
    @State private var showingAddItem = false
    @State private var showingTagManager = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !allTags.isEmpty {
                    FilterBarView(allTags: allTags, viewModel: viewModel)
                }

                let filtered = viewModel.filteredItems(allItems)

                if filtered.isEmpty {
                    ContentUnavailableView(
                        emptyTitle,
                        systemImage: emptyIcon,
                        description: Text(emptyDescription)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filtered) { item in
                            NavigationLink {
                                TodoDetailView(item: item)
                            } label: {
                                TodoRowView(item: item) {
                                    viewModel.toggleCompletion(item)
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteItems([item], context: modelContext)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    viewModel.toggleCompletion(item)
                                } label: {
                                    Label(item.isCompleted ? "取消完成" : "完成",
                                          systemImage: item.isCompleted ? "arrow.uturn.backward" : "checkmark")
                                }
                                .tint(item.isCompleted ? Color.orange : Color.green)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .searchable(text: $viewModel.searchText, prompt: "搜索事项或标签")
            .navigationTitle("待办事项")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showingAddItem = true } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Section("排序方式") {
                            ForEach(TodoListViewModel.SortOrder.allCases, id: \.self) { order in
                                Button {
                                    viewModel.sortOrder = order
                                } label: {
                                    if viewModel.sortOrder == order {
                                        Label(order.rawValue, systemImage: "checkmark")
                                    } else {
                                        Text(order.rawValue)
                                    }
                                }
                            }
                        }
                        Section {
                            Toggle("显示已完成", isOn: $viewModel.showCompleted)
                        }
                        Section {
                            Button {
                                showingTagManager = true
                            } label: {
                                Label("管理标签", systemImage: "tag")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                TodoEditView()
            }
            .sheet(isPresented: $showingTagManager) {
                NavigationStack {
                    TagListView()
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("完成") { showingTagManager = false }
                            }
                        }
                }
            }
        }
    }

    private var emptyTitle: String {
        if !viewModel.searchText.isEmpty { return "未找到结果" }
        if !viewModel.selectedTags.isEmpty { return "该标签下暂无事项" }
        if !viewModel.showCompleted { return "暂无待办事项" }
        return "开始添加事项吧"
    }

    private var emptyIcon: String {
        if !viewModel.searchText.isEmpty { return "magnifyingglass" }
        if !viewModel.selectedTags.isEmpty { return "tag.slash" }
        return "checklist"
    }

    private var emptyDescription: String {
        if !viewModel.searchText.isEmpty { return "尝试修改搜索词" }
        if !viewModel.selectedTags.isEmpty { return "切换其他标签筛选" }
        return "点击右上角 + 添加第一个待办事项"
    }
}

#Preview {
    TodoListView()
        .modelContainer(PreviewData.container)
}
