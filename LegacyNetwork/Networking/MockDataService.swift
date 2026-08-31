import Foundation

/// Serves every screen from in-memory fixtures. Two skins:
/// - `.current` — representative "populated" data (what the live app looks like).
/// - `.growth`  — the same shapes scaled by a factor that ramps up over real
///   elapsed time, to demonstrate gradual growth.
///
/// No real member or payment records are embedded — these are illustrative
/// values shaped like the real responses.
struct MockDataService: DataService {
    let skin: AppSkin

    // MARK: growth scaling

    /// 1.0 for `.current`; for `.growth`, starts small and climbs toward 1.0
    /// over real days since first launch.
    private var g: Double {
        guard skin == .growth else { return 1.0 }
        let key = "growth_anchor_epoch"
        let now = Date().timeIntervalSince1970
        let stored = UserDefaults.standard.double(forKey: key)
        let anchor: Double
        if stored == 0 { UserDefaults.standard.set(now, forKey: key); anchor = now } else { anchor = stored }
        let days = max(0, (now - anchor) / 86_400)
        return min(1.0, 0.15 + days * 0.03)
    }

    private func money(_ v: Double) -> Double { ((v * g) * 100).rounded() / 100 }
    private func count(_ v: Int, min lo: Int = 0) -> Int { max(lo, Int((Double(v) * g).rounded())) }
    private func daysAgo(_ n: Int) -> Date { Calendar.current.date(byAdding: .day, value: -n, to: Date()) ?? Date() }
    private func daysAhead(_ n: Int) -> Date { Calendar.current.date(byAdding: .day, value: n, to: Date()) ?? Date() }

    // MARK: auth

    private var demoUser: User {
        User(id: 1, email: "dianne@legacynetwork.com", fullname: "Dianne Leavitt",
             firstName: "Dianne", middleName: nil, lastName: "Leavitt",
             isAdmin: true, isDistributor: true, isActivated: true, isSubscribed: true,
             isTrainingDone: true, isPaid: false, isOrphan: true, partnerAdmin: false,
             tierId: 3, tier: Tier(id: 3, name: "Pro", slug: "pro", price: "0.00",
                 formattedPrice: "$0.00", isPaid: true, isFree: false, isActive: true, status: "active"),
             isTrial: false, trialEndsAt: nil, trialDaysRemaining: nil,
             isTrialActive: false, isTrialExpired: false,
             dateOfBirth: nil, gender: nil, mobile: nil, intlMobile: nil, avatar: nil,
             synergyId: "180555", synergyStatus: "ACTIVE", siteOrigin: "legacy", userLang: "en",
             status: "active", hash: nil, allowNotification: true,
             incomeGoalAmount: "5000", incomeGoalTargetDate: "2027-06-30",
             mailingAddress1: nil, mailingAddress2: nil, mailingCity: nil,
             mailingState: nil, mailingPostalCode: nil, mailingCountry: nil)
    }
    func login(email: String, password: String) async throws -> LoginResponse {
        LoginResponse(data: demoUser, token: "mock-session-token", accessToken: "mock-session-token", refreshToken: nil, tokenType: "Bearer", expiresIn: 86400, pelagoJwe: nil)
    }
    func currentUser() async throws -> User { demoUser }
    func profile() async throws -> User { demoUser }
    func logout() async throws {}

    // MARK: dashboard

    func dashboard() async throws -> DashboardData {
        DashboardData(
            greeting: "Welcome back, Dianne",
            stats: [
                DashboardStat(key: "volume", label: "Rank Volume", value: "\(count(48210)) BV", deltaPercent: 12.4, trend: "up"),
                DashboardStat(key: "team", label: "Team Size", value: "\(count(1284))", deltaPercent: 8.1, trend: "up"),
                DashboardStat(key: "month", label: "This Month", value: fmtMoney(money(9420)), deltaPercent: 5.7, trend: "up"),
                DashboardStat(key: "lgct", label: "LGCT", value: "\(count(3150))", deltaPercent: 2.3, trend: "up"),
            ],
            xp: XPSummary(level: max(1, count(14, min: 1)), xp: count(2450, min: 40),
                          xpToNextLevel: 550, streakDays: count(23, min: 1), title: "Director"),
            recentActivity: [
                ActivityItem(id: "a1", title: "New team member joined", subtitle: "Marcus Bell enrolled under you", timestamp: daysAgo(0), iconName: "person.badge.plus"),
                ActivityItem(id: "a2", title: "Commission paid", subtitle: fmtMoney(money(420)) + " · Team Bonus", timestamp: daysAgo(1), iconName: "dollarsign.circle"),
                ActivityItem(id: "a3", title: "Rank advanced", subtitle: "You reached Director", timestamp: daysAgo(4), iconName: "rosette"),
            ]
        )
    }

    func notifications(page: Int) async throws -> Paginated<NotificationItem> {
        let items = [
            NotificationItem(id: "n1", title: "Commission deposited", body: fmtMoney(money(420)) + " has been added to your balance.", timestamp: daysAgo(0), read: false, category: "earnings", deeplink: nil),
            NotificationItem(id: "n2", title: "New enrollment", body: "Marcus Bell joined your team.", timestamp: daysAgo(1), read: false, category: "network", deeplink: nil),
            NotificationItem(id: "n3", title: "Quiz completed", body: "You earned 50 XP on Product Basics.", timestamp: daysAgo(2), read: true, category: "learn", deeplink: nil),
            NotificationItem(id: "n4", title: "Payout scheduled", body: "Your weekly payout is on its way.", timestamp: daysAgo(3), read: true, category: "earnings", deeplink: nil),
        ]
        return Paginated(items: items, currentPage: 1, lastPage: 1, total: items.count)
    }

    // MARK: network

    func networkTree() async throws -> NetworkNode {
        func node(_ id: String, _ name: String, _ rank: String, _ total: Int, children: [NetworkNode]? = nil) -> NetworkNode {
            NetworkNode(id: id, name: name, rank: rank, avatarURL: nil,
                        directCount: children?.count ?? 0, totalCount: count(total, min: 1),
                        volume: money(Double(total) * 40), isActive: true,
                        children: children, hasChildren: children?.isEmpty == false)
        }
        return node("root", "Dianne Leavitt", "Director", 1284, children: [
            node("c1", "Marcus Bell", "Manager", 312, children: [
                node("c1a", "Priya Shah", "Associate", 84),
                node("c1b", "Leo Martin", "Associate", 61),
            ]),
            node("c2", "Ava Reynolds", "Manager", 268, children: [
                node("c2a", "Noah Kim", "Associate", 73),
            ]),
            node("c3", "Sofia Nguyen", "Associate", 149),
        ])
    }

    func leaderboard(period: String) async throws -> [LeaderboardEntry] {
        let names = ["Dianne Leavitt", "Marcus Bell", "Ava Reynolds", "Sofia Nguyen", "Noah Kim", "Priya Shah", "Leo Martin", "Grace Owens"]
        return names.enumerated().map { i, name in
            LeaderboardEntry(id: "l\(i)", rank: i + 1, name: name, avatarURL: nil,
                             value: money(Double(9800 - i * 900)), change: (i % 3) - 1)
        }
    }

    // MARK: earnings

    func commissions(page: Int) async throws -> Paginated<Commission> {
        let types = ["Team Bonus", "Retail Profit", "Rank Bonus", "Matching Bonus", "Fast Start"]
        let items = (0..<8).map { i in
            Commission(id: "cm\(i)", type: types[i % types.count], amount: money(Double(120 + i * 45)),
                       currency: "USD", date: daysAgo(i * 3), status: i == 0 ? "pending" : "paid",
                       sourceName: types[i % types.count])
        }
        return Paginated(items: items, currentPage: 1, lastPage: 1, total: items.count)
    }

    func earningsSummary() async throws -> EarningsSummary {
        EarningsSummary(
            totalEarned: money(84210), thisPeriod: money(9420), pending: money(420), currency: "USD",
            breakdown: [
                EarningsBreakdown(label: "Team Bonus", amount: money(4200)),
                EarningsBreakdown(label: "Retail Profit", amount: money(2650)),
                EarningsBreakdown(label: "Rank Bonus", amount: money(1800)),
                EarningsBreakdown(label: "Matching Bonus", amount: money(770)),
            ]
        )
    }

    // MARK: token

    func tokenBalance() async throws -> TokenBalance {
        TokenBalance(balance: Double(count(3150, min: 25)), symbol: "LGCT",
                     usdValue: money(3150 * 0.42), pendingBalance: Double(count(120)))
    }
    func tokenTransactions(page: Int) async throws -> Paginated<TokenTransaction> {
        let items = (0..<7).map { i in
            let earn = i % 2 == 0
            return TokenTransaction(id: "t\(i)", type: earn ? "earn" : "spend",
                                    amount: Double(earn ? 1 : -1) * Double(count(50 + i * 10, min: 1)),
                                    date: daysAgo(i * 2),
                                    description: earn ? "Quiz reward" : "Marketplace purchase",
                                    balanceAfter: Double(count(3150 - i * 40)))
        }
        return Paginated(items: items, currentPage: 1, lastPage: 1, total: items.count)
    }

    // MARK: learn / gamification

    func quizzes() async throws -> [Quiz] {
        [
            Quiz(id: "q1", title: "Product Basics", description: "Learn the core product line.", questionCount: 5, xpReward: 50, completed: true, bestScore: 5),
            Quiz(id: "q2", title: "Compensation Plan", description: "How ranks and bonuses work.", questionCount: 6, xpReward: 75, completed: false, bestScore: nil),
            Quiz(id: "q3", title: "Sharing Legacy", description: "Best practices for enrolling.", questionCount: 4, xpReward: 40, completed: false, bestScore: nil),
        ]
    }
    func quizSession(id: String) async throws -> QuizSession {
        QuizSession(id: id, title: "Compensation Plan", questions: [
            QuizQuestion(id: "qq1", prompt: "What drives Rank Volume?", options: [
                QuizOption(id: "o1", text: "Team purchases + retail"),
                QuizOption(id: "o2", text: "Only your purchases"),
                QuizOption(id: "o3", text: "Login streak"),
            ], type: "single"),
            QuizQuestion(id: "qq2", prompt: "Matching Bonus pays on…", options: [
                QuizOption(id: "o1", text: "Your personally enrolled team"),
                QuizOption(id: "o2", text: "The whole company"),
                QuizOption(id: "o3", text: "Retail only"),
            ], type: "single"),
        ], timeLimitSeconds: nil)
    }
    func submitQuiz(id: String, answers: [String: String]) async throws -> QuizResult {
        QuizResult(quizId: id, score: answers.count, total: 2, passed: true, xpEarned: 75, correctIds: Array(answers.values))
    }
    func achievements() async throws -> [Achievement] {
        [
            Achievement(id: "ac1", name: "First Enrollment", description: "Enroll your first member", iconURL: nil, unlocked: true, unlockedAt: daysAgo(120), progress: 1),
            Achievement(id: "ac2", name: "Director Rank", description: "Reach Director", iconURL: nil, unlocked: g >= 0.6, unlockedAt: g >= 0.6 ? daysAgo(4) : nil, progress: min(1, g + 0.2)),
            Achievement(id: "ac3", name: "30-Day Streak", description: "Log in 30 days straight", iconURL: nil, unlocked: false, unlockedAt: nil, progress: min(1, g)),
            Achievement(id: "ac4", name: "Token Holder", description: "Hold 5,000 LGCT", iconURL: nil, unlocked: false, unlockedAt: nil, progress: min(1, g * 0.63)),
        ]
    }

    // MARK: billing

    func subscription() async throws -> Subscription {
        Subscription(planName: "Legacy Pro", status: "active", renewsAt: daysAhead(18),
                     priceLabel: "$49.00 / mo", processor: "stripe")
    }
    func checkoutPlans() async throws -> [CheckoutPlan] {
        [
            CheckoutPlan(
                id: "starter", name: "Legacy Starter", priceMonthly: 19,
                priceLabel: "$19.00", period: "per month",
                tagline: "Get started building your network.",
                features: [
                    "Personal distributor dashboard",
                    "Up to 2 network levels",
                    "Standard commission rate",
                    "Community learning quizzes",
                ],
                isPopular: false, badge: nil
            ),
            CheckoutPlan(
                id: "pro", name: "Legacy Pro", priceMonthly: 49,
                priceLabel: "$49.00", period: "per month",
                tagline: "For active distributors growing a team.",
                features: [
                    "Everything in Starter",
                    "Unlimited network levels",
                    "Boosted commission rate + LGCT rewards",
                    "Full leaderboard & earnings analytics",
                    "Priority support",
                ],
                isPopular: true, badge: "Most popular"
            ),
            CheckoutPlan(
                id: "elite", name: "Legacy Elite", priceMonthly: 99,
                priceLabel: "$99.00", period: "per month",
                tagline: "Maximum earning power and tools.",
                features: [
                    "Everything in Pro",
                    "Admin & team management tools",
                    "Highest commission tier",
                    "Early access to new features",
                    "Dedicated account manager",
                ],
                isPopular: false, badge: "Best value"
            ),
        ]
    }
    func paymentMethods() async throws -> [PaymentMethod] {
        [
            PaymentMethod(id: "pm1", brand: "visa", last4: "4242", expMonth: 8, expYear: 2028, isDefault: true),
            PaymentMethod(id: "pm2", brand: "mastercard", last4: "4444", expMonth: 3, expYear: 2027, isDefault: false),
        ]
    }
    func paymentHistory(page: Int) async throws -> Paginated<PaymentHistoryItem> {
        let items = (0..<6).map { i in
            PaymentHistoryItem(id: "ph\(i)", amount: 49.00, currency: "USD", date: daysAgo(i * 30),
                               status: "paid", description: "Legacy Pro — monthly", receiptURL: nil)
        }
        return Paginated(items: items, currentPage: 1, lastPage: 1, total: items.count)
    }

    // MARK: admin

    func adminMetrics() async throws -> AdminMetrics {
        AdminMetrics(totalMembers: count(18420, min: 10), activeMembers: count(12180, min: 6),
                     totalVolume: money(1_940_000), pendingPayouts: money(86200),
                     breakdown: [
                        DashboardStat(key: "new", label: "New This Week", value: "\(count(214))", deltaPercent: 6.2, trend: "up"),
                        DashboardStat(key: "churn", label: "Churn", value: "1.8%", deltaPercent: -0.3, trend: "down"),
                     ])
    }
    func adminMembers(page: Int) async throws -> Paginated<AdminMember> {
        let names = ["Marcus Bell", "Ava Reynolds", "Sofia Nguyen", "Noah Kim", "Priya Shah", "Leo Martin", "Grace Owens", "Ethan Cole"]
        let items = names.enumerated().map { i, name in
            AdminMember(id: 100 + i, name: name, email: name.lowercased().replacingOccurrences(of: " ", with: ".") + "@example.com",
                        role: i % 4 == 0 ? "manager" : "distributor", status: i % 5 == 0 ? "inactive" : "active",
                        joinedAt: daysAgo(30 + i * 12), volume: money(Double(1200 + i * 300)))
        }
        return Paginated(items: items, currentPage: 1, lastPage: 1, total: items.count)
    }
    func adminMemberDetail(id: Int) async throws -> AdminMember {
        AdminMember(id: id, name: "Marcus Bell", email: "marcus.bell@example.com", role: "manager",
                    status: "active", joinedAt: daysAgo(96), volume: money(3120))
    }
    func adminPayouts(page: Int) async throws -> Paginated<AdminPayout> {
        let names = ["Marcus Bell", "Ava Reynolds", "Sofia Nguyen", "Noah Kim", "Priya Shah"]
        let items = names.enumerated().map { i, name in
            AdminPayout(id: "po\(i)", memberName: name, amount: money(Double(280 + i * 120)),
                        status: i == 0 ? "processing" : "paid", date: daysAgo(i * 2))
        }
        return Paginated(items: items, currentPage: 1, lastPage: 1, total: items.count)
    }
}

/// Currency formatter shared with the mock layer.
private func fmtMoney(_ v: Double, _ currency: String = "USD") -> String {
    let f = NumberFormatter(); f.numberStyle = .currency; f.currencyCode = currency
    return f.string(from: NSNumber(value: v)) ?? String(format: "%.2f", v)
}
