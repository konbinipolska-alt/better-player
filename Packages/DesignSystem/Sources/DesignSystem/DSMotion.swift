import SwiftUI

/// Motion tokens — fast, spring-based, purposeful. No decorative animation.
public enum DSMotion {
    /// Quick feedback (button press, small state change).
    public static let quick = Animation.spring(response: 0.22, dampingFraction: 0.9)
    /// Standard transition.
    public static let standard = Animation.spring(response: 0.32, dampingFraction: 0.86)
    /// Pill ⇄ full Now Playing expansion.
    public static let expand = Animation.spring(response: 0.42, dampingFraction: 0.82)
    /// Scrub pill morph (resting ⇄ scrubbing).
    public static let scrubMorph = Animation.spring(response: 0.26, dampingFraction: 0.88)
}

/// Named animation durations (seconds) for non-spring uses.
public enum DSDuration {
    public static let quick: Double = 0.18
    public static let standard: Double = 0.30
    public static let slow: Double = 0.45
}
