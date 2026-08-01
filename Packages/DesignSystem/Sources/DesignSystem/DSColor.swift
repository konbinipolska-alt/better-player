import SwiftUI

/// Design-system color tokens. Dark-first, "50/50 terminal × iOS 18".
/// These are the single source of truth — features must never hardcode hex values.
public enum DSColor {
    // Surfaces (dark-first, near-black).
    /// App background canvas.
    public static let canvas = Color(hex: "#0A0A0A")
    /// Primary surface — cards and the mini-player pill.
    public static let surface = Color(hex: "#111111")
    /// Slightly raised surface (sheets, elevated rows).
    public static let surfaceRaised = Color(hex: "#1A1A1A")
    /// Scrub progress fill: pill background (#111111) lightened ~15%.
    public static let progressFill = Color(hex: "#2A2A2A")
    /// Progress fill for the frosted-glass pill — a light sweep readable over blur.
    public static let progressGlass = Color.white.opacity(0.14)
    /// Hairline dividers / borders.
    public static let hairline = Color(hex: "#262626")

    // Text.
    public static let textPrimary = Color(hex: "#F5F5F5")
    public static let textSecondary = Color(hex: "#9CA3AF")
    public static let textTertiary = Color(hex: "#6B7280")

    // Accent — restrained, technical. Placeholder to lock during design review.
    public static let accent = Color(hex: "#7EE787")
    /// Text/icon color drawn on top of `accent`.
    public static let onAccent = Color(hex: "#0A0A0A")

    // Semantic.
    public static let destructive = Color(hex: "#F87171")
}
