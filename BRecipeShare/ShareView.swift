import SwiftUI

@Observable
final class ShareState {
    var saved: Bool = false
}

struct ShareView: View {

    var state: ShareState

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // App icon stand-in
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.orange.gradient)
                    .frame(width: 72, height: 72)
                Image(systemName: "fork.knife")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.white)
            }

            if state.saved {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                    Text("Recipe saved!")
                        .font(.headline)
                    Text("Open BRecipe to review and import.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .transition(.opacity)
            } else {
                VStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.regular)
                    Text("Saving recipe…")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(32)
        .animation(.easeInOut(duration: 0.3), value: state.saved)
    }
}
