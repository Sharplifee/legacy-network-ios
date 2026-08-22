import SwiftUI

/// The LEGACY NETWORK wordmark: globe icon on the left, "LEGACY" bold uppercase,
/// with "NETWORK" letterspaced below it. Matches the web app lockup.
struct LegacyWordmark: View {
    var tint: Color = .white
    var size: CGFloat = 28

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            GlobeIcon(tint: tint)
                .frame(width: size * 1.6, height: size * 1.6)
            VStack(alignment: .leading, spacing: 0) {
                Text("LEGACY")
                    .font(.custom(Theme.Font.fontFamily, size: size).weight(.bold))
                    .foregroundStyle(tint)
                Text("NETWORK")
                    .font(.custom(Theme.Font.fontFamily, size: size * 0.5).weight(.regular))
                    .tracking(size * 0.28)   // letterspaced
                    .foregroundStyle(tint)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Legacy Network")
    }
}

/// Simple globe glyph rendered with SF Symbols as a stand-in for the brand
/// globe. Replace with the vector asset once the logo is exported.
struct GlobeIcon: View {
    var tint: Color = .white

    var body: some View {
        Image(systemName: "globe")
            .resizable()
            .scaledToFit()
            .fontWeight(.regular)
            .foregroundStyle(tint)
    }
}

#Preview {
    ZStack {
        Theme.Color.primary
        LegacyWordmark()
    }
    .frame(height: 160)
}
