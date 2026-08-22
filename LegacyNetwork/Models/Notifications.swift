import Foundation

struct NotificationItem: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    var body: String?
    var timestamp: Date?
    var read: Bool
    var category: String?
    var deeplink: String?
}

struct Paginated<T: Codable & Equatable>: Codable, Equatable {
    let items: [T]
    var currentPage: Int?
    var lastPage: Int?
    var total: Int?

    enum CodingKeys: String, CodingKey {
        case items = "data"
        case currentPage = "current_page"
        case lastPage = "last_page"
        case total
    }
}
