import Foundation
import Combine

/// Owns the active role (Distributor / Admin) and persists it.
///
/// The role drives navigation and endpoint access. Reads are backed by
/// UserDefaults so the networking layer can consult the current role from any
/// thread without touching the main actor.
@MainActor
final class RoleManager: ObservableObject {
    private let defaultsKey = "active_role"

    @Published private(set) var active: Role {
        didSet { UserDefaults.standard.set(active.rawValue, forKey: defaultsKey) }
    }

    /// Whether the signed-in account is *allowed* to switch to admin at all.
    /// Distributor-only accounts never see the toggle or admin screens.
    @Published var canUseAdmin: Bool = false

    init() {
        let stored = UserDefaults.standard.string(forKey: defaultsKey)
        active = stored.flatMap(Role.init) ?? .admin   // web default is Admin when available
    }

    func set(_ role: Role) {
        guard role != .admin || canUseAdmin else { return }
        active = role
    }

    func toggle() {
        set(active == .admin ? .distributor : .admin)
    }

    /// Thread-safe snapshot for the networking layer.
    nonisolated static func current() -> Role {
        let raw = UserDefaults.standard.string(forKey: "active_role")
        return raw.flatMap(Role.init) ?? .distributor
    }
}
