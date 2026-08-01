import SwiftUI
import DesignSystem

/// Top-level shell: three destinations (Playlists / Search / Now Playing)
/// with the persistent, interactive mini-player pill docked above the tab bar.
struct RootView: View {
    enum Tab: Hashable { case playlists, search, nowPlaying }
    @State private var tab: Tab = .playlists
    @State private var engine = PlayerEngine()
    @State private var showFullPlayer = false

    var body: some View {
        TabView(selection: $tab) {
            PlaylistsView()
                .tabItem { Label("Playlists", systemImage: "square.stack") }
                .tag(Tab.playlists)

            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
                .tag(Tab.search)

            NowPlayingView()
                .tabItem { Label("Now Playing", systemImage: "waveform") }
                .tag(Tab.nowPlaying)
        }
        .tint(DSColor.accent)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MiniPlayerPill(engine: engine, onTapExpand: { showFullPlayer = true })
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, DSSpacing.sm)
        }
        .fullScreenCover(isPresented: $showFullPlayer) {
            FullPlayerView(engine: engine)
        }
    }
}

#Preview {
    RootView().preferredColorScheme(.dark)
}
