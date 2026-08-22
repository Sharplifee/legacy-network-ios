import Foundation

/// Authentication state machine. Exchanges credentials for a Sanctum token,
/// stores only the token (never the credentials) in the Keychain, loads the
/// current user, and clears everything on logout or 401.
@MainActor
final class AuthManager: ObservableObject {
    enum Status: Equatable {
        case unknown          // launching, deciding
        case signedOut
        case signedIn(User)
    }

    @Published private(set) var status: Status = .unknown
    @Published var loginError: APIError?
    @Published var isAuthenticating = false

    private let keychain = KeychainStore()
    private var client: APIClient!
    private let roleManager: RoleManager

    init(roleManager: RoleManager) {
        self.roleManager = roleManager
    }

    /// Wire the client after construction (breaks the init cycle with APIClient).
    func attach(client: APIClient) {
        self.client = client
    }

    /// Thread-safe token accessor for the networking layer.
    nonisolated func tokenSnapshot() -> String? {
        KeychainStore().get(.sanctumToken)
    }

    // MARK: - Session lifecycle

    /// Called on launch: if a token exists, try to restore the session.
    func restoreSession() async {
        guard keychain.get(.sanctumToken) != nil else {
            status = .signedOut
            return
        }
        do {
            let user = try await client.request(.currentUser, as: User.self)
            applySignedIn(user)
        } catch {
            // Token invalid/expired — start clean.
            await signOut()
        }
    }

    func login(email: String, password: String) async {
        isAuthenticating = true
        loginError = nil
        defer { isAuthenticating = false }

        do {
            let result = try await client.request(
                .login(email: email, password: password, deviceName: "LegacyNetwork-iOS"),
                as: LoginResponse.self
            )
            keychain.set(result.token, for: .sanctumToken)
            applySignedIn(result.user)
        } catch let error as APIError {
            loginError = error
        } catch {
            loginError = .transport(error.localizedDescription)
        }
    }

    func signOut() async {
        // Best-effort server logout; ignore failures.
        try? await client.send(.logout)
        keychain.delete(.sanctumToken)
        await client.clearCaches()
        roleManager.canUseAdmin = false
        roleManager.set(.distributor)
        status = .signedOut
    }

    /// Invoked by APIClient on a 401.
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
