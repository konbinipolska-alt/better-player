import SwiftUI
import UIKit

/// The unauthorized state: a single call to action that requests Apple Music
/// access. If access was previously denied, the request won't re-prompt, so we
/// also offer a path into Settings.
struct AuthGateView: View {
    let auth: MusicAuthModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "music.note.list")
                .font(.system(size: 64))
                .foregroundStyle(.white)
            Text("Connect Apple Music")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("Better Player needs access to your Apple Music library to show and play your playlists.")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()

            Button {
                Task { await auth.request() }
            } label: {
                Text("Connect")
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white, in: .rect(cornerRadius: 14))
            }
            .padding(.horizontal, 32)

            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}
