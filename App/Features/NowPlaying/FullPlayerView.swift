import SwiftUI
import UIKit
import DesignSystem

/// Full Now Playing screen. Reached by morphing the mini-player pill in place:
/// the large cover shares a `matchedGeometryEffect` (`np.artwork`) with the
/// pill thumb, so a single `DSMotion.expand` spring flies/scales it up. A
/// downward drag interactively moves + scales the whole surface toward the pill
/// (dimming and rounding its corners as it goes); releasing past a threshold —
/// or tapping the chevron — collapses back with the same spring, while a
/// release under threshold snaps back to full. The drag is continuous and
/// interruptible (it can reverse before release).
struct FullPlayerView: View {
    @Bindable var engine: PlayerEngine
    /// Shared namespace for the matched cover morph.
    var morph: Namespace.ID? = nil
    /// Collapse back to the docked pill (parent flips `isExpanded` with a spring).
    var collapse: () -> Void = {}

    @State private var isDraggingBar = false
    @State private var dragOffset: CGFloat = 0

    /// Drag distance past which release collapses.
    private let collapseThreshold: CGFloat = 120
    /// Distance mapped to full (1.0) collapse progress for the interactive transform.
    private let dragSpan: CGFloat = 620

    private var progress: CGFloat { min(1, max(0, dragOffset / dragSpan)) }

    var body: some View {
        ZStack {
            DSColor.canvas
                .ignoresSafeArea()
                .opacity(1 - progress * 0.4)   // dim as it shrinks toward the pill
            VStack(spacing: DSSpacing.xl) {
                grabber
                Spacer()
                artwork
                titles
                scrubBar
                transport
                Spacer()
            }
            .padding(DSSpacing.xl)
        }
        // Interactive collapse transform — the whole surface tracks the finger.
        .scaleEffect(1 - progress * 0.12, anchor: .top)
        .offset(y: dragOffset)
        .clipShape(RoundedRectangle(cornerRadius: progress * 40, style: .continuous))
        .gesture(collapseDrag)
    }

    // MARK: Interactive collapse

    private var collapseDrag: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { v in
                // Downward only; a slight rubber-band lets it reverse smoothly.
                dragOffset = max(0, v.translation.height)
            }
            .onEnded { v in
                let flungDown = v.predictedEndTranslation.height > 500
                if v.translation.height > collapseThreshold || flungDown {
                    // Collapse: parent removes this view with DSMotion.expand and
                    // the matched cover flies back into the pill. Keep the current
                    // offset so the fading surface reads as continuing downward.
                    collapse()
                } else {
                    withAnimation(DSMotion.expand) { dragOffset = 0 }
                }
            }
    }

    private var grabber: some View {
        VStack(spacing: DSSpacing.md) {
            Capsule()
                .fill(DSColor.textTertiary.opacity(0.6))
                .frame(width: 36, height: 5)
            Button { collapse() } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(DSColor.textSecondary)
                    .frame(width: 44, height: 44)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }

    private var artwork: some View {
        RoundedRectangle(cornerRadius: DSRadius.card, style: .continuous)
            .fill(DSColor.surface)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let img = engine.artwork {
                    Image(uiImage: img).resizable().scaledToFill()
                        .hueRotation(.degrees(engine.track.artworkHue))
                } else {
                    Image(systemName: "music.note")
                        .font(.system(size: 64, weight: .light))
                        .foregroundStyle(DSColor.textTertiary)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DSRadius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DSRadius.card, style: .continuous)
                    .stroke(DSColor.hairline, lineWidth: DSStroke.hairline)
            )
            .matchedArtwork(in: morph)
    }

    private var titles: some View {
        VStack(spacing: DSSpacing.xs) {
            Text(engine.track.title)
                .font(DSFont.title)
                .foregroundStyle(DSColor.textPrimary)
            Text(engine.track.artist)
                .font(DSFont.mono)
                .foregroundStyle(DSColor.textSecondary)
        }
    }

    private var scrubBar: some View {
        VStack(spacing: DSSpacing.xs) {
            GeometryReader { geo in
                Capsule()
                    .fill(DSColor.surfaceRaised)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(DSColor.textPrimary)
                            .frame(width: engine.displayProgress * geo.size.width)
                    }
                    .frame(height: 6)
                    .frame(maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { v in
                                isDraggingBar = true
                                engine.seek(toFraction: Double(v.location.x / geo.size.width))
                            }
                            .onEnded { _ in isDraggingBar = false }
                    )
            }
            .frame(height: 24)

            HStack {
                Text(Timecode.string(engine.displayTime))
                Spacer()
                Text(Timecode.string(engine.duration))
            }
            .font(DSFont.monoSmall)
            .foregroundStyle(DSColor.textTertiary)
        }
    }

    private var transport: some View {
        HStack(spacing: DSSpacing.xxl) {
            transportButton("backward.fill", size: 26) { engine.previous() }
            transportButton(engine.isPlaying ? "pause.fill" : "play.fill", size: 40) {
                engine.togglePlayPause()
            }
            transportButton("forward.fill", size: 26) { engine.next() }
        }
    }

    private func transportButton(_ name: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: name)
                .font(.system(size: size, weight: .medium))
                .foregroundStyle(DSColor.textPrimary)
                .frame(width: 64, height: 64)
        }
    }
}

#Preview {
    FullPlayerView(engine: PlayerEngine()).preferredColorScheme(.dark)
}
