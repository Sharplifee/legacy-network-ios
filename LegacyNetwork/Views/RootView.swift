import SwiftUI

/// Auth gate. Shows a splash while restoring the session, the login screen when
/// signed out, and the role-aware main navigation when signed in.
struct RootView: View {
    @EnvironmentObject private var auth: AuthManager

    var body: some View {
        switch auth.status {
        case .unknown:
            SplashView()
        case .signedOut:
            LoginView()
                .transition(.opacity)
        case .signedIn:
            MainTabView()
                .transition(.opacity)
        }
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            Theme.Color.primary.ignoresSafeArea()
            LegacyWordmark(tint: .white)
        }
    }
}
