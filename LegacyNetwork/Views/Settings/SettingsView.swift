import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var auth: AuthManager
    @EnvironmentObject private var roles: RoleManager
    @EnvironmentObject private var skin: SkinManager
    @Environment(\.dismiss) private var dismiss

    private var user: User? {
        if case .signedIn(let user) = auth.status { return user }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                header

                profileCard

                if roles.canUseAdmin {
                    roleToggleCard
                }

                accountSection

                Button(role: .destructive) {
                    Task { await auth.signOut() }
                } label: {
                    Text("Log Out")
                        .font(Theme.Font.subhead)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, Theme.Spacing.sm)

                dataSkinControl

                Spacer(minLength: Theme.Spacing.xxl)
            }
            .padding(Theme.Spacing.lg)
        }
        .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
        .navigationBarBackButtonHidden()
    }

    // MARK: - Data skin (discreet demo toggle)

    /// A low-key control to switch the whole app between the "Current" snapshot
    /// and a "Growth" skin whose numbers ramp up over time. Front-end demo only.
    private var dataSkinControl: some View {
        VStack(spacing: Theme.Spacing.xs) {
            Picker("", selection: Binding(
                get: { skin.skin },
                set: { skin.skin = $0 }
            )) {
                ForEach(AppSkin.allCases) { Text($0.label).tag($0) }
            }
            .pickerStyle(.segmented)

            Text("Demo data · \(skin.skin == .growth ? "Growth (ramps over time)" : "Current snapshot")")
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.Color.textSecondary)
        }
        .padding(.horizontal, Theme.Spacing.xs)
        .opacity(0.9)
    }

    // MARK: - Header (back pill + centered title)

    private var header: some View {
        ZStack {
            Text("Settings")
                .font(Theme.Font.headline)
                .foregroundStyle(Theme.Color.textPrimary)

            HStack {
                Button { dismiss() } label: {
                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(Theme.Font.subhead)
                    .foregroundStyle(Theme.Color.textPrimary)
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(Capsule().fill(Theme.Color.surface))
                    .themeShadow(Theme.Shadow.card)
                }
                Spacer()
            }
        }
    }

    // MARK: - Profile card

    private var profileCard: some View {
        Card {
            HStack(spacing: Theme.Spacing.lg) {
                Avatar(url: user?.avatarURL, name: user?.displayName ?? "")
                    .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(user?.displayName ?? "—")
                        .font(Theme.Font.headline)
                        .foregroundStyle(Theme.Color.textPrimary)
                    Text(user?.email ?? "—")
                        .font(Theme.Font.footnote)
                        .foregroundStyle(Theme.Color.textSecondary)
                }
                Spacer()
                NavigationLink {
                    ProfileView()
                } label: {
                    Text("Edit")
                        .font(Theme.Font.subhead)
                        .foregroundStyle(Theme.Color.primary)
                }
            }
        }
    }

    // MARK: - Distributor / Admin toggle

    private var roleToggleCard: some View {
        Card {
            HStack {
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text("Mode")
                        .font(Theme.Font.subhead)
                        .foregroundStyle(Theme.Color.textPrimary)
                    Text(roles.active == .admin ? "Admin" : "Distributor")
                        .font(Theme.Font.footnote)
                        .foregroundStyle(Theme.Color.textSecondary)
                }
                Spacer()
                Toggle("", isOn: Binding(
                    get: { roles.active == .admin },
                    set: { roles.set($0 ? .admin : .distributor) }
                ))
                .labelsHidden()
                .tint(Theme.Color.primary)
            }
        }
    }

    // MARK: - Account section

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text("ACCOUNT")
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.Color.textSecondary)
                .padding(.leading, Theme.Spacing.xs)

            Card(padding: 0) {
                VStack(spacing: 0) {
                    SettingsRow(title: "Notification") { NotificationsView() }
                    Divider().padding(.leading, Theme.Spacing.lg)
                    SettingsRow(title: "Manage Subscription") { SubscriptionView() }
                    Divider().padding(.leading, Theme.Spacing.lg)
                    SettingsRow(title: "Payment Information") { PaymentMethodsView() }
                    Divider().padding(.leading, Theme.Spacing.lg)
                    SettingsRow(title: "Payment History") { PaymentHistoryView() }
                }
            }
        }
    }
}

/// A settings row with a title on the left and a circular chevron button right.
private struct SettingsRow<Destination: View>: View {
    let title: String
    @ViewBuilder var destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HStack {
                Text(title)
                    .font(Theme.Font.body)
                    .foregroundStyle(Theme.Color.textPrimary)
                Spacer()
                CircleChevron()
            }
            .padding(Theme.Spacing.lg)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct Avatar: View {
    let url: URL?
    let name: String

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default: placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .clipShape(Circle())
    }

    private var placeholder: some View {
        ZStack {
            Theme.Color.primary.opacity(0.15)
            Text(initials)
                .font(Theme.Font.subhead)
                .foregroundStyle(Theme.Color.primary)
        }
    }

    private var initials: String {
        let parts = name.split(separator: " ").prefix(2)
        return parts.map { String($0.prefix(1)) }.joined().uppercased()
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environmentObject(AuthManager(roleManager: RoleManager()))
        .environmentObject(RoleManager())
        .environmentObject(SkinManager())
}
