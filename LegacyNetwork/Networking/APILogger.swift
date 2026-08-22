import Foundation
import os

/// Debug-only network logging. Compiled out of release via `#if DEBUG`, and
/// never logs the Authorization header value or request bodies containing
/// credentials.
enum APILogger {
    private static let log = Logger(subsystem: "com.legacynetwork.app", category: "network")

    static func request(_ request: URLRequest, endpoint: Endpoint) {
        #if DEBUG
        let method = request.httpMethod ?? "?"
        let url = request.url?.absoluteString ?? "?"
        log.debug("→ \(method, privacy: .public) \(url, privacy: .public)")
        #endif
    }

    static func response(_ response: HTTPURLResponse, endpoint: Endpoint, bytes: Int) {
        #if DEBUG
        log.debug("← \(response.statusCode, privacy: .public) \(endpoint.path, privacy: .public) (\(bytes) bytes)")
        #endif
    }

    static func failure(_ error: Error, endpoint: Endpoint) {
        #if DEBUG
        log.error("✗ \(endpoint.path, privacy: .public): \(String(describing: error), privacy: .public)")
        #endif
    }
}
