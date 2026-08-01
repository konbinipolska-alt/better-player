import SwiftUI
import SwiftData
import UIKit
import DesignSystem

/// A single playlist: our own chrome header (back / title / ellipsis menu),
/// inline rename on long-press of the name, and the playlist's tracks as rows.
struct PlaylistDetailView: View {
    let playlist: Playlist
    let engine: PlayerEngine

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var showMenu = false
    @State private var isRenaming = false
    @State private var editingName = ""
    @FocusState private var nameFocused: Bool

    /// Reorder mode for the track list. `hasMoved` flips the reorder glyph to a
    /// checkmark once the first successful drag lands.
    @State private var isReordering = false
    @State private var hasMoved = false

    /// Observe the Favorites playlist so the per-row toggle icon (and the
    /// dashboard's "N songs" count) update the instant membership changes.
    @Query(filter: #Predicate<Playlist> { $0.isFavorites }) private var favorites: [Playlist]

    private var store: PlaylistStore { PlaylistStore(context) }

    private var favoriteIDs: Set<String> {
        Set(favorites.first?.items.map(\.catalogID) ?? [])
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.horizontal, DSSpacing.xl)
                    .padding(.top, DSSpacing.md)
                    .padding(.bottom, DSSpacing.sm)

                controlRow
                    .padding(.horizontal, DSSpacing.xl)
                    .padding(.bottom, DSSpacing.sm)

                tracks
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            if showMenu {
                menuOverlay
            }
        }
        .background(DSColor.canvas.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: Header

    private var header: some View {
        HStack(alignment: .center, spacing: DSSpacing.sm) {
            IconButton(systemName: "chevron.left") { dismiss() }
                .offset(x: -8) // optically align the glyph to the leading edge

            VStack(alignment: .leading, spacing: 2) {
                Eyebrow("Playlist")
                nameView
            }

            Spacer(minLength: DSSpacing.sm)

            IconButton(systemName: "ellipsis") {
                withAnimation(DSMotion.quick) { showMenu.toggle() }
            }
        }
    }

    @ViewBuilder private var nameView: some View {
        if isRenaming {
            TextField("Name", text: $editingName)
                .font(DSFont.title)
                .foregroundStyle(DSColor.textPrimary)
                .focused($nameFocused)
                .submitLabel(.done)
                .onSubmit { commitRename() }
                .onChange(of: nameFocused) { _, focused in
                    if !focused { commitRename() }
                }
        } else {
            Text(playlist.name)
                .font(DSFont.title)
                .foregroundStyle(DSColor.textPrimary)
                .lineLimit(1)
                .onLongPressGesture { beginRename() }
        }
    }

    // MARK: Control row

    /// Compact, right-aligned row of two chrome-less icon buttons just above the
    /// track list: cycle the player's playback mode, and toggle reorder mode.
    private var controlRow: some View {
        HStack(spacing: DSSpacing.sm) {
            Spacer(minLength: 0)

            IconButton(systemName: playbackModeIcon, tint: playbackModeTint) {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                engine.cyclePlaybackMode()
            }

            IconButton(systemName: reorderIcon,
                       tint: isReordering ? DSColor.textPrimary : DSColor.textSecondary) {
                toggleReorder()
            }
        }
    }

    private var playbackModeIcon: String {
        switch engine.playbackMode {
        case .loopAll: return "repeat"
        case .loopOne: return "repeat.1"
        case .shuffle: return "shuffle"
        }
    }

    /// Dim tint for the default (loopAll); primary for active non-default modes.
    private var playbackModeTint: Color {
        engine.playbackMode == .loopAll ? DSColor.textTertiary : DSColor.textPrimary
    }

    /// Arrows until the first move lands, then a checkmark ("done" affordance).
    private var reorderIcon: String {
        (isReordering && hasMoved) ? "checkmark" : "arrow.up.arrow.down"
    }

    // MARK: Tracks

    private var tracks: some View {
        let items = playlist.orderedItems
        return List {
            ForEach(items) { item in
                VStack(spacing: 0) {
                    TrackRowView(
                        engine: engine,
                        item: item,
                        isCurrent: isCurrent(item),
                        isFavorite: favoriteIDs.contains(item.catalogID),
                        isReordering: isReordering,
                        onTap: { play(item) },
                        onToggleFavorite: { toggleFavorite(item) }
                    )
                    if item.id != items.last?.id {
                        DSDivider().padding(.leading, 76)
                    }
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onMove(perform: moveRows)

            // Bottom breathing room so the mini-player pill never overlaps rows.
            Color.clear
                .frame(height: 160)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .environment(\.editMode, .constant(isReordering ? .active : .inactive))
        .animation(DSMotion.quick, value: isReordering)
    }

    // MARK: Menu

    private var menuOverlay: some View {
        ZStack(alignment: .topTrailing) {
            // Tap-catcher to dismiss.
            Color.black.opacity(0.001)
                .ignoresSafeArea()
                .onTapGesture { withAnimation(DSMotion.quick) { showMenu = false } }

            ContextDropdown(items: [
                ContextDropdownItem(title: "Delete", isDestructive: true) {
                    deletePlaylist()
                }
            ])
            .padding(.trailing, DSSpacing.xl)
            .padding(.top, 52)
        }
        .transition(.opacity)
    }

    // MARK: Reorder

    private func toggleReorder() {
        if isReordering {
            withAnimation(DSMotion.quick) { isReordering = false }
        } else {
            hasMoved = false
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            withAnimation(DSMotion.quick) { isReordering = true }
        }
    }

    /// Persist a drag immediately so the new order survives relaunch. Maps
    /// SwiftUI's insertion-index semantics onto `store.move(in:from:to:)`.
    private func moveRows(from source: IndexSet, to destination: Int) {
        guard let s = source.first else { return }
        let d = destination > s ? destination - 1 : destination
        store.move(in: playlist, from: s, to: d)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        hasMoved = true
    }

    // MARK: Actions

    private func beginRename() {
        editingName = playlist.name
        isRenaming = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { nameFocused = true }
    }

    private func commitRename() {
        guard isRenaming else { return }
        let trimmed = editingName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { store.rename(playlist, to: trimmed) }
        isRenaming = false
        nameFocused = false
    }

    private func deletePlaylist() {
        showMenu = false
        dismiss()
        // Delete after the pop so the view no longer reads the deleted model.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            store.delete(playlist)
        }
    }

    private func matchingEngineTrack(_ item: PlaylistItem) -> NowPlayingTrack? {
        engine.tracks.first {
            $0.id == item.catalogID || $0.id.hasPrefix(item.catalogID + "#")
        }
    }

    private func isCurrent(_ item: PlaylistItem) -> Bool {
        matchingEngineTrack(item)?.id == engine.track.id
    }

    private func play(_ item: PlaylistItem) {
        if let track = matchingEngineTrack(item) {
            engine.play(itemID: track.id)
        }
        // else: no matching engine track yet — no-op for now.
    }

    private func toggleFavorite(_ item: PlaylistItem) {
        store.toggleFavorite(catalogID: item.catalogID, title: item.title, artist: item.artist)
    }
}

/// Track row reusing the Playlists visual: circular thumb + title/artist, with
/// the animated equalizer on the currently-playing row.
private struct TrackRowView: View {
    let engine: PlayerEngine
    let item: PlaylistItem
    let isCurrent: Bool
    let isFavorite: Bool
    /// While reordering, rows are drag-only: tap-to-play and the favorite toggle
    /// are disabled.
    let isReordering: Bool
    let onTap: () -> Void
    let onToggleFavorite: () -> Void

    var body: some View {
        HStack(spacing: DSSpacing.md) {
            // Row body: tapping anywhere here plays the track (disabled while reordering).
            HStack(spacing: DSSpacing.md) {
                thumb
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(isCurrent ? DSColor.textPrimary : DSColor.textSecondary)
                        .lineLimit(1)
                    Text(item.artist)
                        .font(.system(size: 11, weight: .regular, design: .monospaced))
                        .foregroundStyle(DSColor.textTertiary)
                        .lineLimit(1)
                }
                Spacer(minLength: DSSpacing.sm)
            }
            .contentShape(Rectangle())
            .onTapGesture { if !isReordering { onTap() } }

            // Trailing slot: favorite add/remove toggle (hidden while reordering).
            if !isReordering {
                favoriteToggle
            }
        }
        .padding(.horizontal, DSSpacing.xl)
        .padding(.vertical, DSSpacing.sm)
    }

    private var favoriteToggle: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onToggleFavorite()
        } label: {
            Image(systemName: isFavorite ? "checkmark" : "plus")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isFavorite ? DSColor.textPrimary : DSColor.textTertiary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var thumb: some View {
        ZStack {
            Circle().fill(DSColor.surfaceRaised)
            if let artwork = engine.sharedArtwork {
                Image(uiImage: artwork).resizable().scaledToFill()
                    .hueRotation(.degrees(hue))
            } else {
                Image(systemName: "music.note")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(DSColor.textTertiary)
            }
            // Currently-playing row: dim the thumb and overlay the equalizer.
            if isCurrent {
                Color.black.opacity(0.35)
                PlayingIndicator(engine: engine)
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
    }

    /// Borrow the hue the engine assigned to the matching track so a shared
    /// cover still reads as distinct per track.
    private var hue: Double {
        engine.tracks.first {
            $0.id == item.catalogID || $0.id.hasPrefix(item.catalogID + "#")
        }?.artworkHue ?? 0
    }
}
