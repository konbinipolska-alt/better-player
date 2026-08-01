import SwiftUI
import UIKit
import Observation
import AVFoundation

/// Drives playback for the UI. For local testing it plays bundled audio through
/// `AVAudioPlayer`. Phase 3 swaps the audio source for `ApplicationMusicPlayer`
/// (MusicKit) behind this same surface.
@MainActor
@Observable
final class PlayerEngine {
    private(set) var track: NowPlayingTrack
    private(set) var currentTime: Double = 0
    private(set) var isPlaying: Bool = false

    // Scrub state.
    private(set) var isScrubbing = false
    private(set) var scrubTargetTime: Double = 0
    private(set) var scrubRate: ScrubRate = .base

    /// Cover art for the current track (its own embedded art, else the shared cover).
    private(set) var artwork: UIImage?
    /// First embedded cover found — reused for tracks that carry no art of their own.
    private(set) var fallbackArtwork: UIImage?

    /// Live audio level (0…1, peak) driving the playing indicator's beat pulse.
    private(set) var level: Double = 0

    /// The playlist backing the player.
    var tracks: [NowPlayingTrack] { queue }
    /// Cover to show in list rows (the shared Konbini cover), tinted per track.
    var sharedArtwork: UIImage? { fallbackArtwork ?? artwork }

    var duration: Double { player?.duration ?? 0 }

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
        let base = Self.discoverTracks()
        if base.isEmpty {
            queue = [NowPlayingTrack(id: "none", title: "No audio", artist: "Konbini", resource: nil)]
        } else {
            // Repeat the tracks (alternating) into a longer, scrollable playlist —
            // each item gets a UNIQUE id so only the actually-playing row is marked.
            queue = (0..<24).map { i in
                let t = base[i % base.count]
                return NowPlayingTrack(id: "\(t.id)#\(i)", title: t.title, artist: t.artist,
                                       resource: t.resource, artworkHue: t.artworkHue)
            }
        }
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

    /// Play a specific track from the playlist (tapped in the Playlists list).
    func play(itemID: String) {
        guard let i = queue.firstIndex(where: { $0.id == itemID }) else { return }
        load(index: i, autoplay: true)
    }

    // MARK: Scrubbing

    func beginScrub() {
        isScrubbing = true
        scrubTargetTime = currentTime
        scrubRate = .base
    }

    /// Update the scrub target only — the audio is NOT seeked here, so there's no
    /// audible scrubbing. The seek happens once, on release (`endScrub`).
    func updateScrub(horizontalDelta: CGFloat, verticalUp: CGFloat, secondsPerPoint: Double) {
        scrubRate = ScrubRate.forVerticalOffset(verticalUp)
        let delta = Double(horizontalDelta) * secondsPerPoint * scrubRate.factor
        scrubTargetTime = max(0, min(duration, scrubTargetTime + delta))
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
            Bundle.main.url(forResource: $0, withExtension: "mp3")
                ?? Bundle.main.url(forResource: $0, withExtension: "m4a")
                ?? Bundle.main.url(forResource: $0, withExtension: "wav")
        }
        if let url, let p = try? AVAudioPlayer(contentsOf: url) {
            p.delegate = delegate
            p.isMeteringEnabled = true
            p.prepareToPlay()
            player = p
        } else {
            player = nil
        }
        artwork = fallbackArtwork          // show the shared cover immediately
        if let url { loadArtwork(from: url) }
        currentTime = 0
        level = 0
        if autoplay { play() } else { isPlaying = false }
    }

    /// Builds the queue from any audio files bundled in the app (mp3/m4a/wav),
    /// so adding your own tracks is just dropping files into App/Resources/Audio.
    /// Tracks after the first get a distinct hue so a shared cover still reads
    /// as different at a glance.
    private static func discoverTracks() -> [NowPlayingTrack] {
        var urls: [URL] = []
        for ext in ["mp3", "m4a", "wav"] {
            urls += Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? []
        }
        let sorted = urls.sorted {
            $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending
        }
        return sorted.enumerated().map { idx, url in
            let base = url.deletingPathExtension().lastPathComponent
            let title = base
                .replacingOccurrences(of: "-", with: " ")
                .replacingOccurrences(of: "_", with: " ")
            let hue = idx == 0 ? 0.0 : Double((idx * 150) % 360)
            return NowPlayingTrack(id: base, title: title, artist: "Konbini",
                                   resource: base, artworkHue: hue)
        }
    }

    // MARK: Artwork

    private func loadArtwork(from url: URL) {
        Task { [weak self] in
            let img = await Self.extractArtwork(AVURLAsset(url: url))
            guard let self else { return }
            if let img {
                if self.fallbackArtwork == nil { self.fallbackArtwork = img }
                self.artwork = img
            } else {
                self.artwork = self.fallbackArtwork
            }
        }
    }

    private nonisolated static func extractArtwork(_ asset: AVURLAsset) async -> UIImage? {
        guard let items = try? await asset.load(.commonMetadata) else { return nil }
        let art = AVMetadataItem.metadataItems(from: items, filteredByIdentifier: .commonIdentifierArtwork)
        guard let item = art.first, let data = try? await item.load(.dataValue) else { return nil }
        return UIImage(data: data)
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
        if p.isPlaying {
            p.updateMeters()
            let peak = Double(p.peakPower(forChannel: 0))   // dB, ~-160…0
            level = max(0, min(1, (peak + 40) / 40))
        } else if level != 0 {
            level = 0
        }
    }
}

/// AVAudioPlayer delegate bridged to a main-actor callback (advance on finish).
private final class PlayerDelegate: NSObject, AVAudioPlayerDelegate {
    var onFinish: (() -> Void)?
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.onFinish?() }
    }
}
