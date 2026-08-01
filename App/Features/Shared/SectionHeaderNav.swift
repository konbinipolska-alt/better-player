import SwiftUI
import DesignSystem

/// Top-of-screen header navigation. Replaces the bottom tab bar: the three
/// section titles are centred on a single baseline. The active title is a little
/// larger and primary; the others are slightly smaller and tertiary (a small
/// ~14% size gap — state is carried mainly by colour + weight). Tapping selects.
struct SectionHeaderNav<Section: Hashable>: View {
    let sections: [Section]
    let title: (Section) -> String
    @Binding var selection: Section

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: DSSpacing.lg) {
            ForEach(sections, id: \.self) { section in
                let isActive = section == selection
                Text(title(section))
                    .font(.system(size: isActive ? 22 : 19,
                                  weight: isActive ? .semibold : .medium,
                                  design: .default))
                    .foregroundStyle(isActive ? DSColor.textPrimary : DSColor.textTertiary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(DSMotion.standard) { selection = section }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DSSpacing.xl)
        .animation(DSMotion.standard, value: selection)
    }
}
