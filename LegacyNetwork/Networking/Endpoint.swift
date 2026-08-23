import Foundation

/// User role. The Settings screen toggles between these; navigation and
/// endpoint access are gated on the active role.
enum Role: String, Codable, CaseIterable {
    case distributor
    case admin
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Every endpoint the app talks to, as a typed value.
///
/// Paths are seeded from the documented domain model (Sanctum auth, dashboard,
/// network, leaderboard, commissions, earnings, LGCT token, quiz, gamification,
/// notifications, subscription/payments). Reconcile each `path` against the
/// captured route table + call sites before shipping — the enum is the single
/// place a URL is ever constructed.
enum Endpoint {
    // Auth
    case login(email: String, password: String, deviceName: String)
    case logout
    case currentUser

    // Core / shared
    case dashboard
    case profile
    case updateProfile(fields: [String: AnyEncodable])
    case notifications(page: Int)
    case markNotificationRead(id: String)

    // Network / genealogy
    case networkTree(rootID: String?)
    case networkNode(id: String)

    // Earnings & commissions
    case leaderboard(period: String)
    case commissions(page: Int)
    case earningsSummary

    // LGCT token
    case tokenBalance
    case tokenTransactions(page: Int)

    // Gamification
    case quizList
    case quizSession(id: String)
    case submitQuiz(id: String, answers: [String: AnyEncodable])
    case quizResults(id: String)
    case achievements
    case xpSummary            // XP / Level / Streak

    // Subscription & payments
    case subscription
    case paymentMethods
    case paymentHistory(page: Int)

    // Admin-only
    case adminMembers(page: Int)
    case adminMemberDetail(id: String)
    case adminMetrics
    case adminPayouts(page: Int)

    // MARK: - Routing metadata

    var method: HTTPMethod {
        switch self {
        case .login, .logout, .submitQuiz, .markNotificationRead:
            return .post
        case .updateProfile:
            return .patch
        default:
            return .get
        }
    }

    var path: String {
        switch self {
        case .login:                    return "/api/v2/login"
        case .logout:                   return "/api/v2/logout"
        case .currentUser:              return "/api/v2/user"

        case .dashboard:                return "/api/v2/dashboard"
        case .profile:                  return "/api/v2/profile"
        case .updateProfile:            return "/api/v2/profile"
        case .notifications:            return "/api/v2/notifications"
        case .markNotificationRead(let id): return "/api/v2/notifications/\(id)/read"

        case .networkTree:              return "/api/v2/network/tree"
        case .networkNode(let id):      return "/api/v2/network/nodes/\(id)"

        case .leaderboard:              return "/api/v2/leaderboard"
        case .commissions:              return "/api/v2/commissions"
        case .earningsSummary:          return "/api/v2/earnings/summary"

        case .tokenBalance:             return "/api/v2/token/balance"
        case .tokenTransactions:        return "/api/v2/token/transactions"

        case .quizList:                 return "/api/v2/quizzes"
        case .quizSession(let id):      return "/api/v2/quizzes/\(id)"
        case .submitQuiz(let id, _):    return "/api/v2/quizzes/\(id)/submit"
        case .quizResults(let id):      return "/api/v2/quizzes/\(id)/results"
        case .achievements:             return "/api/v2/achievements"
        case .xpSummary:                return "/api/v2/gamification/summary"

        case .subscription:             return "/api/v2/subscription"
        case .paymentMethods:           return "/api/v2/payment/methods"
        case .paymentHistory:           return "/api/v2/payment/history"

        case .adminMembers:             return "/api/v2/admin/members"
        case .adminMemberDetail(let id):return "/api/v2/admin/members/\(id)"
        case .adminMetrics:             return "/api/v2/admin/metrics"
        case .adminPayouts:             return "/api/v2/admin/payouts"
        }
    }

    /// Query items for GET endpoints that paginate/filter.
    var queryItems: [URLQueryItem] {
        switch self {
        case .notifications(let page),
             .commissions(let page),
             .tokenTransactions(let page),
             .paymentHistory(let page),
             .adminMembers(let page),
             .adminPayouts(let page):
            return [URLQueryItem(name: "page", value: String(page))]
        case .leaderboard(let period):
            return [URLQueryItem(name: "period", value: period)]
        case .networkTree(let rootID):
            return rootID.map { [URLQueryItem(name: "root_id", value: $0)] } ?? []
        default:
            return []
        }
    }

    /// JSON body for write endpoints, type-erased so the client can encode it
    /// without opening an existential.
    var body: AnyEncodable? {
        switch self {
        case .login(let email, let password, let deviceName):
            return AnyEncodable(LoginRequest(email: email, password: password, deviceName: deviceName))
        case .updateProfile(let fields):
            return AnyEncodable(fields)
        case .submitQuiz(_, let answers):
            return AnyEncodable(["answers": answers])
        default:
            return nil
        }
    }

    /// Whether this endpoint requires the caller to be in admin mode.
    /// Role-aware routing refuses to call these outside admin mode.
    var requiresAdmin: Bool {
        switch self {
        case .adminMembers, .adminMemberDetail, .adminMetrics, .adminPayouts:
            return true
        default:
            return false
        }
    }

    /// Endpoints that don't require an auth token.
    var isPublic: Bool {
        if case .login = self { return true }
        return false
    }
}

// MARK: - Request/encoding helpers

struct LoginRequest: Encodable {
    let email: String
    let password: String
    let deviceName: String

    enum CodingKeys: String, CodingKey {
        case email, password
        case deviceName = "device_name"
    }
}

/// Type-erased Encodable so heterogeneous form fields can flow through Endpoint.
struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void
    init<T: Encodable>(_ wrapped: T) {
        encodeClosure = wrapped.encode
    }
    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
