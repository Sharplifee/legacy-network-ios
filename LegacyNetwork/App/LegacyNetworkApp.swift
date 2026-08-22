import SwiftUI

@main
struct LegacyNetworkApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(appState.auth)
                .environmentObject(appState.roleManager)
                .task { await appState.bootstrap() }
                .tint(Theme.Color.primary)
        }
    }
}
