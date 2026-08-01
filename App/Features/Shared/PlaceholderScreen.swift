import SwiftUI
import DesignSystem

/// Temporary scaffolding screen — a titled, on-brand placeholder used until each
/// feature is implemented. Removed as real screens land.
struct PlaceholderScreen: View {
    let eyebrow: String
    let title: String
    let note: String
    let systemImage: String

    var body: some View {
        ZStack {
            DSColor.canvas.ignoresSafeArea()
            VStack(alignment: .leading, spacing: DSSpacing.sm) {
                Eyebrow(eyebrow)
                Text(title)
                    .font(DSFont.display)
                    .foregroundStyle(DSColor.textPrimary)
                Spacer()
                VStack(spacing: DSSpacing.md) {
                    Image(systemName: systemImage)
                        .font(.system(size: 34, weight: .regular))
                        .foregroundStyle(DSColor.textTertiary)
                    Text(note)
                        .font(DSFont.mono)
                        .foregroundStyle(DSColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                Spacer()
                Spacer()
            }
            .padding(DSSpacing.xl)
        }
    }
}
