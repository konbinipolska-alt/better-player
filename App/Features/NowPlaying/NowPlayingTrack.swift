import Foundation

/// Lightweight, provider-agnostic representation of what's currently loaded in
/// the player. Real data is mapped from MusicKit in Phase 3; a `.sample` is used
/// to drive the static pill during scaffolding.
struct NowPlayingTrack: Equatable, Identifiable {
    let id: String
    let title: String
    let artist: String
    let duration: Double   // seconds

    static let sample = NowPlayingTrack(
        id: "sample",
        title: "Nightlight",
        artist: "Konbini",
        duration: 214
    )
}
