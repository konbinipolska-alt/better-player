import SwiftUI
import MusicKit

/// Renders MusicKit `Artwork` at a fixed square size using `ArtworkImage` (which
/// resolves catalog/library artwork correctly — plain `AsyncImage` cannot load
/// MusicKit artwork URLs). Falls back to an SF Symbol tile when art is absent.
struct ArtworkView: View {
    let artwork: Artwork?
    let size: CGFloat
    var systemFallback: String = "music.note"

    private var corner: CGFloat { size * 0.12 }

    var body: some View {
        Group {
            if let artwork {
                ArtworkImage(artwork, width: size, height: size)
            } else {
                RoundedRectangle(cornerRadius: corner, style: .continuous)
                    .fill(.white.opacity(0.1))
                    .frame(width: size, height: size)
                    .overlay {
                        Image(systemName: systemFallback)
                            .font(.system(size: size * 0.35))
                            .foregroundStyle(.white.opacity(0.5))
                    }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    }
}
