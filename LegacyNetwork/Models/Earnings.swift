import Foundation

struct LeaderboardEntry: Codable, Equatable, Identifiable {
    let id: String
    let rank: Int
    let name: String
    var avatarURL: URL?
    let value: Double
    var change: Int?
}

struct Commission: Codable, Equatable, Identifiable {
    let id: String
    let type: String
    let amount: Double
    var currency: String?
    let date: Date
    var status: String?
    var sourceName: String?
}

struct EarningsSummary: Codable, Equatable {
    var totalEarned: Double
    var thisPeriod: Double
    var pending: Double
    var currency: String?
    var breakdown: [EarningsBreakdown]?
}

struct EarningsBreakdown: Codable, Equatable, Identifiable {
    var id: String { label }
    let label: String
    let amount: Double
}
