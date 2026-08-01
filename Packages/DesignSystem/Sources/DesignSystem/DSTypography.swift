import SwiftUI

/// Typography tokens. The "technical" half of the aesthetic lives here:
/// monospaced, tabular figures for data / timecodes / numerics; SF Pro for prose.
/// Weights are kept light — medium by default, semibold only for the odd accent.
public enum DSFont {
    // MARK: Prose (SF Pro / system)
    public static let display = Font.system(size: 34, weight: .semibold, design: .default)
    public static let title = Font.system(size: 22, weight: .medium, design: .default)
    public static let headline = Font.system(size: 17, weight: .medium, design: .default)
    public static let body = Font.system(size: 17, weight: .regular, design: .default)
    public static let callout = Font.system(size: 15, weight: .regular, design: .default)
    public static let caption = Font.system(size: 12, weight: .regular, design: .default)

    // MARK: Data (SF Mono, monospaced-digit)
    /// Large monospaced readout, e.g. a big timecode.
    public static let monoLarge = Font.system(size: 28, weight: .medium, design: .monospaced)
        .monospacedDigit()
    /// Standard monospaced label (metadata, counts).
    public static let mono = Font.system(size: 14, weight: .regular, design: .monospaced)
        .monospacedDigit()
    /// Small monospaced label (timecodes on the pill, durations).
    public static let monoSmall = Font.system(size: 12, weight: .regular, design: .monospaced)
        .monospacedDigit()
    /// Uppercase technical eyebrow / section marker.
    public static let eyebrow = Font.system(size: 11, weight: .medium, design: .monospaced)
}
