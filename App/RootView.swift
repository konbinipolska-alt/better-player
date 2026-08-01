import SwiftUI
import DesignSystem

/// Top-level shell: three destinations (Playlists / Search / Now Playing)
/// with the persistent mini-player pill docked above the tab bar.
struct RootView: View {
    enum Tab: Hashable { case playlists, search, nowPlaying }
    @State private var tab: Tab = .playlists

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
            // Static preview of the signature pill. The gesture engine + real
            // playback arrive in Phase 3; this validates the design tokens now.
            MiniPlayerPill(track: .sample, progress: 0.38)
                .padding(.horizontal, DSSpacing.md)
                .padding(.bottom, DSSpacing.sm)
        }
    }
}

#Preview {
    RootView().preferredColorScheme(.dark)
}
