import SwiftUI
import DesignSystem

/// Album subpage: shows a simple list of tracks. A back chevron appears in the
/// top-left to return to the artist view.
struct AlbumView: View {
    let artistName: String
    let albumName: String
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, DSSpacing.xl)
                .padding(.top, DSSpacing.md)
                .padding(.bottom, DSSpacing.sm)

            tracks
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DSColor.canvas.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack(spacing: DSSpacing.sm) {
            IconButton(systemName: "chevron.left") { onBack() }
            VStack(alignment: .leading, spacing: 2) {
                Eyebrow(artistName)
                Text(albumName)
                    .font(DSFont.title)
                    .foregroundStyle(DSColor.textPrimary)
                    .lineLimit(1)
            }
            Spacer()
        }
    }

    private var tracks: some View {
        List {
            ForEach(1..<13, id: \.self) { i in
                HStack {
                    Text("Track \(i)")
                        .font(DSFont.body)
                        .foregroundStyle(DSColor.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, DSSpacing.xl)
                .padding(.vertical, DSSpacing.sm)
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
