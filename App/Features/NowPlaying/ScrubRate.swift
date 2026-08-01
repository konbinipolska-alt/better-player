import CoreGraphics

/// Scrub-speed tiers selected by how far the finger moves vertically (upward)
/// during a hold-scrub. The higher the finger, the LARGER the multiplier — keep
/// the finger low near the pill for precise seeking, lift it to scrub fast.
enum ScrubRate: CaseIterable {
    case base      // finger near the pill = precise
    case fast
    case faster
    case turbo     // finger high = fastest

    /// Multiplier applied to horizontal scrub movement.
    var factor: Double {
        switch self {
        case .base:   return 1.0
        case .fast:   return 1.8
        case .faster: return 2.6
        case .turbo:  return 3.5
        }
    }

    /// Maps upward finger travel (points, positive = up) to a rate tier — more
    /// upward travel → a bigger multiplier.
    static func forVerticalOffset(_ up: CGFloat) -> ScrubRate {
        switch up {
        case ..<50:  return .base
        case ..<120: return .fast
        case ..<220: return .faster
        default:     return .turbo
        }
    }
}
