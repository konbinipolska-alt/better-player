import Foundation
import SwiftData

/// A user playlist. CloudKit-friendly: every property has a default, the
/// relationship is optional, and there are no unique constraints.
@Model
final class Playlist {
    var id: UUID = UUID()
    var name: String = ""
    /// The single, non-deletable "Favorites" playlist is flagged here.
    var isFavorites: Bool = false
    /// Sort position in the dashboard (Favorites is pinned at 0).
    var order: Int = 0
    var createdAt: Date = Date.now

    @Relationship(deleteRule: .cascade, inverse: \PlaylistItem.playlist)
    var items: [PlaylistItem] = []

    init(
        id: UUID = UUID(),
        name: String = "",
        isFavorites: Bool = false,
        order: Int = 0,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.isFavorites = isFavorites
        self.order = order
        self.createdAt = createdAt
    }

    /// Items in their stored order.
    var orderedItems: [PlaylistItem] {
        items.sorted { $0.order < $1.order }
    }
}
