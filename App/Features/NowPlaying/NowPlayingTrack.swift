import Foundation

/// Lightweight, provider-agnostic representation of what's loaded in the player.
/// `resource` is the base name of a bundled audio file used for local testing;
/// Phase 3 maps these from MusicKit instead.
struct NowPlayingTrack: Equatable, Identifiable {
    let id: String
    let title: String
    let artist: String
    /// Bundled audio file base name (no extension), or nil once real catalog
    /// items back the player.
    let resource: String?
}
