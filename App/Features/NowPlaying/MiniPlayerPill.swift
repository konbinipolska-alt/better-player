import SwiftUI
import DesignSystem

/// The signature mini-player pill. During scaffolding this is a static visual
/// that proves out the design tokens; Phase 3 adds the scrub gesture engine
/// (flick prev/next, press-and-hold to seek, vertical speed multiplier,
/// off-pill continuation, morph → progress + timecode).
struct MiniPlayerPill: View {
    let track: NowPlayingTrack
    /// 0…1 elapsed fraction.
    var progress: Double = 0
    var isPlaying: Bool = true

    private let height: CGFloat = 62

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Base surface.
                DSColor.surface

                // Progress = pill background lightened ~15% up to the elapsed point.
                DSColor.progressFill
                    .frame(width: max(0, min(1, progress)) * geo.size.width)

                content
                    .padding(.horizontal, DSSpacing.sm)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DSRadius.lg, style: .continuous)
                .stroke(DSColor.hairline, lineWidth: DSStroke.hairline)
        )
        .shadow(color: .black.opacity(0.4), radius: 12, y: 4)
    }

    private var content: some View {
        HStack(spacing: DSSpacing.md) {
            artwork
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(DSFont.headline)
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
                Text(track.artist)
                    .font(DSFont.monoSmall)
                    .foregroundStyle(DSColor.textSecondary)
                    .lineLimit(1)
            }
            Spacer(minLength: DSSpacing.sm)
            Text(Timecode.string(progress * track.duration))
                .font(DSFont.monoSmall)
                .foregroundStyle(DSColor.textTertiary)
            playButton
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
        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(DSColor.textPrimary)
            .frame(width: 40, height: 40)
            .contentShape(Rectangle())
    }
}

#Preview {
    ZStack {
        DSColor.canvas.ignoresSafeArea()
        MiniPlayerPill(track: .sample, progress: 0.38)
            .padding()
    }
    .preferredColorScheme(.dark)
}
