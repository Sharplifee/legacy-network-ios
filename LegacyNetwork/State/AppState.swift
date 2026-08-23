import Foundation

/// Composition root. Wires role, skin, auth, and the data source.
///
/// The app is a front-end replica with **no live backend**: `data` is served by
/// `MockDataService`, switched between the Current and Growth skins. The live
/// `APIClient` + `LiveDataService` are kept so a real backend can be wired later
/// by returning `LiveDataService(client:)` from `data`.
@MainActor
final class AppState: ObservableObject {
    let roleManager: RoleManager
    let skinManager: SkinManager
    let auth: AuthManager
    let client: APIClient

    init() {
        let roles = RoleManager()
        let skin = SkinManager()
        let auth = AuthManager(roleManager: roles)

        let client = APIClient(
            tokenProvider: { KeychainStore().get(.sanctumToken) },
            roleProvider: { RoleManager.current() },
            onUnauthorized: { [weak auth] in await auth?.handleUnauthorized() }
        )

        self.roleManager = roles
        self.skinManager = skin
        self.auth = auth
        self.client = client

        // Auth (and every screen) reads the current skin's mock data.
        auth.attach(dataProvider: { [skin] in MockDataService(skin: skin.skin) })
    }

    /// Typed data source for the current skin. Swap to `LiveDataService(client:)`
    /// here to run against the real backend.
    var data: DataService { MockDataService(skin: skinManager.skin) }

    func bootstrap() async {
        await auth.restoreSession()
    }
}
