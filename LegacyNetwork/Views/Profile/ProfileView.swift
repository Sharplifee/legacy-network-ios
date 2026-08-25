import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        AsyncScreen(title: "Profile", load: {
            try await appState.data.profile()
        }) { user in
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    Avatar(url: user.avatarURL, name: user.displayName)
                        .frame(width: 96, height: 96)
                        .padding(.top, Theme.Spacing.lg)
                    Text(user.displayName).font(Theme.Font.title)
                    Text(user.email).font(Theme.Font.footnote).foregroundStyle(Theme.Color.textSecondary)

                    Card {
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            LabeledRow(label: "Member ID", value: "\(user.id)")
                            LabeledRow(label: "Role", value: user.isAdmin == true ? "Admin" : "Distributor")
                            if let tier = user.tier { LabeledRow(label: "Tier", value: tier.name) }
                            if let sid = user.synergyId { LabeledRow(label: "Synergy ID", value: sid) }
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
