import SwiftUI
import DesignSystem

/// Modal artist view with its own internal navigation. Displays a simple list
/// of albums; tapping an album pushes an `AlbumView`. A close `X` button sits
/// in the top-right corner to dismiss the whole artist sheet.
struct ArtistView: View {
    let artistName: String
    let initialAlbumName: String?
    let onClose: () -> Void

    @State private var path: [AlbumRoute] = []
    @State private var didDeepLink = false

    var body: some View {
        NavigationStack(path: $path) {
            ArtistAlbumsList(artistName: artistName)
            .navigationTitle(artistName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { closeToolbar }
            .navigationDestination(for: AlbumRoute.self) { route in
                switch route {
                case .album(let name):
                    AlbumView(artistName: artistName, albumName: name) {
                        if !path.isEmpty { path.removeLast() }
                    }
                }
            }
        }
        .task { deepLinkIfNeeded() }
    }

    private var closeToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(DSColor.textPrimary)
            }
            .accessibilityLabel("Close")
            .accessibilityHint("Dismiss artist")
            .buttonStyle(.plain)
        }
    }

    private func deepLinkIfNeeded() {
        guard !didDeepLink, let initialAlbumName else { return }
        didDeepLink = true
        path = [.album(initialAlbumName)]
    }
}

private enum AlbumRoute: Hashable {
    case album(String)
}

/// Simple list of albums for an artist. For now, mocked with a few names.
private struct ArtistAlbumsList: View {
    let artistName: String

    private var albums: [String] {
        // Placeholder data; to be replaced by MusicKit.
        ["Greatest Hits", "Live at Home", "Rare Tracks", "Studio Sessions"]
    }

    var body: some View {
        List {
            ForEach(albums, id: \.self) { album in
                NavigationLink(value: AlbumRoute.album(album)) {
                    HStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(DSColor.surfaceRaised)
                            .frame(width: 48, height: 48)
                        Text(album)
                            .font(DSFont.headline)
                            .foregroundStyle(DSColor.textPrimary)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(DSColor.canvas.ignoresSafeArea())
    }
}
