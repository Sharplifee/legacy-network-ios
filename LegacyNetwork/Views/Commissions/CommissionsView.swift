import SwiftUI

struct CommissionsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        AsyncScreen(title: "Commissions",
                    isEmpty: { $0.items.isEmpty },
                    emptyTitle: "No commissions yet",
                    load: {
            try await appState.client.request(.commissions(page: 1), as: Paginated<Commission>.self)
        }) { page in
            List(page.items) { c in
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        Text(c.sourceName ?? c.type).font(Theme.Font.body)
                        Text(c.date, style: .date).font(Theme.Font.caption).foregroundStyle(Theme.Color.textSecondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                        Text(money(c.amount, c.currency)).font(Theme.Font.subhead).foregroundStyle(Theme.Color.success)
                        if let status = c.status {
                            Text(status.capitalized).font(Theme.Font.caption).foregroundStyle(Theme.Color.textSecondary)
                        }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(.plain)
        }
    }
}
