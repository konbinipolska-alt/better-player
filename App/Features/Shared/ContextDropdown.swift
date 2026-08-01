import SwiftUI
import DesignSystem

/// A single row in a `ContextDropdown`.
struct ContextDropdownItem: Identifiable {
    let id = UUID()
    let title: String
    var isDestructive: Bool = false
    let action: () -> Void
}

/// Our own styled dropdown: a dark raised surface with a hairline border,
/// anchored under a trigger. Presented as an overlay; tapping outside dismisses.
struct ContextDropdown: View {
    let items: [ContextDropdownItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Button {
                    item.action()
                } label: {
                    Text(item.title)
                        .font(DSFont.headline)
                        .foregroundStyle(item.isDestructive ? DSColor.destructive : DSColor.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DSSpacing.md)
                        .padding(.vertical, DSSpacing.sm)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                if index < items.count - 1 {
                    DSDivider()
                }
            }
        }
        .frame(width: 180, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                .fill(DSColor.surfaceRaised)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous)
                .strokeBorder(DSColor.hairline, lineWidth: DSStroke.regular)
        )
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 16, y: 8)
    }
}
