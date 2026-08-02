import Foundation
import MusicKit
import Observation

/// The playback core. Wraps `ApplicationMusicPlayer` (Apple Music's in-app player)
/// and mirrors its out-of-process state into observable properties SwiftUI can
/// bind to. Deliberately contains **no** `AVAudioSession`/`AVAudioPlayer` — the
/// system player owns audio output; touching the session here only fights it.
@MainActor
@Observable
final class PlayerModel {
    private let player = ApplicationMusicPlayer.shared

    // Mirrored state.
    private(set) var isPlaying = false
    private(set) var hasCurrentEntry = false
    private(set) var title = ""
    private(set) var artist = ""
    private(set) var artwork: Artwork?
    private(set) var duration: TimeInterval = 0
    private(set) var playbackTime: TimeInterval = 0
    private(set) var lastError: String?

    /// Normalised 0…1 position for progress UI.
    var progress: Double {
        guard duration > 0 else { return 0 }
        return min(1, max(0, playbackTime / duration))
    }

    private var ticker: Task<Void, Never>?
    private var currentEntryKey: String?

    init() { startTicker() }

    // MARK: Commands

    /// Queue `tracks` (a playlist's tracks) starting at `track`, and play.
    func play(_ tracks: MusicItemCollection<Track>, startingAt track: Track) async {
        lastError = nil
        player.queue = ApplicationMusicPlayer.Queue(for: tracks, startingAt: track)
        do {
            try await player.play()
        } catch {
            lastError = error.localizedDescription
        }
        sync()
    }

    func togglePlayPause() async {
        do {
            if player.state.playbackStatus == .playing {
                player.pause()
            } else {
                try await player.play()
            }
        } catch {
            lastError = error.localizedDescription
        }
        sync()
    }

    func skipToNext() async {
        try? await player.skipToNextEntry()
        sync()
    }

    func skipToPrevious() async {
        // Match Apple Music: restart the track first, only jump back near the start.
        if playbackTime > 3 {
            player.playbackTime = 0
            playbackTime = 0
        } else {
            try? await player.skipToPreviousEntry()
        }
        sync()
    }

    func seek(to time: TimeInterval) {
        let clamped = max(0, min(time, duration))
        player.playbackTime = clamped
        playbackTime = clamped
    }

    // MARK: State mirroring

    /// A gentle poll keeps `playbackTime`/`isPlaying` fresh (the player publishes
    /// neither continuously) and detects track changes to refresh metadata.
    private func startTicker() {
        ticker = Task { [weak self] in
            while !Task.isCancelled {
                self?.sync()
                try? await Task.sleep(for: .milliseconds(400))
            }
        }
    }

    private func sync() {
        isPlaying = player.state.playbackStatus == .playing
        playbackTime = player.playbackTime

        let entry = player.queue.currentEntry
        hasCurrentEntry = entry != nil
        let key = entry.map { "\($0.id)" }
        guard key != currentEntryKey else { return }
        currentEntryKey = key

        title = entry?.title ?? ""
        artist = entry?.subtitle ?? ""
        artwork = entry?.artwork
        duration = 0
        if let item = entry?.item, case let .song(song) = item {
            duration = song.duration ?? 0
        }
    }
}
