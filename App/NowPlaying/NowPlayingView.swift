import SwiftUI

/// Full-screen Now Playing (presented as a sheet). Large artwork, title/artist,
/// a scrubbable progress bar, and transport controls. Swiping the sheet down
/// dismisses it back to the mini player.
struct NowPlayingView: View {
    let player: PlayerModel

    @State private var isScrubbing = false
    @State private var scrubValue: Double = 0

    var body: some View {
        VStack(spacing: 28) {
            Capsule()
                .fill(.white.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 10)

            Spacer(minLength: 0)

            ArtworkView(artwork: player.artwork, size: 300)
                .shadow(color: .black.opacity(0.5), radius: 24, y: 12)

            VStack(spacing: 6) {
                Text(player.title.isEmpty ? "Not Playing" : player.title)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(player.artist)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            progressBar
            controls

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }

    private var displayedTime: Double {
        isScrubbing ? scrubValue : player.playbackTime
    }

    private var progressBar: some View {
        VStack(spacing: 6) {
            Slider(
                value: Binding(
                    get: { displayedTime },
                    set: { scrubValue = $0 }
                ),
                in: 0...max(player.duration, 1),
                onEditingChanged: { editing in
                    isScrubbing = editing
                    if !editing { player.seek(to: scrubValue) }
                }
            )
            .tint(.white)

            HStack {
                Text(timecode(displayedTime))
                Spacer()
                Text(timecode(player.duration))
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(.secondary)
        }
    }

    private var controls: some View {
        HStack(spacing: 48) {
            Button { Task { await player.skipToPrevious() } } label: {
                Image(systemName: "backward.fill").font(.title)
            }
            Button { Task { await player.togglePlayPause() } } label: {
                Image(systemName: player.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 68))
            }
            Button { Task { await player.skipToNext() } } label: {
                Image(systemName: "forward.fill").font(.title)
            }
        }
        .foregroundStyle(.white)
    }

    private func timecode(_ t: TimeInterval) -> String {
        guard t.isFinite, t >= 0 else { return "0:00" }
        let total = Int(t)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
