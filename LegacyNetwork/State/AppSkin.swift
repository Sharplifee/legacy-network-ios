import Foundation
import Combine

/// Which data "skin" the app renders. This is a front-end replica with no live
/// backend: both skins are served from `MockDataService`.
///
/// - `.current` — a realistic static snapshot that mirrors how the live app
///   looks populated (representative data, not real members' records).
/// - `.growth`  — the same screens seeded with smaller numbers that ramp up
///   over real elapsed time, to demo gradual growth.
enum AppSkin: String, CaseIterable, Identifiable {
    case current
    case growth

    var id: String { rawValue }
    var label: String { self == .current ? "Current" : "Growth" }
}

@MainActor
final class SkinManager: ObservableObject {
    private let key = "app_skin"

    @Published var skin: AppSkin {
        didSet { UserDefaults.standard.set(skin.rawValue, forKey: key) }
    }

    init() {
        skin = UserDefaults.standard.string(forKey: key).flatMap(AppSkin.init) ?? .current
    }
}
