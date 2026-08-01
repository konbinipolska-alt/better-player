import SwiftUI
import Observation
import AVFoundation

/// Drives playback for the UI. For local testing it plays bundled, procedurally
/// generated samples through `AVAudioPlayer` — so scrubbing is *audible*. Phase 3
/// swaps the audio source for `ApplicationMusicPlayer` (MusicKit) behind this
/// same surface.
@MainActor
@Observable
final class PlayerEngine {
    private(set) var track: NowPlayingTrack
    private(set) var currentTime: Double = 0
    private(set) var isPlaying: Bool = false

    // Scrub state.
    private(set) var isScrubbing = false
    private(set) var scrubTargetTime: Double = 0
    private(set) var scrubRate: ScrubRate = .hiSpeed

    var duration: Double { player?.duration ?? 0 }

    /// Fraction to render in the pill: the scrub target while scrubbing, else the playhead.
    var displayProgress: Double {
        guard duration > 0 else { return 0 }
        return max(0, min(1, displayTime / duration))
    }
    var displayTime: Double { isScrubbing ? scrubTargetTime : currentTime }

    private var player: AVAudioPlayer?
    private var display: Timer?
    private let queue: [NowPlayingTrack]
    private var index = 0
    private let delegate = PlayerDelegate()

    init() {
        queue = [
            NowPlayingTrack(id: "1", title: "Nightlight",   artist: "Konbini", resource: "sample_nightlight"),
            NowPlayingTrack(id: "2", title: "Amber Static", artist: "Konbini", resource: "sample_amber"),
            NowPlayingTrack(id: "3", title: "Low Orbit",    artist: "Konbini", resource: "sample_orbit"),
        ]
        track = queue[0]
        configureSession()
        delegate.onFinish = { [weak self] in self?.next() }
        load(index: 0, autoplay: false)   // silent on launch; user taps play
        startDisplay()
    }

    // MARK: Transport

    func play() {
        guard player != nil else { return }
        player?.play()
        isPlaying = true
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func togglePlayPause() { isPlaying ? pause() : play() }

    func next() { load(index: index + 1, autoplay: true) }

    func previous() {
        if currentTime > 3 {
            seekSeconds(0)
        } else {
            load(index: index - 1, autoplay: true)
        }
    }

    // MARK: Scrubbing

    func beginScrub() {
        isScrubbing = true
        scrubTargetTime = currentTime
        scrubRate = .hiSpeed
    }

    /// Incremental horizontal delta (points) at the current rate; rate tier from
    /// upward vertical travel. Seeks the player live so the scrub is audible.
    func updateScrub(horizontalDelta: CGFloat, verticalUp: CGFloat, secondsPerPoint: Double) {
        scrubRate = ScrubRate.forVerticalOffset(verticalUp)
        let delta = Double(horizontalDelta) * secondsPerPoint * scrubRate.factor
        scrubTargetTime = max(0, min(duration, scrubTargetTime + delta))
        player?.currentTime = scrubTargetTime
        currentTime = scrubTargetTime
    }

    func endScrub(commit: Bool) {
        if commit { seekSeconds(scrubTargetTime) }
        isScrubbing = false
    }

    /// Direct seek by fraction (0…1) — used by the full player's scrub bar.
    func seek(toFraction f: Double) { seekSeconds(f * duration) }

    private func seekSeconds(_ t: Double) {
        let c = max(0, min(duration, t))
        player?.currentTime = c
        currentTime = c
    }

    // MARK: Loading

    private func load(index i: Int, autoplay: Bool) {
        let count = queue.count
        index = ((i % count) + count) % count
        track = queue[index]

        let url = track.resource.flatMap {
            Bundle.main.url(forResource: $0, withExtension: "m4a")
                ?? Bundle.main.url(forResource: $0, withExtension: "wav")
        }
        if let url, let p = try? AVAudioPlayer(contentsOf: url) {
            p.delegate = delegate
            p.prepareToPlay()
            player = p
        } else {
            player = nil
        }
        currentTime = 0
        if autoplay { play() } else { isPlaying = false }
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        try? session.setActive(true)
    }

    // MARK: Display refresh

    private func startDisplay() {
        display?.invalidate()
        let t = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.refresh() }
        }
        RunLoop.main.add(t, forMode: .common)
        display = t
    }

    private func refresh() {
        guard let p = player, !isScrubbing else { return }
        currentTime = p.currentTime
        if isPlaying != p.isPlaying { isPlaying = p.isPlaying }
    }
}

/// AVAudioPlayer delegate bridged to a main-actor callback (advance on finish).
private final class PlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onFinish: (() -> Void)?
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.onFinish?() }
    }
}
