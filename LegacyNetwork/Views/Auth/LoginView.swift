import SwiftUI

/// One-tap login gate. Single private user — no credentials required.
/// Tapping Log In signs straight into the populated fixture. The mock data
/// service ignores the passed values, so this never hits a backend.
struct LoginView: View {
    @EnvironmentObject private var auth: AuthManager

    var body: some View {
        ZStack {
            Theme.Color.primary.ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xl) {
                Spacer()

                LegacyWordmark(tint: .white, size: 40)

                Spacer()

                if let error = auth.loginError {
                    Text(error.userMessage)
                        .font(Theme.Font.footnote)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Theme.Spacing.xl)
                }

                PrimaryButtonInverse(title: "Log In", isLoading: auth.isAuthenticating) {
                    Task { await auth.login(email: "dianne@legacynetwork.com", password: "") }
                }
                .padding(.horizontal, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.xxl)
            }
            .frame(maxWidth: 520)
            .frame(maxWidth: .infinity)
        }
    }
}

/// White pill button used on the blue login background.
private struct PrimaryButtonInverse: View {
    let title: String
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView().tint(Theme.Color.primary)
                } else {
                    Text(title)
                        .font(Theme.Font.headline)
                        .foregroundStyle(Theme.Color.primary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.white)
            .clipShape(Capsule())
        }
        .disabled(isLoading)
    }
}

#Preview {
    LoginView().environmentObject(AuthManager(roleManager: RoleManager()))
}
