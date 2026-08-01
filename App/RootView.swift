import SwiftUI
import SwiftData
import DesignSystem

/// Top-level shell. A `NavigationStack` drives the playlists dashboard → detail
/// flow using our own chrome (the system nav bar is hidden per-screen). The
/// persistent, interactive mini-player pill is docked at the bottom safe area
/// and expands into the full player.
struct RootView: View {
    @Environment(\.modelContext) private var context

    @State private var engine = PlayerEngine()
    @State private var showFullPlayer = false

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                PlaylistsDashboardView(engine: engine)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DSColor.canvas.ignoresSafeArea())
            .overlay(alignment: .bottom) {
                MiniPlayerPill(engine: engine, onTapExpand: { showFullPlayer = true })
                    .padding(.horizontal, DSSpacing.lg)
                    .padding(.bottom, 20)
                    .offset(y: geo.safeAreaInsets.bottom)
            }
        }
        .fullScreenCover(isPresented: $showFullPlayer) {
            FullPlayerView(engine: engine)
        }
        .task {
            PlaylistStore(context).seedIfNeeded()
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Playlist.self, PlaylistItem.self], inMemory: true)
        .preferredColorScheme(.dark)
}
