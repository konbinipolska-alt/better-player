import SwiftUI

struct NowPlayingView: View {
    var body: some View {
        PlaceholderScreen(
            eyebrow: "Player",
            title: "Now Playing",
            note: "Full player with the large scrubber.\nPhase 3–4.",
            systemImage: "waveform"
        )
    }
}

#Preview { NowPlayingView().preferredColorScheme(.dark) }
