import SwiftUI

/// Legacy Network design system.
///
/// Values here are the single source of truth for color, type, spacing, and
/// shape across the app. They mirror the web application's CSS design tokens.
///
/// NOTE: These values were seeded from the documented web design system
/// (see README) and the login/settings specs. When the web CSS is captured,
/// reconcile any drift here — this is the only place a color/spacing value
/// should ever be defined.
enum Theme {

    // MARK: - Colors

    enum Color {
        /// #3171CC — primary brand blue (login background, primary buttons).
        static let primary = SwiftUI.Color(hex: 0x3171CC)
        /// #21BCAA — teal accent (input icon buttons, highlights).
        static let accent = SwiftUI.Color(hex: 0x21BCAA)
        /// #1B1E23 — dark header / nav surface.
        static let headerDark = SwiftUI.Color(hex: 0x1B1E23)

        /// Pale yellow input field fill (login form).
        static let inputFill = SwiftUI.Color(hex: 0xFDF6D8)

        static let surface = SwiftUI.Color(.systemBackground)
        static let surfaceSecondary = SwiftUI.Color(.secondarySystemBackground)
        static let surfaceGrouped = SwiftUI.Color(.systemGroupedBackground)

        static let textPrimary = SwiftUI.Color(.label)
        static let textSecondary = SwiftUI.Color(.secondaryLabel)
        static let textOnPrimary = SwiftUI.Color.white

        static let separator = SwiftUI.Color(.separator)

        static let success = SwiftUI.Color(hex: 0x2FB56B)
        static let warning = SwiftUI.Color(hex: 0xE0A82E)
        static let danger = SwiftUI.Color(hex: 0xD64545)
    }

    // MARK: - Typography

    enum Font {
        static let fontFamily = "Helvetica Neue"

        static func regular(_ size: CGFloat) -> SwiftUI.Font {
            .custom(fontFamily, size: size).weight(.regular)
        }
        static func medium(_ size: CGFloat) -> SwiftUI.Font {
            .custom(fontFamily, size: size).weight(.medium)
        }
        static func bold(_ size: CGFloat) -> SwiftUI.Font {
            .custom(fontFamily, size: size).weight(.bold)
        }

        // Semantic scale (supports Dynamic Type via relativeTo where used).
        static let largeTitle = bold(32)
        static let title = bold(24)
        static let headline = medium(18)
        static let body = regular(16)
        static let callout = regular(15)
        static let subhead = medium(14)
        static let footnote = regular(13)
        static let caption = regular(12)
    }

    // MARK: - Spacing (4pt grid)

    enum Spacing {
        static let xxs: CGFloat = 2
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
        static let xxxl: CGFloat = 48
    }

    // MARK: - Radius

    enum Radius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 10   // documented default corner radius
        static let lg: CGFloat = 16
        static let pill: CGFloat = 999
    }

    // MARK: - Shadow

    enum Shadow {
        static let card = ShadowStyle(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        static let elevated = ShadowStyle(color: .black.opacity(0.14), radius: 16, x: 0, y: 6)
    }

    struct ShadowStyle {
        let color: SwiftUI.Color
        let radius: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    // MARK: - Animation / transitions

    enum Motion {
        static let quick = Animation.easeInOut(duration: 0.18)
        static let standard = Animation.easeInOut(duration: 0.28)
        static let spring = Animation.spring(response: 0.4, dampingFraction: 0.82)
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: alpha
        )
    }
}

// MARK: - Shadow view modifier

extension View {
    func themeShadow(_ style: Theme.ShadowStyle) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}
