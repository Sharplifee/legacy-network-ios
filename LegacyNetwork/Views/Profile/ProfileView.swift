import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        AsyncScreen(title: "Profile", load: {
            try await appState.client.request(.profile, as: User.self)
        }) { user in
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    Avatar(url: user.avatarURL, name: user.name)
                        .frame(width: 96, height: 96)
                        .padding(.top, Theme.Spacing.lg)
                    Text(user.name).font(Theme.Font.title)
                    Text(user.email).font(Theme.Font.footnote).foregroundStyle(Theme.Color.textSecondary)

                    Card {
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            LabeledRow(label: "Member ID", value: "\(user.id)")
                            if let roles = user.roles, !roles.isEmpty {
                                LabeledRow(label: "Roles", value: roles.joined(separator: ", "))
                            }
                        }
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
        }
    }
}

struct LabeledRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).font(Theme.Font.footnote).foregroundStyle(Theme.Color.textSecondary)
            Spacer()
            Text(value).font(Theme.Font.body).foregroundStyle(Theme.Color.textPrimary)
        }
    }
}
