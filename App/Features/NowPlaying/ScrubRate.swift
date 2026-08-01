import CoreGraphics

/// Scrub-speed tiers, selected by how far the finger moves vertically (upward)
/// during a hold-scrub — mirroring Apple's video scrubber. The pill is docked at
/// the bottom, so *up* = finer control (more headroom there).
enum ScrubRate: CaseIterable {
    case hiSpeed   // 1.0×
    case half      // 0.5×
    case quarter   // 0.25×
    case fine      // 0.1×

    /// Multiplier applied to horizontal scrub movement.
    var factor: Double {
        switch self {
        case .hiSpeed: return 1.0
        case .half:    return 0.5
        case .quarter: return 0.25
        case .fine:    return 0.1
        }
    }

    var label: String {
        switch self {
        case .hiSpeed: return "HI-SPEED"
        case .half:    return "HALF-SPEED"
        case .quarter: return "QUARTER"
        case .fine:    return "FINE"
        }
    }

    /// Maps upward finger travel (in points, positive = up) to a rate tier.
    static func forVerticalOffset(_ up: CGFloat) -> ScrubRate {
        switch up {
        case ..<60:   return .hiSpeed
        case ..<140:  return .half
        case ..<240:  return .quarter
        default:      return .fine
        }
    }
}
