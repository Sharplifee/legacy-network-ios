import Foundation

/// Typed errors surfaced by the networking layer.
enum APIError: Error, Equatable {
    case invalidURL
    case notAuthenticated
    case unauthorized                 // 401 — token invalid/expired
    case forbidden                    // 403 — role not permitted (e.g. admin-gated)
    case notFound                     // 404
    case rateLimited(retryAfter: TimeInterval?)   // 429
    case server(status: Int, message: String?)    // 5xx / other
    case decoding(String)
    case offline
    case transport(String)
    case cancelled

    /// User-facing message. Never leaks tokens or raw payloads.
    var userMessage: String {
        switch self {
        case .invalidURL:        return "Something went wrong building the request."
        case .notAuthenticated:  return "Please sign in to continue."
        case .unauthorized:      return "Your session expired. Please sign in again."
        case .forbidden:         return "You don't have access to this."
        case .notFound:          return "We couldn't find what you were looking for."
        case .rateLimited:       return "Too many requests. Please try again in a moment."
        case .server:            return "The server had a problem. Please try again."
        case .decoding:          return "We received an unexpected response."
        case .offline:           return "You appear to be offline."
        case .transport:         return "A network error occurred. Please try again."
        case .cancelled:         return "The request was cancelled."
        }
    }

    var isRetryable: Bool {
        switch self {
        case .rateLimited, .server, .transport, .offline: return true
        default: return false
        }
    }
}
