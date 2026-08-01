import Foundation
import SwiftData

/// Thin CRUD facade over the SwiftData `ModelContext` for playlists and their
/// items. All mutations run on the main actor and persist immediately.
@MainActor
struct PlaylistStore {
    let context: ModelContext

    init(_ context: ModelContext) {
        self.context = context
    }

    // MARK: Seeding

    /// On first launch (no playlists yet), create the pinned **Favorites**
    /// playlist plus a **Konbini** playlist holding the two real tracks.
    func seedIfNeeded() {
        let existing = (try? context.fetch(FetchDescriptor<Playlist>())) ?? []
        guard existing.isEmpty else { return }

        let favorites = Playlist(name: "Favorites", isFavorites: true, order: 0)
        context.insert(favorites)

        let konbini = Playlist(name: "Konbini", order: 1)
        context.insert(konbini)

        let seed: [(catalogID: String, title: String)] = [
            ("Automatic-Doors-Open-Wide", "Automatic Doors Open Wide"),
            ("konbini-groove-remix", "konbini groove remix"),
        ]
        for (i, t) in seed.enumerated() {
            let item = PlaylistItem(
                providerID: "mock",
                catalogID: t.catalogID,
                title: t.title,
                artist: "Konbini",
                order: i,
                playlist: konbini
            )
            context.insert(item)
        }

        save()
    }

    // MARK: Playlist CRUD

    @discardableResult
    func createPlaylist(name: String) -> Playlist {
        let order = nextPlaylistOrder()
        let playlist = Playlist(name: name, order: order)
        context.insert(playlist)
        save()
        return playlist
    }

    func rename(_ playlist: Playlist, to name: String) {
        playlist.name = name
        save()
    }

    func delete(_ playlist: Playlist) {
        context.delete(playlist)
        save()
    }

    // MARK: Item CRUD

    func addItem(_ item: PlaylistItem, to playlist: Playlist) {
        item.order = playlist.items.count
        item.playlist = playlist
        context.insert(item)
        save()
    }

    func removeItem(_ item: PlaylistItem) {
        let playlist = item.playlist
        context.delete(item)
        if let playlist { normalizeOrder(playlist) }
        save()
    }

    /// Reorder an item within a playlist, keeping `order` contiguous (0..<n).
    func move(in playlist: Playlist, from source: Int, to destination: Int) {
        var ordered = playlist.orderedItems
        guard ordered.indices.contains(source) else { return }
        let clamped = max(0, min(destination, ordered.count - 1))
        let item = ordered.remove(at: source)
        ordered.insert(item, at: clamped)
        for (i, it) in ordered.enumerated() { it.order = i }
        save()
    }

    // MARK: Favorites

    /// Add the track to Favorites if absent, otherwise remove it. Creates the
    /// Favorites playlist on demand if it somehow doesn't exist.
    func toggleFavorite(catalogID: String, title: String, artist: String) {
        let favorites = favoritesPlaylist()
        if let existing = favorites.items.first(where: { $0.catalogID == catalogID }) {
            context.delete(existing)
            normalizeOrder(favorites)
        } else {
            let item = PlaylistItem(
                catalogID: catalogID,
                title: title,
                artist: artist,
                order: favorites.items.count,
                playlist: favorites
            )
            context.insert(item)
        }
        save()
    }

    func isFavorite(catalogID: String) -> Bool {
        favoritesPlaylist().items.contains { $0.catalogID == catalogID }
    }

    // MARK: Helpers

    private func favoritesPlaylist() -> Playlist {
        let descriptor = FetchDescriptor<Playlist>(
            predicate: #Predicate { $0.isFavorites }
        )
        if let found = (try? context.fetch(descriptor))?.first {
            return found
        }
        let favorites = Playlist(name: "Favorites", isFavorites: true, order: 0)
        context.insert(favorites)
        return favorites
    }

    private func nextPlaylistOrder() -> Int {
        let all = (try? context.fetch(FetchDescriptor<Playlist>())) ?? []
        return (all.map(\.order).max() ?? 0) + 1
    }

    private func normalizeOrder(_ playlist: Playlist) {
        for (i, it) in playlist.orderedItems.enumerated() { it.order = i }
    }

    private func save() {
        try? context.save()
    }
}
