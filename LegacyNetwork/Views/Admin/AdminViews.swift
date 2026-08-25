import SwiftUI

/// Admin dashboard. Only reachable when the active role is `.admin` (the tab is
/// hidden otherwise) and every request below is admin-gated in `APIClient`.
struct AdminDashboardView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var roles: RoleManager
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        Group {
            if roles.active == .admin && roles.canUseAdmin {
                AsyncScreen(title: "Admin", load: {
                    try await appState.data.adminMetrics()
                }) { metrics in
                    ScrollView {
                        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                            LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                                StatTile(label: "Members", value: "\(metrics.totalMembers)")
                                StatTile(label: "Active", value: "\(metrics.activeMembers)")
                                StatTile(label: "Volume", value: money(metrics.totalVolume))
                                StatTile(label: "Pending Payouts", value: money(metrics.pendingPayouts))
                            }
                            NavigationLink { AdminMembersView() } label: {
                                adminLink("Members")
                            }.buttonStyle(.plain)
                            NavigationLink { AdminPayoutsView() } label: {
                                adminLink("Payouts")
                            }.buttonStyle(.plain)
                        }
                        .padding(Theme.Spacing.lg)
                    }
                    .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
                }
            } else {
                // Defense in depth: never render admin content for distributors.
                EmptyStateView(title: "Admin access required",
                               subtitle: "Switch to Admin mode in Settings.",
                               systemImage: "lock.shield")
                    .navigationTitle("Admin")
            }
        }
    }

    private func adminLink(_ title: String) -> some View {
        HStack {
            Text(title).font(Theme.Font.body)
            Spacer()
            CircleChevron()
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
    }
}

struct AdminMembersView: View {
    @EnvironmentObject private var appState: AppState
    var body: some View {
        AsyncScreen(title: "Members",
                    isEmpty: { $0.items.isEmpty },
                    emptyTitle: "No members",
                    load: {
            try await appState.data.adminMembers(page: 1)
        }) { page in
            List(page.items) { m in
                NavigationLink { AdminMemberDetailView(id: m.id) } label: {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        Text(m.name).font(Theme.Font.body)
                        Text(m.email).font(Theme.Font.caption).foregroundStyle(Theme.Color.textSecondary)
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

struct AdminMemberDetailView: View {
    @EnvironmentObject private var appState: AppState
    let id: Int
    var body: some View {
        AsyncScreen(title: "Member", load: {
            try await appState.data.adminMemberDetail(id: id)
        }) { m in
            ScrollView {
                Card {
                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        Text(m.name).font(Theme.Font.title)
                        LabeledRow(label: "Email", value: m.email)
                        if let role = m.role { LabeledRow(label: "Role", value: role) }
                        if let status = m.status { LabeledRow(label: "Status", value: status) }
                        if let vol = m.volume { LabeledRow(label: "Volume", value: money(vol)) }
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
        }
    }
}

struct AdminPayoutsView: View {
    @EnvironmentObject private var appState: AppState
    var body: some View {
        AsyncScreen(title: "Payouts",
                    isEmpty: { $0.items.isEmpty },
                    emptyTitle: "No payouts",
                    load: {
            try await appState.data.adminPayouts(page: 1)
        }) { page in
            List(page.items) { p in
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        Text(p.memberName).font(Theme.Font.body)
                        Text(p.date, style: .date).font(Theme.Font.caption).foregroundStyle(Theme.Color.textSecondary)
                    }
                    Spacer()
                    Text(money(p.amount)).font(Theme.Font.subhead)
                    if let status = p.status { StatusBadge(status: status) }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(.plain)
        }
    }
}
