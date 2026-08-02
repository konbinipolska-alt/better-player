import SwiftUI
import MusicKit

@main
struct BetterPlayerApp: App {
    @State private var auth = MusicAuthModel()
    @State private var player = PlayerModel()

    var body: some Scene {
        WindowGroup {
            RootView(auth: auth, player: player)
                .preferredColorScheme(.dark)
        }
    }
}

/// Top-level flow: auth gate → library. The mini player docks over the library
/// once something is queued; tapping it presents the full Now Playing sheet.
struct RootView: View {
    let auth: MusicAuthModel
    let player: PlayerModel

    @State private var path: [Playlist] = []
    @State private var showNowPlaying = false

    var body: some View {
        Group {
            switch auth.status {
            case .checking:
                ProgressView()
                    .tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)

            case .unauthorized:
                AuthGateView(auth: auth)

            case .authorized:
                NavigationStack(path: $path) {
                    LibraryView(player: player)
                        .navigationDestination(for: Playlist.self) { playlist in
                            PlaylistDetailView(playlist: playlist, player: player)
                        }
                }
                .overlay(alignment: .bottom) {
                    if player.hasCurrentEntry {
                        MiniPlayerBar(player: player) { showNowPlaying = true }
                            .padding(.horizontal, 12)
                            .padding(.bottom, 8)
                    }
                }
                .sheet(isPresented: $showNowPlaying) {
                    NowPlayingView(player: player)
                }
            }
        }
        .task { await auth.refresh() }
    }
}
