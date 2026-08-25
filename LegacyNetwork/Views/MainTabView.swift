import SwiftUI

/// Role-aware root navigation. The tab set changes with the active role:
/// admin-only destinations never appear for distributor-role users.
struct MainTabView: View {
    @EnvironmentObject private var roles: RoleManager
    @EnvironmentObject private var skin: SkinManager

    var body: some View {
        TabView {
            NavigationStack { DashboardView() }
                .tabItem { Label("Home", systemImage: "house.fill") }

            NavigationStack { NetworkTreeView() }
                .tabItem { Label("Network", systemImage: "person.3.fill") }

            NavigationStack { EarningsView() }
                .tabItem { Label("Earnings", systemImage: "chart.line.uptrend.xyaxis") }

            NavigationStack { QuizListView() }
                .tabItem { Label("Learn", systemImage: "graduationcap.fill") }

            if roles.active == .admin && roles.canUseAdmin {
                NavigationStack { AdminDashboardView() }
                    .tabItem { Label("Admin", systemImage: "shield.lefthalf.filled") }
            }

            NavigationStack { SettingsView() }
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        // Re-render (and re-fetch data) when the role or data skin changes.
        .id("\(roles.active.rawValue)-\(skin.skin.rawValue)")
        .animation(Theme.Motion.standard, value: roles.active)
    }
}
