import Foundation

/// Identifies a backing music service. Apple Music is the only implementation
/// for now; `spotify` (and `mixed` orchestration) are reserved so the app can
/// grow without reworking the seam.
enum ProviderID: String, Sendable {
    case appleMusic
    case spotify
}

/// Normalized authorization state across providers.
enum ProviderAuthStatus: Sendable {
    case notDetermined
    case denied
    case restricted
    case authorized
}

/// The abstraction every music backend conforms to. Kept intentionally small in
/// Phase 0 — search, library, playback and playlist operations are added in
/// their respective phases (2–4). This exists now to establish the boundary so
/// features never import MusicKit directly.
protocol MusicProvider: AnyObject, Sendable {
    var id: ProviderID { get }

    /// Ask the user for permission to use this provider.
    func requestAuthorization() async -> ProviderAuthStatus

    /// Whether the signed-in account can actually stream (e.g. an active
    /// Apple Music subscription).
    func canPlayback() async -> Bool
}
