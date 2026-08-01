import SwiftUI
import SwiftData

@main
struct BetterPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
        .modelContainer(for: [Playlist.self, PlaylistItem.self])
    }
}
