import SwiftUI
import DesignSystem

struct MusicAuthView: View {
    @Bindable var auth: MusicAuthManager
    var onClose: () -> Void

    @State private var requesting = false

    var body: some View {
        VStack(spacing: DSSpacing.xl) {
            VStack(spacing: DSSpacing.sm) {
                Text("Connect to Apple Music")
                    .font(DSFont.display)
                    .foregroundStyle(DSColor.textPrimary)
                Text("We use your Apple Music subscription to search artists and albums, and to play full tracks.")
                    .font(DSFont.body)
                    .foregroundStyle(DSColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, DSSpacing.xl)

            Button(action: request) {
                HStack(spacing: DSSpacing.sm) {
                    if requesting { ProgressView().tint(DSColor.textPrimary) }
                    Text(requesting ? "Requesting…" : "Connect")
                        .font(DSFont.headline)
                        .foregroundStyle(DSColor.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(DSColor.surfaceRaised)
                .clipShape(RoundedRectangle(cornerRadius: DSRadius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, DSSpacing.xl)

            Spacer()

            Button(action: onClose) {
                Text("Not now")
                    .font(DSFont.callout)
                    .foregroundStyle(DSColor.textTertiary)
            }
            .padding(.bottom, DSSpacing.xl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DSColor.canvas.ignoresSafeArea())
        .onChange(of: auth.status) { _, _ in
            // When status changes to authorized/restricted, the presenting condition will hide this sheet.
            requesting = false
        }
    }

    private func request() {
        guard !requesting else { return }
        requesting = true
        Task { @MainActor in
            await auth.requestAuthorization()
        }
    }
}
