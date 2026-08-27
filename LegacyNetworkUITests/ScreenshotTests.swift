import XCTest

/// Drives the app on a simulator and captures a screenshot of each primary
/// screen. Screenshots are attached to the .xcresult (visible in Xcode / CI)
/// **and** written as PNGs into the test runner's Documents container so CI can
/// pull them out with `simctl get_app_container`.
///
/// The app runs entirely on mock data, so login accepts any input — tapping
/// "Log In" moves past the auth gate into the tabbed UI.
final class ScreenshotTests: XCTestCase {

    private let app = XCUIApplication()

    override func setUpWithError() throws {
        // Best-effort capture — never abort the pass because one element moved.
        continueAfterFailure = true
        app.launch()
    }

    func testCaptureScreens() throws {
        // 1. Login screen (pre-auth).
        save("01-login")

        // 2. Sign in with the demo account (mock auth accepts anything).
        let email = app.textFields.firstMatch
        if email.waitForExistence(timeout: 15) {
            email.tap()
            email.typeText("dianne@legacynetwork.com")
        }
        let password = app.secureTextFields.firstMatch
        if password.waitForExistence(timeout: 3) {
            password.tap()
            password.typeText("demo-password")
        }
        let loginButton = app.buttons["Log In"]
        if loginButton.waitForExistence(timeout: 3) {
            loginButton.tap()
        }

        // 3. First authed screen (Dashboard).
        let tabBar = app.tabBars.firstMatch
        _ = tabBar.waitForExistence(timeout: 20)
        sleep(3)
        save("02-home")

        // 4. Walk every tab and screenshot it.
        if tabBar.exists {
            let count = tabBar.buttons.count
            for i in 0..<count {
                let button = tabBar.buttons.element(boundBy: i)
                guard button.exists else { continue }
                let label = sanitize(button.label)
                button.tap()
                sleep(2)
                save(String(format: "tab-%02d-%@", i, label))
            }
        }

        // 5. A couple of drill-downs from Settings, if reachable.
        if tabBar.exists {
            let settingsTab = tabBar.buttons["Settings"]
            if settingsTab.exists {
                settingsTab.tap()
                sleep(1)
                tapFirstIfExists(["Manage Subscription", "Payment Information", "Payment History"], prefix: "detail")
            }
        }
    }

    // MARK: - Helpers

    private func tapFirstIfExists(_ labels: [String], prefix: String) {
        for (idx, label) in labels.enumerated() {
            let cell = app.staticTexts[label]
            if cell.waitForExistence(timeout: 2) {
                cell.tap()
                sleep(2)
                save(String(format: "%@-%02d-%@", prefix, idx, sanitize(label)))
                app.navigationBars.buttons.firstMatch.tap() // back
                sleep(1)
            }
        }
    }

    private func save(_ name: String) {
        let shot = XCUIScreen.main.screenshot()

        let attachment = XCTAttachment(screenshot: shot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let dir = docs.first else { return }
        let url = dir.appendingPathComponent("\(name).png")
        try? shot.pngRepresentation.write(to: url)
    }

    private func sanitize(_ s: String) -> String {
        let allowed = CharacterSet.alphanumerics
        let mapped = s.unicodeScalars.map { allowed.contains($0) ? Character($0) : "-" }
        let joined = String(mapped)
        return joined.isEmpty ? "screen" : joined
    }
}
