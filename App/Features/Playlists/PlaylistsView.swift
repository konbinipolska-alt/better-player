import SwiftUI

struct PlaylistsView: View {
    var body: some View {
        PlaceholderScreen(
            note: "Your library and playlists land here.\nPhase 4.",
            systemImage: "square.stack"
        )
    }
}

#Preview { PlaylistsView().preferredColorScheme(.dark) }
