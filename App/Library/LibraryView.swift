import SwiftUI
import MusicKit

/// The root screen: the user's Apple Music library playlists, with explicit
/// loading / empty / error(+retry) states. Tapping a row pushes its detail.
struct LibraryView: View {
    let player: PlayerModel

    private enum Phase {
        case loading
        case loaded(MusicItemCollection<Playlist>)
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
                    Text("Couldn't load your library").font(.headline)
                    Text(message).font(.caption).foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Retry") { Task { await load() } }
                        .buttonStyle(.bordered).tint(.white)
                }
                .padding(40)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .empty:
                Text("No playlists in your library")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let playlists):
                List {
                    ForEach(playlists) { playlist in
                        NavigationLink(value: playlist) {
                            PlaylistRow(playlist: playlist)
                        }
                        .listRowBackground(Color.black)
                        .listRowSeparatorTint(.white.opacity(0.08))
                    }
                    // Clear the mini player so the last row isn't hidden behind it.
                    Color.clear.frame(height: 72).listRowBackground(Color.black)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .navigationTitle("Playlists")
        .task { if case .loading = phase { await load() } }
    }

    private func load() async {
        phase = .loading
        do {
            var request = MusicLibraryRequest<Playlist>()
            request.limit = 100
            let response = try await request.response()
            phase = response.items.isEmpty ? .empty : .loaded(response.items)
        } catch {
            phase = .failed(error.localizedDescription)
        }
    }
}

private struct PlaylistRow: View {
    let playlist: Playlist

    var body: some View {
        HStack(spacing: 12) {
            ArtworkView(artwork: playlist.artwork, size: 52, systemFallback: "music.note.list")
            VStack(alignment: .leading, spacing: 3) {
                Text(playlist.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                if let curator = playlist.curatorName, !curator.isEmpty {
                    Text(curator)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
