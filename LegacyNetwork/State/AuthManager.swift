import Foundation

/// Authentication state machine. Talks to a `DataService` (mock by default),
/// stores only a session token in the Keychain, and clears it on logout / 401.
@MainActor
final class AuthManager: ObservableObject {
    enum Status: Equatable {
        case unknown
        case signedOut
        case signedIn(User)
    }

    @Published private(set) var status: Status = .unknown
    @Published var loginError: APIError?
    @Published var isAuthenticating = false

    private let keychain = KeychainStore()
    private let roleManager: RoleManager
    private var dataProvider: (() -> DataService)!

    init(roleManager: RoleManager) {
        self.roleManager = roleManager
    }

    /// Wire the data source after construction (breaks the init cycle).
    func attach(dataProvider: @escaping () -> DataService) {
        self.dataProvider = dataProvider
    }

    /// Thread-safe token accessor for the networking layer.
    nonisolated func tokenSnapshot() -> String? {
        KeychainStore().get(.sanctumToken)
    }

    // MARK: - Session lifecycle

    func restoreSession() async {
        guard keychain.get(.sanctumToken) != nil else {
            status = .signedOut
            return
        }
        do {
            let user = try await dataProvider().currentUser()
            applySignedIn(user)
        } catch {
            await signOut()
        }
    }

    func login(email: String, password: String) async {
        isAuthenticating = true
        loginError = nil
        defer { isAuthenticating = false }
        do {
            let result = try await dataProvider().login(email: email, password: password)
            keychain.set(result.token, for: .sanctumToken)
            applySignedIn(result.user)
        } catch let error as APIError {
            loginError = error
        } catch {
            loginError = .transport(error.localizedDescription)
        }
    }

    func signOut() async {
        try? await dataProvider().logout()
        keychain.delete(.sanctumToken)
        roleManager.canUseAdmin = false
        roleManager.set(.distributor)
        status = .signedOut
    }

    /// Invoked by APIClient on a 401 (live backend only).
    func handleUnauthorized() async {
        keychain.delete(.sanctumToken)
        status = .signedOut
    }

    private func applySignedIn(_ user: User) {
        roleManager.canUseAdmin = user.canUseAdmin
        if !user.canUseAdmin { roleManager.set(.distributor) }
        status = .signedIn(user)
    }
}
