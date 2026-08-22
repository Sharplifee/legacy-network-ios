import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthManager

    @State private var accountType = 0   // 0 = Distributor, 1 = Customer
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @FocusState private var focus: Field?

    private enum Field { case email, password }

    var body: some View {
        ZStack {
            Theme.Color.primary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    Spacer(minLength: Theme.Spacing.xxxl)

                    LegacyWordmark(tint: .white, size: 34)
                        .padding(.bottom, Theme.Spacing.md)

                    // Distributor / Customer toggle
                    SegmentedPill(options: ["Distributor", "Customer"], selection: $accountType)
                        .padding(.horizontal, Theme.Spacing.xl)

                    VStack(spacing: Theme.Spacing.lg) {
                        // Email field with teal envelope button
                        InputField(
                            text: $email,
                            placeholder: "Email",
                            icon: "envelope.fill",
                            keyboard: .emailAddress,
                            isSecure: false
                        )
                        .focused($focus, equals: .email)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                        // Password field with teal eye toggle button
                        InputField(
                            text: $password,
                            placeholder: "Password",
                            icon: showPassword ? "eye.slash.fill" : "eye.fill",
                            keyboard: .default,
                            isSecure: !showPassword,
                            onIconTap: { showPassword.toggle() }
                        )
                        .focused($focus, equals: .password)
                    }
                    .padding(.horizontal, Theme.Spacing.xl)

                    if let error = auth.loginError {
                        Text(error.userMessage)
                            .font(Theme.Font.footnote)
                            .foregroundStyle(.white)
                            .padding(.horizontal, Theme.Spacing.xl)
                    }

                    // Log In button (full-width pill)
                    PrimaryButtonInverse(
                        title: "Log In",
                        isLoading: auth.isAuthenticating,
                        isEnabled: !email.isEmpty && !password.isEmpty
                    ) {
                        focus = nil
                        Task { await auth.login(email: email, password: password) }
                    }
                    .padding(.horizontal, Theme.Spacing.xl)

                    // Four support links
                    VStack(spacing: Theme.Spacing.md) {
                        linkRow("Forgot Password?")
                        linkRow("Never received Welcome Email?")
                        linkRow("Never received Verification Email?")
                        linkRow("Existing Synergy Team Member wanting to use the Legacy Network WebApp?")
                    }
                    .padding(.horizontal, Theme.Spacing.xl)
                    .padding(.top, Theme.Spacing.sm)

                    Spacer(minLength: Theme.Spacing.xxl)
                }
                .frame(maxWidth: 520)
                .frame(maxWidth: .infinity)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private func linkRow(_ title: String) -> some View {
        Button {
            // TODO: route to the corresponding web/native flow.
        } label: {
            Text(title)
                .font(Theme.Font.footnote)
                .foregroundStyle(.white.opacity(0.9))
                .underline()
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }
}

/// Pale-yellow input field with an attached teal icon button on the right.
private struct InputField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false
    var onIconTap: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 0) {
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(Theme.Font.body)
            .foregroundStyle(Theme.Color.textPrimary)
            .padding(.horizontal, Theme.Spacing.lg)
            .frame(height: 52)
            .keyboardType(keyboard)

            Button {
                onIconTap?()
            } label: {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Theme.Color.accent)
            }
            .disabled(onIconTap == nil)
        }
        .background(Theme.Color.inputFill)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
    }
}

/// White pill button used on the blue login background.
private struct PrimaryButtonInverse: View {
    let title: String
    var isLoading: Bool
    var isEnabled: Bool
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
            .background(Color.white.opacity(isEnabled ? 1 : 0.6))
            .clipShape(Capsule())
        }
        .disabled(!isEnabled || isLoading)
    }
}

#Preview {
    LoginView().environmentObject(AuthManager(roleManager: RoleManager()))
}
