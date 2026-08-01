import SwiftUI

struct SearchView: View {
    var body: some View {
        PlaceholderScreen(
            eyebrow: "Find & Play",
            title: "Search",
            note: "Search Apple Music and your library.\nPhase 2.",
            systemImage: "magnifyingglass"
        )
    }
}

#Preview { SearchView().preferredColorScheme(.dark) }
