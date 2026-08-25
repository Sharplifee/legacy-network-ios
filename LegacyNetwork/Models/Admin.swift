import Foundation

/// Admin-only models. Only fetched when the active role is `.admin`; the
/// networking layer refuses these requests otherwise.
struct AdminMetrics: Codable, Equatable {
    var totalMembers: Int
    var activeMembers: Int
    var totalVolume: Double
    var pendingPayouts: Double
    var breakdown: [DashboardStat]?
}

struct AdminMember: Codable, Equatable, Identifiable {
    let id: Int
    let name: String
    let email: String
    var role: String?
    var status: String?
    var joinedAt: Date?
    var volume: Double?
}

struct AdminPayout: Codable, Equatable, Identifiable {
    let id: String
    let memberName: String
    let amount: Double
    var status: String?
    let date: Date
}
