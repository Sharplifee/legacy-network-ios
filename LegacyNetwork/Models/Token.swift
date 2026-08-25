import Foundation

/// LGCT token wallet.
struct TokenBalance: Codable, Equatable {
    let balance: Double
    var symbol: String?
    var usdValue: Double?
    var pendingBalance: Double?
}

struct TokenTransaction: Codable, Equatable, Identifiable {
    let id: String
    let type: String        // "earn" | "spend" | "transfer" | ...
    let amount: Double
    let date: Date
    var description: String?
    var balanceAfter: Double?
}
