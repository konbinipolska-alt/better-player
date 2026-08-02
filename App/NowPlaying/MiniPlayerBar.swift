import SwiftUI

/// The docked mini player. Shown only while something is queued; tapping the bar
/// opens Now Playing, the trailing button toggles play/pause.
struct MiniPlayerBar: View {
    let player: PlayerModel
    var onOpen: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            ArtworkView(artwork: player.artwork, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(player.title.isEmpty ? "Not Playing" : player.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(player.artist)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            Button {
                Task { await player.togglePlayPause() }
            } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.08))
        )
        .contentShape(Rectangle())
        .onTapGesture { onOpen() }
    }
}
