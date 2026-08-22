import Foundation

/// A node in the distributor genealogy tree. Children are loaded lazily
/// (expand/collapse) via `Endpoint.networkNode(id:)`.
struct NetworkNode: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    var rank: String?
    var avatarURL: URL?
    var directCount: Int?
    var totalCount: Int?
    var volume: Double?
    var isActive: Bool?
    var children: [NetworkNode]?
    var hasChildren: Bool?
}
