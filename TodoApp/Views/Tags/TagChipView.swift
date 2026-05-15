import SwiftUI

struct TagChipView: View {
    let tag: Tag
    var isSelected: Bool = false
    var isSmall: Bool = false

    var body: some View {
        Text(tag.name)
            .font(isSmall ? .caption2 : .caption)
            .fontWeight(.medium)
            .padding(.horizontal, isSmall ? 6 : 8)
            .padding(.vertical, isSmall ? 2 : 4)
            .background(isSelected ? tag.color : tag.color.opacity(0.15))
            .foregroundStyle(isSelected ? .white : tag.color)
            .clipShape(Capsule())
    }
}
