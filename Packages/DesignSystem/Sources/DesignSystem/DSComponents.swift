import SwiftUI

/// A hairline divider using the design-system stroke + color.
public struct DSDivider: View {
    public init() {}
    public var body: some View {
        Rectangle()
            .fill(DSColor.hairline)
            .frame(height: DSStroke.hairline)
    }
}

/// Uppercase monospaced "eyebrow" label — a technical section marker.
public struct Eyebrow: View {
    private let text: String
    public init(_ text: String) { self.text = text }
    public var body: some View {
        Text(text.uppercased())
            .font(DSFont.eyebrow)
            .tracking(1.2)
            .foregroundStyle(DSColor.textTertiary)
    }
}

public extension View {
    /// Applies the app canvas background, ignoring safe areas.
    func dsCanvas() -> some View {
        background(DSColor.canvas.ignoresSafeArea())
    }
}
