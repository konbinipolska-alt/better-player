import Foundation
import Observation

#if canImport(MusicKit)
import MusicKit
#endif

@MainActor
@Observable
final class MusicAuthManager {
    enum Status {
        case notDetermined
        case denied
        case restricted
        case authorized
    }

    private(set) var status: Status = .notDetermined

    var shouldPrompt: Bool {
        switch status {
        case .authorized: return false
        case .restricted: return false // don't prompt if restricted by system
        case .notDetermined, .denied: return true
        }
    }

    func refreshStatus() {
        #if canImport(MusicKit)
        switch MusicAuthorization.currentStatus {
        case .notDetermined: status = .notDetermined
        case .denied: status = .denied
        case .restricted: status = .restricted
        case .authorized: status = .authorized
        @unknown default: status = .notDetermined
        }
        #else
        status = .authorized
        #endif
    }

    func requestAuthorization() async {
        #if canImport(MusicKit)
        let s = await MusicAuthorization.request()
        switch s {
        case .notDetermined: status = .notDetermined
        case .denied: status = .denied
        case .restricted: status = .restricted
        case .authorized: status = .authorized
        @unknown default: status = .notDetermined
        }
        #else
        status = .authorized
        #endif
    }
}
