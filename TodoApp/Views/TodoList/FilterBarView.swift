import SwiftUI

struct FilterBarView: View {
    let allTags: [Tag]
    @Bindable var viewModel: TodoListViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(allTags) { tag in
                    Button {
                        viewModel.toggleTag(tag)
                    } label: {
                        TagChipView(tag: tag, isSelected: viewModel.isTagSelected(tag))
                    }
                    .buttonStyle(.plain)
                }

                if !viewModel.selectedTags.isEmpty {
                    Button("清除") {
                        viewModel.clearTagFilter()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary)
                    .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(.bar)
    }
}
