import SwiftUI
import UIKit
import DesignSystem

/// The signature mini-player pill with its scrub gesture engine. Flick vs scrub
/// is decided by **how long the finger stays down**, not by movement:
/// - **tap** (left/centre) → expand to Now Playing; **tap** (over the button) → play/pause
/// - **quick horizontal swipe** (finger lifts before the hold delay) → previous / next
/// - **press-and-hold ~0.2s, then drag** → scrub: horizontal = seek, vertical (up) =
///   speed multiplier tier; the finger may leave the pill and keep scrubbing.
///   During scrub the pill content stays put — only the progress fill sweeps and the
///   small timecode reflects the target; audio is seeked once, on release.
struct MiniPlayerPill: View {
    @Bindable var engine: PlayerEngine
    var onTapExpand: () -> Void = {}

    private let height: CGFloat = 68
    private let baseSecondsPerPoint: Double = 0.25
    private let holdDelay: TimeInterval = 0.2

    // Gesture state.
    @State private var gestureBegan = false
    @State private var didScrub = false
    @State private var curWidth: CGFloat = 0
    @State private var lastWidth: CGFloat = 0
    @State private var startX: CGFloat = 0
    @State private var holdWork: DispatchWorkItem?
    @State private var lastRate: ScrubRate = .hiSpeed

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                DSColor.surface

                // Progress = pill background lightened ~15%, up to the (scrub or live) point.
                DSColor.progressFill
                    .frame(width: engine.displayProgress * geo.size.width)
                    .animation(engine.isScrubbing ? nil : DSMotion.quick, value: engine.displayProgress)

                restingContent
                    .padding(.horizontal, DSSpacing.sm)
            }
            .contentShape(Rectangle())
            .gesture(dragGesture(width: geo.size.width))
        }
        .frame(height: height)
        .clipShape(Capsule(style: .continuous))
        .overlay(
            Capsule(style: .continuous)
                .stroke(DSColor.hairline, lineWidth: DSStroke.hairline)
        )
        .shadow(color: .black.opacity(0.35), radius: 10, y: 3)
    }

    // MARK: Content

    private var restingContent: some View {
        HStack(spacing: DSSpacing.md) {
            artwork
            VStack(alignment: .leading, spacing: 4) {
                Text(engine.track.title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
                Text(engine.track.artist)
                    .font(DSFont.monoSmall)
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: DSSpacing.sm)
            Text(Timecode.string(engine.displayTime))
                .font(DSFont.monoSmall)
                .foregroundStyle(DSColor.textTertiary)
            playButton
        }
    }

    private var artwork: some View {
        ZStack {
            Circle().fill(DSColor.surfaceRaised)
            if let img = engine.artwork {
                Image(uiImage: img).resizable().scaledToFill()
                    .hueRotation(.degrees(engine.track.artworkHue))
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(DSColor.textTertiary)
            }
        }
        .frame(width: 56, height: 56)
        .clipShape(Circle())
    }

    private var playButton: some View {
        Image(systemName: engine.isPlaying ? "pause.fill" : "play.fill")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(DSColor.textPrimary)
            .frame(width: 44, height: 44)
    }

    // MARK: Gesture

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !gestureBegan { beginGesture(startLocation: value.startLocation) }
                curWidth = value.translation.width

                guard didScrub else { return }
                let delta = value.translation.width - lastWidth
                lastWidth = value.translation.width
                let up = max(0, -value.translation.height)
                engine.updateScrub(horizontalDelta: delta, verticalUp: up,
                                   secondsPerPoint: baseSecondsPerPoint)
                if engine.scrubRate != lastRate {
                    lastRate = engine.scrubRate
                    UISelectionFeedbackGenerator().selectionChanged()
                }
            }
            .onEnded { value in
                holdWork?.cancel()
                defer { resetGesture() }

                if didScrub {
                    engine.endScrub(commit: true)
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    return
                }

                // Ended before the hold fired → a quick gesture: flick or tap.
                let w = value.translation.width
                let h = value.translation.height
                if abs(w) > 30 && abs(w) > abs(h) {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    w < 0 ? engine.next() : engine.previous()
                } else if abs(w) < 12 && abs(h) < 12 {
                    if startX > width - 64 {
                        engine.togglePlayPause()
                    } else {
                        onTapExpand()
                    }
                }
            }
    }

    /// Begins tracking and arms the hold timer. The timer — not movement —
    /// decides scrub vs flick: if the finger is still down after `holdDelay`,
    /// we enter scrub mode regardless of how much it moved.
    private func beginGesture(startLocation: CGPoint) {
        gestureBegan = true
        didScrub = false
        curWidth = 0
        lastWidth = 0
        startX = startLocation.x

        let work = DispatchWorkItem {
            guard gestureBegan, !didScrub else { return }
            didScrub = true
            lastWidth = curWidth
            lastRate = .hiSpeed
            engine.beginScrub()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        holdWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + holdDelay, execute: work)
    }

    private func resetGesture() {
        gestureBegan = false
        didScrub = false
        curWidth = 0
        lastWidth = 0
    }
}

#Preview {
    ZStack {
        DSColor.canvas.ignoresSafeArea()
        MiniPlayerPill(engine: PlayerEngine())
            .padding()
    }
    .preferredColorScheme(.dark)
}
