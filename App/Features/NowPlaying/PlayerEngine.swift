import SwiftUI
import Observation

/// Drives playback state for the UI. During scaffolding this is a **simulated
/// clock** so the scrub interaction can be built and felt before MusicKit is
/// wired in. Phase 3 swaps the internal clock for `ApplicationMusicPlayer`
/// (currentTime/duration/transport) without changing this surface.
@MainActor
@Observable
final class PlayerEngine {
    private(set) var track: NowPlayingTrack
    private(set) var currentTime: Double
    private(set) var isPlaying: Bool = true

    // Scrub state.
    private(set) var isScrubbing = false
    private(set) var scrubTargetTime: Double = 0
    private(set) var scrubRate: ScrubRate = .hiSpeed

    var duration: Double { track.duration }

    /// Fraction to render in the pill: the scrub target while scrubbing,
    /// otherwise the live playhead.
    var displayProgress: Double {
        let t = isScrubbing ? scrubTargetTime : currentTime
        return duration > 0 ? max(0, min(1, t / duration)) : 0
    }

    var displayTime: Double { isScrubbing ? scrubTargetTime : currentTime }

    // Simulated-clock backing.
    private var timer: Timer?
    private let queue: [NowPlayingTrack]
    private var index: Int

    init() {
        let q: [NowPlayingTrack] = [
            NowPlayingTrack(id: "1", title: "Nightlight", artist: "Konbini", duration: 214),
            NowPlayingTrack(id: "2", title: "Amber Static", artist: "Konbini", duration: 187),
            NowPlayingTrack(id: "3", title: "Low Orbit", artist: "Konbini", duration: 246),
        ]
        self.queue = q
        self.index = 0
        self.track = q[0]
        self.currentTime = 82   // start mid-track so the pill shows progress
        startClock()
    }

    // MARK: Transport

    func togglePlayPause() {
        isPlaying.toggle()
        isPlaying ? startClock() : stopClock()
    }

    func next() {
        index = (index + 1) % queue.count
        loadCurrent()
    }

    func previous() {
        // If we're a few seconds in, restart the track (like most players);
        // otherwise go to the previous one.
        if currentTime > 3 {
            currentTime = 0
        } else {
            index = (index - 1 + queue.count) % queue.count
            loadCurrent()
        }
    }

    private func loadCurrent() {
        track = queue[index]
        currentTime = 0
        if isPlaying { startClock() }
    }

    // MARK: Scrubbing

    func beginScrub() {
        isScrubbing = true
        scrubTargetTime = currentTime
        scrubRate = .hiSpeed
        stopClock()
    }

    /// Apply an incremental horizontal delta (points) at the current rate, and
    /// update the rate tier from upward vertical travel (points, positive = up).
    func updateScrub(horizontalDelta: CGFloat, verticalUp: CGFloat, secondsPerPoint: Double) {
        scrubRate = ScrubRate.forVerticalOffset(verticalUp)
        let deltaSeconds = Double(horizontalDelta) * secondsPerPoint * scrubRate.factor
        scrubTargetTime = max(0, min(duration, scrubTargetTime + deltaSeconds))
    }

    func endScrub(commit: Bool) {
        if commit { currentTime = scrubTargetTime }
        isScrubbing = false
        if isPlaying { startClock() }
    }

    /// Direct seek by fraction (0…1) — used by the full player's scrub bar.
    func seek(toFraction f: Double) {
        currentTime = max(0, min(duration, f * duration))
    }

    // MARK: Simulated clock

    private func startClock() {
        stopClock()
        guard isPlaying else { return }
        let t = Timer(timeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.tick(0.25) }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func stopClock() {
        timer?.invalidate()
        timer = nil
    }

    private func tick(_ dt: Double) {
        guard isPlaying, !isScrubbing else { return }
        currentTime += dt
        if currentTime >= duration { next() }
    }
}
