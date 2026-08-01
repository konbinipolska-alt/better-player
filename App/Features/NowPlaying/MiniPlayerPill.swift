import SwiftUI
import UIKit
import DesignSystem

/// The signature mini-player pill with its scrub gesture engine:
/// - **tap** (left/centre) → expand to Now Playing; **tap** (over the button) → play/pause
/// - **quick horizontal flick** → previous / next track
/// - **press-and-hold, then drag** → scrub: horizontal = seek, vertical (up) =
///   speed multiplier tier; the finger may leave the pill and keep scrubbing;
///   the pill morphs to a progress fill + target timecode; release commits.
struct MiniPlayerPill: View {
    @Bindable var engine: PlayerEngine
    var onTapExpand: () -> Void = {}

    private let height: CGFloat = 62
    private let baseSecondsPerPoint: Double = 0.25
    private let holdDelay: TimeInterval = 0.22

    // Gesture state.
    @State private var gestureBegan = false
    @State private var didScrub = false
    @State private var movedBeyondHold = false
    @State private var curWidth: CGFloat = 0
    @State private var lastWidth: CGFloat = 0
    @State private var startX: CGFloat = 0
    @State private var startDate = Date()
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

                Group {
                    if engine.isScrubbing {
                        scrubbingContent
                    } else {
                        restingContent
                    }
                }
                .padding(.horizontal, DSSpacing.sm)
            }
            .contentShape(Rectangle())
            .gesture(dragGesture(width: geo.size.width))
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                .stroke(engine.isScrubbing ? DSColor.accent.opacity(0.5) : DSColor.hairline,
                        lineWidth: engine.isScrubbing ? 1 : DSStroke.hairline)
        )
        .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
        .animation(DSMotion.scrubMorph, value: engine.isScrubbing)
    }

    // MARK: Content

    private var restingContent: some View {
        HStack(spacing: DSSpacing.md) {
            artwork
            VStack(alignment: .leading, spacing: 2) {
                Text(engine.track.title)
                    .font(DSFont.headline)
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

    private var scrubbingContent: some View {
        HStack(spacing: DSSpacing.md) {
            VStack(alignment: .leading, spacing: 0) {
                Text(engine.scrubRate.label)
                    .font(DSFont.eyebrow)
                    .tracking(1.2)
                    .foregroundStyle(DSColor.accent)
                Text("SCRUB")
                    .font(DSFont.eyebrow)
                    .tracking(1.2)
                    .foregroundStyle(DSColor.textTertiary)
            }
            Spacer(minLength: DSSpacing.sm)
            Text(Timecode.string(engine.scrubTargetTime))
                .font(DSFont.monoLarge)
                .foregroundStyle(DSColor.textPrimary)
            Text("/ \(Timecode.string(engine.duration))")
                .font(DSFont.monoSmall)
                .foregroundStyle(DSColor.textTertiary)
        }
    }

    private var artwork: some View {
        RoundedRectangle(cornerRadius: DSRadius.sm, style: .continuous)
            .fill(DSColor.surfaceRaised)
            .frame(width: 46, height: 46)
            .overlay(
                Image(systemName: "music.note")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(DSColor.textTertiary)
            )
    }

    private var playButton: some View {
        Image(systemName: engine.isPlaying ? "pause.fill" : "play.fill")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(DSColor.textPrimary)
            .frame(width: 44, height: 44)
    }

    // MARK: Gesture

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !gestureBegan {
                    beginGesture(startLocation: value.startLocation)
                }
                curWidth = value.translation.width

                if didScrub {
                    let delta = value.translation.width - lastWidth
                    lastWidth = value.translation.width
                    let up = max(0, -value.translation.height)
                    engine.updateScrub(horizontalDelta: delta, verticalUp: up,
                                       secondsPerPoint: baseSecondsPerPoint)
                    if engine.scrubRate != lastRate {
                        lastRate = engine.scrubRate
                        UISelectionFeedbackGenerator().selectionChanged()
                    }
                } else if abs(value.translation.width) > 12 || abs(value.translation.height) > 12 {
                    movedBeyondHold = true          // it's a swipe/flick, not a hold
                    holdWork?.cancel()
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

                let w = value.translation.width
                let h = value.translation.height
                if abs(w) > 40 {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    w < 0 ? engine.next() : engine.previous()
                } else if abs(w) < 10 && abs(h) < 10 {
                    if startX > width - 64 {
                        engine.togglePlayPause()
                    } else {
                        onTapExpand()
                    }
                }
            }
    }

    private func beginGesture(startLocation: CGPoint) {
        gestureBegan = true
        didScrub = false
        movedBeyondHold = false
        curWidth = 0
        lastWidth = 0
        startX = startLocation.x
        startDate = Date()

        let work = DispatchWorkItem {
            guard !movedBeyondHold, gestureBegan else { return }
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
        movedBeyondHold = false
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
