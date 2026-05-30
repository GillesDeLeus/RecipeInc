import SwiftUI

// MARK: - Color from hex string

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 122, 255)
        }
        self.init(.sRGB,
                  red: Double(r) / 255,
                  green: Double(g) / 255,
                  blue: Double(b) / 255,
                  opacity: Double(a) / 255)
    }
}

// MARK: - Cross-platform image from Data

extension Image {
    init?(data: Data) {
#if os(iOS)
        guard let ui = UIImage(data: data) else { return nil }
        self.init(uiImage: ui)
#else
        guard let ns = NSImage(data: data) else { return nil }
        self.init(nsImage: ns)
#endif
    }
}

extension View {

    /// Cross-platform wrapper for `.navigationBarTitleDisplayMode`.
    /// On macOS the modifier doesn't exist and is silently skipped.
    @ViewBuilder
    func navigationTitleDisplayMode(_ mode: NavigationTitleDisplayMode) -> some View {
#if os(iOS)
        switch mode {
        case .large:
            self.navigationBarTitleDisplayMode(.large)
        case .inline:
            self.navigationBarTitleDisplayMode(.inline)
        }
#else
        self
#endif
    }
}

/// Platform-agnostic display mode enum mirroring `NavigationBarItem.TitleDisplayMode`.
enum NavigationTitleDisplayMode {
    case large
    case inline
}

// MARK: - Star rating widget

struct StarRatingView: View {
    let rating: Int
    let interactive: Bool
    let onRate: (Int) -> Void

    init(rating: Int, interactive: Bool = true, onRate: @escaping (Int) -> Void = { _ in }) {
        self.rating = rating
        self.interactive = interactive
        self.onRate = onRate
    }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundStyle(star <= rating ? Color.yellow : Color.secondary.opacity(0.35))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard interactive else { return }
                        onRate(rating == star ? 0 : star)
                    }
            }
        }
        .fixedSize()
    }
}
