import SwiftUI
import UIKit
import DesignSystem

/// Full Now Playing screen, presented when the pill is tapped. Minimal by design:
/// large artwork, a draggable scrub bar, and transport. Phase 4 will enrich it
/// (queue, the same vertical-multiplier scrub as the pill).
struct FullPlayerView: View {
    @Bindable var engine: PlayerEngine
    @Environment(\.dismiss) private var dismiss
    @State private var isDraggingBar = false

    var body: some View {
        ZStack {
            DSColor.canvas.ignoresSafeArea()
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
        .presentationBackground(DSColor.canvas)
    }

    private var grabber: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.down")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(DSColor.textSecondary)
                .frame(width: 44, height: 44)
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
