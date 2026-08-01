import SwiftUI
import SwiftData
import DesignSystem

/// Root screen: a big "Playlists" title with a search trigger, over a scrollable
/// list of playlists (Favorites pinned first). Tapping a row pushes its detail.
/// The search icon enters an in-place search mode on this same screen.
struct PlaylistsDashboardView: View {
    let engine: PlayerEngine
    @Environment(\.modelContext) private var context

    @Query(sort: \Playlist.order, order: .forward) private var playlists: [Playlist]
    @Query private var allItems: [PlaylistItem]

    @State private var isSearching = false
    @State private var query = ""

    private var searchResults: [PlaylistItem] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return [] }
        let lower = q.lowercased()
        return allItems.filter { item in
            item.title.lowercased().contains(lower) || item.artist.lowercased().contains(lower)
        }.sorted { a, b in a.title.localizedCaseInsensitiveCompare(b.title) == .orderedAscending }
    }

    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, DSSpacing.xl)
                .padding(.top, DSSpacing.md)
                .padding(.bottom, DSSpacing.lg)

            if isSearching {
                if query.isEmpty {
                    // Empty state: show only the header with blinking caret (already rendered above).
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 0) {
                            ForEach(searchResults, id: \.id) { item in
                                SearchResultRow(item: item)
                                DSDivider().padding(.leading, DSSpacing.xl)
                            }
                        }
                        .padding(.bottom, 160)
                    }
                }
            } else {
                list
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DSColor.canvas.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Header

    @ViewBuilder private var header: some View {
        if isSearching {
            HStack(alignment: .center, spacing: DSSpacing.sm) {
                searchField
                Spacer(minLength: DSSpacing.sm)
                IconButton(systemName: "xmark") { exitSearch() }
            }
        } else {
            HStack(alignment: .firstTextBaseline, spacing: DSSpacing.sm) {
                Text("Playlists")
                    .font(DSFont.display)
                    .foregroundStyle(DSColor.textPrimary)
                Spacer(minLength: DSSpacing.sm)
                IconButton(systemName: "magnifyingglass") { enterSearch() }
                    .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] }
            }
        }
    }

    private var searchField: some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 4) {
                Text(query.isEmpty ? "Search" : query)
                    .font(DSFont.display)
                    .foregroundStyle(query.isEmpty ? DSColor.textTertiary : DSColor.textPrimary)
                    .lineLimit(1)
                BlinkingCaret()
            }
            // Invisible field that actually captures the keyboard.
            TextField("", text: $query)
                .focused($searchFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(.clear)
                .tint(.clear)
                .accessibilityLabel("Search")
                .opacity(0.02)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: List

    private var list: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(playlists.enumerated()), id: \.element.id) { index, playlist in
                    NavigationLink(value: playlist) {
                        PlaylistDashboardRow(playlist: playlist)
                    }
                    .buttonStyle(.plain)
                    if index < playlists.count - 1 {
                        DSDivider().padding(.leading, DSSpacing.xl)
                    }
                }
            }
            .padding(.bottom, 160)
        }
        .navigationDestination(for: Playlist.self) { playlist in
            PlaylistDetailView(playlist: playlist, engine: engine)
        }
    }

    // MARK: Search mode

    private func enterSearch() {
        withAnimation(DSMotion.quick) { isSearching = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            searchFocused = true
        }
    }

    private func exitSearch() {
        searchFocused = false
        query = ""
        withAnimation(DSMotion.quick) { isSearching = false }
    }
}

/// One dashboard row: playlist name + a "N songs" mono subtitle.
private struct PlaylistDashboardRow: View {
    let playlist: Playlist

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(playlist.name)
                    .font(DSFont.headline)
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
                Text("\(playlist.items.count) songs")
                    .font(DSFont.monoSmall)
                    .foregroundStyle(DSColor.textTertiary)
            }
            Spacer()
        }
        .padding(.horizontal, DSSpacing.xl)
        .padding(.vertical, DSSpacing.md)
        .contentShape(Rectangle())
    }
}

/// A thin 2pt white caret that blinks at roughly 1Hz.
struct BlinkingCaret: View {
    @State private var on = true
    var body: some View {
        RoundedRectangle(cornerRadius: 1)
            .fill(Color.white)
            .frame(width: 2, height: 30)
            .opacity(on ? 1 : 0)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    on = false
                }
            }
    }
}

/// One search result row: track title + artist, with a trailing add/remove toggle to Favorites.
private struct SearchResultRow: View {
    @Environment(\.modelContext) private var context
    let item: PlaylistItem

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(DSFont.headline)
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
                Text(item.artist)
                    .font(DSFont.monoSmall)
                    .foregroundStyle(DSColor.textTertiary)
                    .lineLimit(1)
            }
            Spacer()
            FavoriteToggle(catalogID: item.catalogID, title: item.title, artist: item.artist)
        }
        .padding(.horizontal, DSSpacing.xl)
        .padding(.vertical, DSSpacing.md)
        .contentShape(Rectangle())
    }
}

/// Heart toggle that adds/removes a track from the Favorites playlist.
private struct FavoriteToggle: View {
    @Environment(\.modelContext) private var context
    let catalogID: String
    let title: String
    let artist: String

    @State private var isFav: Bool = false

    var body: some View {
        let store = PlaylistStore(context)
        // Keep local state in sync on appear.
        let _ = _onAppearUpdate()
        Button {
            store.toggleFavorite(catalogID: catalogID, title: title, artist: artist)
            isFav = store.isFavorite(catalogID: catalogID)
        } label: {
            Image(systemName: isFav ? "heart.fill" : "heart")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isFav ? DSColor.textPrimary : DSColor.textSecondary)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func _onAppearUpdate() {
        // Update the local favorite state when the view appears.
        DispatchQueue.main.async {
            let store = PlaylistStore(context)
            self.isFav = store.isFavorite(catalogID: catalogID)
        }
    }
}
