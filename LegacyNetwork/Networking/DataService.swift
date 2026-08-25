import Foundation

/// Typed data source for every screen. The app is a front-end replica, so the
/// default is `MockDataService` (no backend). `LiveDataService` is kept for when
/// the real API is wired: it forwards to `APIClient`.
protocol DataService: Sendable {
    func login(email: String, password: String) async throws -> LoginResponse
    func currentUser() async throws -> User
    func logout() async throws

    func dashboard() async throws -> DashboardData
    func profile() async throws -> User
    func notifications(page: Int) async throws -> Paginated<NotificationItem>

    func networkTree() async throws -> NetworkNode
    func leaderboard(period: String) async throws -> [LeaderboardEntry]

    func commissions(page: Int) async throws -> Paginated<Commission>
    func earningsSummary() async throws -> EarningsSummary

    func tokenBalance() async throws -> TokenBalance
    func tokenTransactions(page: Int) async throws -> Paginated<TokenTransaction>

    func quizzes() async throws -> [Quiz]
    func quizSession(id: String) async throws -> QuizSession
    func submitQuiz(id: String, answers: [String: String]) async throws -> QuizResult
    func achievements() async throws -> [Achievement]

    func subscription() async throws -> Subscription
    func checkoutPlans() async throws -> [CheckoutPlan]
    func paymentMethods() async throws -> [PaymentMethod]
    func paymentHistory(page: Int) async throws -> Paginated<PaymentHistoryItem>

    func adminMetrics() async throws -> AdminMetrics
    func adminMembers(page: Int) async throws -> Paginated<AdminMember>
    func adminMemberDetail(id: Int) async throws -> AdminMember
    func adminPayouts(page: Int) async throws -> Paginated<AdminPayout>
}

// MARK: - Live (real backend)

/// Forwards every call to the real API. Unused while the app runs on mock data,
/// but kept so wiring the backend later is a one-line switch in `AppState`.
struct LiveDataService: DataService {
    let client: APIClient

    func login(email: String, password: String) async throws -> LoginResponse {
        try await client.request(.login(email: email, password: password, deviceName: "LegacyNetwork-iOS"))
    }
    func currentUser() async throws -> User { try await client.request(.currentUser, as: CurrentUserResponse.self).data }
    func logout() async throws { try await client.send(.logout) }
    func dashboard() async throws -> DashboardData { try await client.request(.dashboard) }
    func profile() async throws -> User { try await client.request(.profile, as: CurrentUserResponse.self).data }
    func notifications(page: Int) async throws -> Paginated<NotificationItem> { try await client.request(.notifications(page: page)) }
    func networkTree() async throws -> NetworkNode { try await client.request(.networkTree(rootID: nil)) }
    func leaderboard(period: String) async throws -> [LeaderboardEntry] { try await client.request(.leaderboard(period: period)) }
    func commissions(page: Int) async throws -> Paginated<Commission> { try await client.request(.commissions(page: page)) }
    func earningsSummary() async throws -> EarningsSummary { try await client.request(.earningsSummary) }
    func tokenBalance() async throws -> TokenBalance { try await client.request(.tokenBalance) }
    func tokenTransactions(page: Int) async throws -> Paginated<TokenTransaction> { try await client.request(.tokenTransactions(page: page)) }
    func quizzes() async throws -> [Quiz] { try await client.request(.quizList) }
    func quizSession(id: String) async throws -> QuizSession { try await client.request(.quizSession(id: id)) }
    func submitQuiz(id: String, answers: [String: String]) async throws -> QuizResult {
        let payload = answers.mapValues { AnyEncodable($0) }
        return try await client.request(.submitQuiz(id: id, answers: payload))
    }
    func achievements() async throws -> [Achievement] { try await client.request(.achievements) }
    func subscription() async throws -> Subscription { try await client.request(.subscription) }
    func checkoutPlans() async throws -> [CheckoutPlan] { try await client.request(.checkoutPlans) }
    func paymentMethods() async throws -> [PaymentMethod] { try await client.request(.paymentMethods) }
    func paymentHistory(page: Int) async throws -> Paginated<PaymentHistoryItem> { try await client.request(.paymentHistory(page: page)) }
    func adminMetrics() async throws -> AdminMetrics { try await client.request(.adminMetrics) }
    func adminMembers(page: Int) async throws -> Paginated<AdminMember> { try await client.request(.adminMembers(page: page)) }
    func adminMemberDetail(id: Int) async throws -> AdminMember { try await client.request(.adminMemberDetail(id: "\(id)")) }
    func adminPayouts(page: Int) async throws -> Paginated<AdminPayout> { try await client.request(.adminPayouts(page: page)) }
}
