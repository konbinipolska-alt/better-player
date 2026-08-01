import SwiftUI

struct NowPlayingView: View {
    var body: some View {
        PlaceholderScreen(
            note: "Full player with the large scrubber.\nPhase 3–4.",
            systemImage: "waveform"
        )
    }
}

#Preview { NowPlayingView().preferredColorScheme(.dark) }
