import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject private var appState: AppState
    @State private var period = "month"

    var body: some View {
        VStack(spacing: 0) {
            Picker("Period", selection: $period) {
                Text("Week").tag("week")
                Text("Month").tag("month")
                Text("All Time").tag("all")
            }
            .pickerStyle(.segmented)
            .padding(Theme.Spacing.lg)

            AsyncScreen(title: "Leaderboard",
                        isEmpty: { $0.isEmpty },
                        emptyTitle: "No rankings yet",
                        load: {
                try await appState.data.leaderboard(period: period)
            }) { entries in
                List(entries) { entry in
                    HStack(spacing: Theme.Spacing.md) {
                        Text("#\(entry.rank)")
                            .font(Theme.Font.headline)
                            .foregroundStyle(entry.rank <= 3 ? Theme.Color.primary : Theme.Color.textSecondary)
                            .frame(width: 44, alignment: .leading)
                        Avatar(url: entry.avatarURL, name: entry.name).frame(width: 36, height: 36)
                        Text(entry.name).font(Theme.Font.body)
                        Spacer()
                        Text(String(format: "%.0f", entry.value))
                            .font(Theme.Font.subhead)
                            .foregroundStyle(Theme.Color.textPrimary)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
                .listStyle(.plain)
            }
            // Reload when the period changes.
            .id(period)
        }
        .navigationTitle("Leaderboard")
    }
}
