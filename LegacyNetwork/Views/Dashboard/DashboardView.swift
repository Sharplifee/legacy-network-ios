import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var roles: RoleManager

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        AsyncScreen(title: "Dashboard", load: {
            try await appState.client.request(.dashboard, as: DashboardData.self)
        }) { data in
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    if let greeting = data.greeting {
                        Text(greeting)
                            .font(Theme.Font.title)
                            .foregroundStyle(Theme.Color.textPrimary)
                    }

                    if let xp = data.xp {
                        XPProgressCard(xp: xp)
                    }

                    LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                        ForEach(data.stats) { stat in
                            StatTile(label: stat.label, value: stat.value, delta: stat.deltaPercent)
                        }
                    }

                    if let activity = data.recentActivity, !activity.isEmpty {
                        Text("Recent Activity")
                            .font(Theme.Font.headline)
                        Card(padding: 0) {
                            VStack(spacing: 0) {
                                ForEach(activity) { item in
                                    ActivityRow(item: item)
                                    if item.id != activity.last?.id {
                                        Divider().padding(.leading, Theme.Spacing.lg)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink { LeaderboardView() } label: {
                        Image(systemName: "trophy.fill")
                    }
                    NavigationLink { AchievementsView() } label: {
                        Image(systemName: "rosette")
                    }
                    NavigationLink { NotificationsView() } label: {
                        Image(systemName: "bell.fill")
                    }
                }
            }
        }
    }
}

private struct ActivityRow: View {
    let item: ActivityItem
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Image(systemName: item.iconName ?? "circle.fill")
                .foregroundStyle(Theme.Color.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(item.title).font(Theme.Font.body)
                if let subtitle = item.subtitle {
                    Text(subtitle).font(Theme.Font.footnote).foregroundStyle(Theme.Color.textSecondary)
                }
            }
            Spacer()
        }
        .padding(Theme.Spacing.lg)
    }
}

struct XPProgressCard: View {
    let xp: XPSummary
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    Text("Level \(xp.level)").font(Theme.Font.headline)
                    Spacer()
                    if let streak = xp.streakDays {
                        Label("\(streak)d", systemImage: "flame.fill")
                            .font(Theme.Font.subhead)
                            .foregroundStyle(Theme.Color.warning)
                    }
                }
                ProgressView(value: progress)
                    .tint(Theme.Color.primary)
                Text("\(xp.xp) / \(xp.xp + xp.xpToNextLevel) XP")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Color.textSecondary)
            }
        }
    }
    private var progress: Double {
        let total = Double(xp.xp + xp.xpToNextLevel)
        return total > 0 ? Double(xp.xp) / total : 0
    }
}
