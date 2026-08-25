import Foundation

struct DashboardData: Codable, Equatable {
    var greeting: String?
    var stats: [DashboardStat]
    var xp: XPSummary?
    var recentActivity: [ActivityItem]?
}

struct DashboardStat: Codable, Equatable, Identifiable {
    var id: String { key }
    let key: String
    let label: String
    let value: String
    var deltaPercent: Double?
    var trend: String?   // "up" | "down" | "flat"
}

struct ActivityItem: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    var subtitle: String?
    var timestamp: Date?
    var iconName: String?
}
