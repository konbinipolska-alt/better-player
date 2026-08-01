import SwiftUI
import DesignSystem

/// Top-level shell: three sections (Playlists / Search / Now Playing) selected
/// from a top header nav (no bottom tab bar). The persistent, interactive
/// mini-player pill is docked at the bottom safe area. Sections can also be
/// changed with a horizontal edge-swipe.
struct RootView: View {
    enum Section: Int, Hashable, CaseIterable {
        case playlists = 0, search, nowPlaying
        var title: String {
            switch self {
            case .playlists: "Playlists"
            case .search: "Search"
            case .nowPlaying: "Now Playing"
            }
        }
    }

    @State private var section: Section = .playlists
    @State private var engine = PlayerEngine()
    @State private var showFullPlayer = false

    // Edge-swipe paging: captured once per drag on the first `.onChanged`.
    @State private var swipeCaptured = false
    @State private var swipeEnabled = false

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                SectionHeaderNav(
                    sections: Section.allCases,
                    title: { $0.title },
                    selection: $section
                )
                .padding(.top, DSSpacing.sm)

                TimeReadout(engine: engine)

                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(DSColor.canvas.ignoresSafeArea())
            .overlay(alignment: .bottom) {
                // Dock the pill low: same margin from the bottom edge as from the
                // sides (DSSpacing.md). Offsetting down by the bottom safe-area
                // inset pushes it past the home-indicator gap so it truly sits low.
                MiniPlayerPill(engine: engine, onTapExpand: { showFullPlayer = true })
                    .padding(.horizontal, DSSpacing.md)
                    .padding(.bottom, DSSpacing.md)
                    .offset(y: geo.safeAreaInsets.bottom)
            }
            .contentShape(Rectangle())
            // Low-priority so the pill's own gesture (and any content) win their
            // touches; this only fires for drags they don't claim.
            .gesture(edgeSwipe(width: geo.size.width))
        }
        .fullScreenCover(isPresented: $showFullPlayer) {
            FullPlayerView(engine: engine)
        }
    }

    @ViewBuilder private var content: some View {
        switch section {
        case .playlists: PlaylistsView(engine: engine)
        case .search: SearchView()
        case .nowPlaying: NowPlayingView()
        }
    }

    // MARK: Edge-swipe paging

    private func edgeSwipe(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 20)
            .onChanged { value in
                guard !swipeCaptured else { return }
                swipeCaptured = true
                let x = value.startLocation.x
                // Must start near a screen edge AND not be scrubbing at touch-down.
                swipeEnabled = !engine.isScrubbing && (x < 24 || x > width - 24)
            }
            .onEnded { value in
                defer { swipeCaptured = false; swipeEnabled = false }
                guard swipeEnabled else { return }
                let w = value.translation.width
                let h = value.translation.height
                guard abs(w) > abs(h), abs(w) > 60 else { return }

                let cur = section.rawValue
                let target = max(0, min(Section.allCases.count - 1,
                                       w < 0 ? cur + 1 : cur - 1))
                if target != cur, let next = Section(rawValue: target) {
                    withAnimation(DSMotion.standard) { section = next }
                }
            }
    }
}

/// Small, centred playback readout under the header: `current / total`. During a
/// scrub the current side reflects the target position until the finger lifts.
private struct TimeReadout: View {
    let engine: PlayerEngine
    var body: some View {
        Text("\(Timecode.string(engine.displayTime)) / \(Timecode.string(engine.duration))")
            .font(DSFont.monoSmall)
            .foregroundStyle(DSColor.textTertiary)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, DSSpacing.xs)
            // Only visible while scrubbing; kept in layout to avoid a jump.
            .opacity(engine.isScrubbing ? 1 : 0)
            .animation(.easeInOut(duration: 0.15), value: engine.isScrubbing)
    }
}

#Preview {
    RootView().preferredColorScheme(.dark)
}
