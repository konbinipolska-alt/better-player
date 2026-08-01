import SwiftUI
import UIKit
import DesignSystem

/// The current "Konbini" playlist. The engine's queue repeats the tracks
/// (each with a unique id) so the list is long enough to scroll; only the
/// actually-playing row is marked and shows the animated equalizer.
struct PlaylistsView: View {
    let engine: PlayerEngine

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                header
                ForEach(engine.tracks) { track in
                    TrackRow(
                        engine: engine,
                        track: track,
                        artwork: engine.sharedArtwork,
                        isCurrent: track.id == engine.track.id,
                        onTap: { engine.play(itemID: track.id) }
                    )
                    DSDivider().padding(.leading, 76)
                }
            }
            .padding(.bottom, 160)
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
    let engine: PlayerEngine
    let track: NowPlayingTrack
    let artwork: UIImage?
    let isCurrent: Bool
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
                    PlayingIndicator(engine: engine)
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
