import SwiftUI
import DesignSystem

/// A lightweight, GPU-friendly warp-stars welcome overlay. Renders thin white
/// streaks flying toward the viewer with subtle chromatic aberration. Tapping
/// anywhere dismisses the overlay via `onFinish`.
struct WelcomeWarpView: View {
    var onFinish: () -> Void

    @State private var t: Double = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()

            TimelineView(.animation(minimumInterval: 1.0/120.0)) { context in
                let now = context.date.timeIntervalSinceReferenceDate
                Canvas { ctx, size in
                    drawWarp(in: ctx, size: size, time: now)
                }
            }
            .ignoresSafeArea()
            .blendMode(.plusLighter)
            .opacity(0.9)

            VStack(spacing: 16) {
                // Placeholder for logo/brand mark.
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(DSColor.surface)
                    .frame(width: 120, height: 24)
            }
        }
        .onTapGesture { onFinish() }
        .task {
            // Auto-dismiss after a short moment.
            try? await Task.sleep(nanoseconds: 2_700_000_000)
            await MainActor.run { onFinish() }
        }
    }

    private func drawWarp(in ctx: GraphicsContext, size: CGSize, time: TimeInterval) {
        let w = size.width
        let h = size.height
        let center = CGPoint(x: w/2, y: h/2)

        // Deterministic pseudo-random but time-evolving field of streaks.
        let starCount = Int(min(220, max(120, (w * h) / 6000)))
        let baseSpeed: CGFloat = 0.8

        for i in 0..<starCount {
            let seed = Double(i) * 12.9898
            let angle = fract(sin(seed) * 43758.5453) * .pi * 2
            let radius0 = CGFloat(fract(cos(seed) * 2467.0)) * min(w, h) * 0.5
            let speed = baseSpeed + CGFloat(fract(sin(seed * 1.3)) * 1.4)

            // Progress 0..1 for this star (wraps over time).
            let p = CGFloat(fract(time * Double(speed) + sin(seed)))
            let r1 = radius0 * p
            let r0 = max(0, r1 - (8 + 32 * (1 - p)))

            let x0 = center.x + cos(angle) * r0
            let y0 = center.y + sin(angle) * r0
            let x1 = center.x + cos(angle) * r1
            let y1 = center.y + sin(angle) * r1

            let path = Path { p in
                p.move(to: CGPoint(x: x0, y: y0))
                p.addLine(to: CGPoint(x: x1, y: y1))
            }

            // Core white streak.
            ctx.stroke(path, with: .color(.white.opacity(0.9)), lineWidth: 1)
            // Subtle chromatic aberration (RB offsets).
            let off: CGFloat = 0.6
            let rPath = path.applying(CGAffineTransform(translationX: off, y: 0))
            let bPath = path.applying(CGAffineTransform(translationX: -off, y: 0))
            ctx.stroke(rPath, with: .color(Color.red.opacity(0.35)), lineWidth: 0.8)
            ctx.stroke(bPath, with: .color(Color.blue.opacity(0.35)), lineWidth: 0.8)
        }
    }
}

private func fract(_ x: Double) -> Double { x - floor(x) }
