import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: Int
    let name: String
    let email: String
    var avatarURL: URL?
    /// Server flag indicating the account may switch into admin mode.
    var canUseAdmin: Bool
    var roles: [String]?

    enum CodingKeys: String, CodingKey {
        case id, name, email, roles
        case avatarURL = "avatar_url"
        case canUseAdmin = "can_use_admin"
    }
}

struct LoginResponse: Codable {
    let token: String
    let user: User
}
