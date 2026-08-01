import SwiftUI
import SwiftData
import DesignSystem

/// Top-level shell. A `NavigationStack` drives the playlists dashboard → detail
/// flow using our own chrome (the system nav bar is hidden per-screen). The
/// persistent, interactive mini-player pill is docked at the bottom safe area
/// and **morphs in place** into the full player: a single interruptible spring
/// (`DSMotion.expand`) drives a `matchedGeometryEffect` on the artwork so it
/// flies/scales from the pill's thumb to the large cover, while the surrounding
/// Now Playing chrome settles in during the same spring. No `.fullScreenCover`,
/// so there is no present/dismiss cross-fade.
struct RootView: View {
    @Environment(\.modelContext) private var context

    @State private var engine = PlayerEngine()
    @State private var isExpanded = false
    @Namespace private var morph

    var body: some View {
        GeometryReader { geo in
            ZStack {
                NavigationStack {
                    PlaylistsDashboardView(engine: engine)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(DSColor.canvas.ignoresSafeArea())

                // Docked pill — hidden while expanded. Its artwork is the matched
                // source that flies up into the full player.
                if !isExpanded {
                    MiniPlayerPill(engine: engine, morph: morph, onTapExpand: {
                        withAnimation(DSMotion.expand) { isExpanded = true }
                    })
                    .padding(.horizontal, DSSpacing.lg)
                    .padding(.bottom, 20)
                    .offset(y: geo.safeAreaInsets.bottom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .transition(.opacity)
                }

                // Expanded Now Playing — custom in-place morph, on top of everything.
                if isExpanded {
                    FullPlayerView(engine: engine, morph: morph, collapse: {
                        withAnimation(DSMotion.expand) { isExpanded = false }
                    })
                    .transition(.opacity)
                }
            }
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
