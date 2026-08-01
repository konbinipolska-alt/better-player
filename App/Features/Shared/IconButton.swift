import SwiftUI
import DesignSystem

/// A 32×32 chrome-less icon button (no background) drawing an SF Symbol.
/// Used for the header search / back / ellipsis affordances.
struct IconButton: View {
    let systemName: String
    var tint: Color = DSColor.textPrimary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
