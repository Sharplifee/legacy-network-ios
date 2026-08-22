import Foundation

/// Composition root. Constructs and wires the role manager, auth manager, and
/// API client so their dependencies resolve without cycles.
@MainActor
final class AppState: ObservableObject {
    let roleManager: RoleManager
    let auth: AuthManager
    let client: APIClient

    init() {
        let roles = RoleManager()
        let auth = AuthManager(roleManager: roles)

        // The client reads token/role via thread-safe, capture-free snapshots
        // (Keychain + UserDefaults) and calls back into auth on 401.
        let client = APIClient(
            tokenProvider: { KeychainStore().get(.sanctumToken) },
            roleProvider: { RoleManager.current() },
            onUnauthorized: { [weak auth] in await auth?.handleUnauthorized() }
        )
        auth.attach(client: client)

        self.roleManager = roles
        self.auth = auth
        self.client = client
    }

    func bootstrap() async {
        await auth.restoreSession()
    }
}
