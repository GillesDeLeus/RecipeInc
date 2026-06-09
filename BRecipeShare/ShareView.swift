import SwiftUI

@Observable
final class ShareState {
    var saved: Bool = false
}

/// Minimal en/nl strings for the extension, driven by the language the main
/// app mirrors into the App Group defaults (key "appLanguage").
private enum ShareStrings {
    static var isDutch: Bool {
        UserDefaults(suiteName: PendingImportStore.appGroupID)?
            .string(forKey: "appLanguage") == "nl"
    }

    static var saving: String {
        isDutch ? "Recept opslaan…" : "Saving recipe…"
    }
    static var saved: String {
        isDutch ? "Recept opgeslagen!" : "Recipe saved!"
    }
    static var openApp: String {
        isDutch ? "Open recipeInc om het te bekijken en te importeren."
                : "Open recipeInc to review and import."
    }
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
                    Text(ShareStrings.saved)
                        .font(.headline)
                    Text(ShareStrings.openApp)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .transition(.opacity)
            } else {
                VStack(spacing: 8) {
                    ProgressView()
                        .controlSize(.regular)
                    Text(ShareStrings.saving)
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
