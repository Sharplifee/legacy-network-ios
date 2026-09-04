import SwiftUI

@main
struct LegacyNetworkApp: App {
    var body: some Scene {
        WindowGroup {
            WebRootView()
                .ignoresSafeArea()
                .statusBarHidden(false)
        }
    }
}
