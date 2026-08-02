import MusicKit
import Observation

/// Owns Apple Music authorization state and reduces MusicKit's four raw statuses
/// into the three the UI cares about: checking → authorized / unauthorized.
@MainActor
@Observable
final class MusicAuthModel {
    enum Status { case checking, authorized, unauthorized }

    private(set) var status: Status = .checking

    /// Called once at launch. If the user has never been asked, prompt now;
    /// otherwise reflect the stored decision.
    func refresh() async {
        switch MusicAuthorization.currentStatus {
        case .authorized:
            status = .authorized
        case .notDetermined:
            status = (await MusicAuthorization.request()) == .authorized ? .authorized : .unauthorized
        default:
            status = .unauthorized
        }
    }

    /// Triggered by the Connect button on the auth gate.
    func request() async {
        status = (await MusicAuthorization.request()) == .authorized ? .authorized : .unauthorized
    }
}
