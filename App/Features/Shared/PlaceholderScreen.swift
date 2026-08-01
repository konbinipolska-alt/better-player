import SwiftUI
import DesignSystem

/// Temporary scaffolding screen — an on-brand placeholder body used until each
/// feature is implemented. The section title now lives in the header nav, so
/// this only renders the descriptive body (SF Symbol + mono note), centered.
struct PlaceholderScreen: View {
    let note: String
    let systemImage: String

    var body: some View {
        ZStack {
            DSColor.canvas.ignoresSafeArea()
            VStack(spacing: DSSpacing.md) {
                Image(systemName: systemImage)
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(DSColor.textTertiary)
                Text(note)
                    .font(DSFont.mono)
                    .foregroundStyle(DSColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(DSSpacing.xl)
        }
    }
}
