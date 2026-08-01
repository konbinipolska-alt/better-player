import SwiftUI
import DesignSystem

/// Slim equalizer-style playing indicator: thin vertical bars that oscillate and
/// pulse in height with the track's live audio level (beat). Flat when paused.
struct PlayingIndicator: View {
    @Bindable var engine: PlayerEngine

    private let barCount = 4
    private let minH: CGFloat = 2
    private let maxH: CGFloat = 12
    private let barWidth: CGFloat = 2
    private let spacing: CGFloat = 2
    private let speeds: [Double] = [7.0, 9.5, 8.0, 6.5]
    private let phases: [Double] = [0.0, 1.3, 2.1, 0.7]

    var body: some View {
        Group {
            if engine.isPlaying {
                TimelineView(.animation) { tl in
                    bars(at: tl.date.timeIntervalSinceReferenceDate)
                }
            } else {
                bars(at: 0)
            }
        }
        .frame(width: CGFloat(barCount) * barWidth + CGFloat(barCount - 1) * spacing,
               height: maxH)
    }

    private func bars(at t: Double) -> some View {
        HStack(alignment: .center, spacing: spacing) {
            ForEach(0..<barCount, id: \.self) { i in
                Capsule()
                    .fill(DSColor.textSecondary)
                    .frame(width: barWidth, height: height(i, t))
            }
        }
    }

    private func height(_ i: Int, _ t: Double) -> CGFloat {
        guard engine.isPlaying else { return minH }
        let osc = 0.5 + 0.5 * sin(t * speeds[i] + phases[i])   // 0…1
        let amp = max(0.12, engine.level)                      // beat amplitude
        let v = min(1.0, amp * osc * 1.9)
        return minH + (maxH - minH) * CGFloat(v)
    }
}
