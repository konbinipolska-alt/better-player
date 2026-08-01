import SwiftUI
import UIKit
import DesignSystem

/// The single current playlist ("Konbini") listing the bundled tracks. Tapping a
/// row plays that track; the current one reads brighter and its waveform icon
/// animates while playing.
struct PlaylistsView: View {
    let engine: PlayerEngine

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                ForEach(engine.tracks) { track in
                    let current = track.id == engine.track.id
                    TrackRow(
                        track: track,
                        artwork: engine.sharedArtwork,
                        isCurrent: current,
                        isPlaying: current && engine.isPlaying,
                        onTap: { engine.play(trackID: track.id) }
                    )
                    DSDivider().padding(.leading, 76)
                }
            }
            .padding(.bottom, 140)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DSSpacing.xs) {
            Eyebrow("Playlist")
            Text("Konbini")
                .font(DSFont.title)
                .foregroundStyle(DSColor.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DSSpacing.xl)
        .padding(.top, DSSpacing.md)
        .padding(.bottom, DSSpacing.md)
    }
}

private struct TrackRow: View {
    let track: NowPlayingTrack
    let artwork: UIImage?
    let isCurrent: Bool
    let isPlaying: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DSSpacing.md) {
                thumb
                VStack(alignment: .leading, spacing: 2) {
                    Text(track.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(isCurrent ? DSColor.textPrimary : DSColor.textSecondary)
                        .lineLimit(1)
                    Text(track.artist)
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(DSColor.textTertiary)
                        .lineLimit(1)
                }
                Spacer(minLength: DSSpacing.sm)
                if isCurrent {
                    Image(systemName: "waveform")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(DSColor.textPrimary)
                        .symbolEffect(.variableColor.iterative, isActive: isPlaying)
                }
            }
            .padding(.horizontal, DSSpacing.xl)
            .padding(.vertical, DSSpacing.sm)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var thumb: some View {
        ZStack {
            Circle().fill(DSColor.surfaceRaised)
            if let artwork {
                Image(uiImage: artwork).resizable().scaledToFill()
                    .hueRotation(.degrees(track.artworkHue))
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(DSColor.textTertiary)
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    }
}
