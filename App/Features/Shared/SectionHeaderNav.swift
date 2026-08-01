import SwiftUI
import DesignSystem

/// Top-of-screen header navigation. Replaces the bottom tab bar: the three
/// section titles sit left-aligned on a single baseline. The active title is
/// large (`DSFont.display`) and primary; the others are smaller (`DSFont.title`)
/// and tertiary. Tapping a title selects that section. The row scrolls
/// horizontally so the active title never gets clipped when it is the last one.
struct SectionHeaderNav<Section: Hashable>: View {
    let sections: [Section]
    let title: (Section) -> String
    @Binding var selection: Section

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .firstTextBaseline, spacing: DSSpacing.md) {
                ForEach(sections, id: \.self) { section in
                    let isActive = section == selection
                    Text(title(section))
                        .font(isActive ? DSFont.display : DSFont.title)
                        .foregroundStyle(isActive ? DSColor.textPrimary : DSColor.textTertiary)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(DSMotion.standard) { selection = section }
                        }
                }
            }
            .padding(.horizontal, DSSpacing.xl)
            .animation(DSMotion.standard, value: selection)
        }
    }
}
