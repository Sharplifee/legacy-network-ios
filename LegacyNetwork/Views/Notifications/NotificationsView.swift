import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        AsyncScreen(title: "Notifications",
                    isEmpty: { $0.items.isEmpty },
                    emptyTitle: "You're all caught up",
                    load: {
            try await appState.client.request(.notifications(page: 1), as: Paginated<NotificationItem>.self)
        }) { page in
            List(page.items) { n in
                HStack(alignment: .top, spacing: Theme.Spacing.md) {
                    Circle()
                        .fill(n.read ? Color.clear : Theme.Color.primary)
                        .frame(width: 8, height: 8)
                        .padding(.top, 6)
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        Text(n.title).font(Theme.Font.subhead)
                        if let body = n.body {
                            Text(body).font(Theme.Font.footnote).foregroundStyle(Theme.Color.textSecondary)
                        }
                        if let ts = n.timestamp {
                            Text(ts, style: .relative).font(Theme.Font.caption).foregroundStyle(Theme.Color.textSecondary)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            }
            .listStyle(.plain)
        }
    }
}
