import Foundation
import SwiftData

/// A track inside a `Playlist`. `catalogID` is the stable, provider-scoped id of
/// the underlying track (for the mock provider this is the bundled file's base
/// name). CloudKit-friendly: all properties defaulted, relationship optional.
@Model
final class PlaylistItem {
    var id: UUID = UUID()
    var providerID: String = "mock"
    /// Stable track id within the provider (e.g. bundled file base name).
    var catalogID: String = ""
    var title: String = ""
    var artist: String = ""
    var artworkURL: String? = nil
    var order: Int = 0

    var playlist: Playlist? = nil

    init(
        id: UUID = UUID(),
        providerID: String = "mock",
        catalogID: String = "",
        title: String = "",
        artist: String = "",
        artworkURL: String? = nil,
        order: Int = 0,
        playlist: Playlist? = nil
    ) {
        self.id = id
        self.providerID = providerID
        self.catalogID = catalogID
        self.title = title
        self.artist = artist
        self.artworkURL = artworkURL
        self.order = order
        self.playlist = playlist
    }
}
