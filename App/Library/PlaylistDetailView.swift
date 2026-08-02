import SwiftUI
import MusicKit

/// One playlist's tracks. Loads them via MusicKit, then plays through the shared
/// `PlayerModel`: "Play" starts from the top, tapping a row starts from there.
struct PlaylistDetailView: View {
    let playlist: Playlist
    let player: PlayerModel

    private enum Phase {
        case loading
        case loaded(MusicItemCollection<Track>)
        case empty
        case failed(String)
    }
    @State private var phase: Phase = .loading

    var body: some View {
        Group {
            switch phase {
            case .loading:
                ProgressView().tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .failed(let message):
                VStack(spacing: 12) {
                    Text("Couldn't load tracks").font(.headline)
                    Text(message).font(.caption).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") { Task { await load() } }
                        .buttonStyle(.bordered).tint(.white)
                }
                .padding(40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .empty:
                Text("No tracks in this playlist")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let tracks):
                List {
                    Button {
                        if let first = tracks.first {
                            Task { await player.play(tracks, startingAt: first) }
                        }
                    } label: {
                        Label("Play", systemImage: "play.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    .listRowBackground(Color.black)

                    ForEach(tracks) { track in
                        Button {
                            Task { await player.play(tracks, startingAt: track) }
                        } label: {
                            TrackRow(track: track)
                        }
                        .listRowBackground(Color.black)
                        .listRowSeparatorTint(.white.opacity(0.08))
                    }
                    Color.clear.frame(height: 72).listRowBackground(Color.black)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .navigationTitle(playlist.name)
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func load() async {
        phase = .loading
        do {
            let detailed = try await playlist.with([.tracks])
            let tracks = detailed.tracks ?? []
            phase = tracks.isEmpty ? .empty : .loaded(tracks)
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}

private struct TrackRow: View {
    let track: Track

    var body: some View {
        HStack(spacing: 12) {
            ArtworkView(artwork: track.artwork, size: 44)
            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(.body)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(track.artistName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }
}
