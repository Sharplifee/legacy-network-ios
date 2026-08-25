import Foundation

/// Central async/await networking client for the Legacy Network backend.
///
/// Responsibilities:
/// - Build requests from the typed `Endpoint` enum
/// - Attach the Sanctum bearer token
/// - Role-aware routing (refuses admin endpoints outside admin mode)
/// - Retry with exponential backoff for transient failures
/// - Response caching (GET) + offline fallback
/// - 401 handling via a token-invalidation hook
/// - Typed errors and debug-only logging
actor APIClient {
    static let baseURL = URL(string: "https://api.legacynetwork.com")!

    private let session: URLSession
    private let cache = ResponseCache()
    private let offlineQueue = OfflineQueue()
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    /// Supplies the current token (from AuthManager/Keychain).
    private let tokenProvider: @Sendable () -> String?
    /// Supplies the currently active role (from RoleManager).
    private let roleProvider: @Sendable () -> Role
    /// Called when the server rejects the token (401) so auth state can reset.
    private let onUnauthorized: @Sendable () async -> Void

    private let maxRetries = 3

    init(
        session: URLSession = .shared,
        tokenProvider: @escaping @Sendable () -> String?,
        roleProvider: @escaping @Sendable () -> Role,
        onUnauthorized: @escaping @Sendable () async -> Void
    ) {
        self.session = session
        self.tokenProvider = tokenProvider
        self.roleProvider = roleProvider
        self.onUnauthorized = onUnauthorized

        let dec = JSONDecoder()
        dec.keyDecodingStrategy = .convertFromSnakeCase
        dec.dateDecodingStrategy = .iso8601
        self.decoder = dec

        let enc = JSONEncoder()
        enc.keyEncodingStrategy = .convertToSnakeCase
        enc.dateEncodingStrategy = .iso8601
        self.encoder = enc
    }

    // MARK: - Public request API

    /// Perform a request and decode the response into `T`.
    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type = T.self) async throws -> T {
        // Role-aware routing: never call admin endpoints outside admin mode.
        if endpoint.requiresAdmin && roleProvider() != .admin {
            throw APIError.forbidden
        }

        let data = try await perform(endpoint)
        do {
            return try decoder.decode(APIResponse<T>.self, from: data).unwrap()
        } catch let error as APIError {
            throw error
        } catch {
            APILogger.failure(error, endpoint: endpoint)
            throw APIError.decoding(String(describing: error))
        }
    }

    /// Perform a request with no decoded return value.
    @discardableResult
    func send(_ endpoint: Endpoint) async throws -> Data {
        if endpoint.requiresAdmin && roleProvider() != .admin {
            throw APIError.forbidden
        }
        return try await perform(endpoint)
    }

    // MARK: - Core

    private func perform(_ endpoint: Endpoint) async throws -> Data {
        let request = try buildRequest(endpoint)
        let cacheKey = request.url?.absoluteString ?? endpoint.path

        // Serve fresh cache for idempotent GETs.
        if endpoint.method == .get, let cached = await cache.fresh(for: cacheKey) {
            return cached
        }

        var attempt = 0
        var lastError: APIError = .transport("unknown")

        while attempt <= maxRetries {
            do {
                APILogger.request(request, endpoint: endpoint)
                let (data, response) = try await session.data(for: request)
                guard let http = response as? HTTPURLResponse else {
                    throw APIError.transport("Non-HTTP response")
                }
                APILogger.response(http, endpoint: endpoint, bytes: data.count)

                switch http.statusCode {
                case 200...299:
                    if endpoint.method == .get {
                        await cache.store(data, for: cacheKey)
                    }
                    return data
                case 401:
                    await onUnauthorized()
                    throw APIError.unauthorized
                case 403:
                    throw APIError.forbidden
                case 404:
                    throw APIError.notFound
                case 429:
                    let retryAfter = http.value(forHTTPHeaderField: "Retry-After").flatMap(TimeInterval.init)
                    throw APIError.rateLimited(retryAfter: retryAfter)
                case 500...599:
                    throw APIError.server(status: http.statusCode, message: nil)
                default:
                    throw APIError.server(status: http.statusCode, message: nil)
                }
            } catch let error as APIError {
                lastError = error
                if !error.isRetryable { throw error }
            } catch let urlError as URLError {
                if urlError.code == .cancelled { throw APIError.cancelled }
                lastError = urlError.code == .notConnectedToInternet ? .offline : .transport(urlError.localizedDescription)
            } catch {
                lastError = .transport(error.localizedDescription)
            }

            // Backoff before next attempt.
            attempt += 1
            if attempt <= maxRetries {
                let delay = backoffDelay(attempt: attempt, error: lastError)
                try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }

        // Offline GET fallback: serve stale cache if we have it.
        if case .offline = lastError, endpoint.method == .get,
           let stale = await cache.stale(for: cacheKey) {
            return stale
        }

        // Offline mutation: queue for replay.
        if case .offline = lastError, endpoint.method != .get {
            await enqueueOffline(endpoint, request: request)
        }

        throw lastError
    }

    private func backoffDelay(attempt: Int, error: APIError) -> TimeInterval {
        if case .rateLimited(let retryAfter) = error, let retryAfter { return retryAfter }
        // Exponential: 2s, 4s, 8s (matches repo git-op backoff convention).
        return pow(2.0, Double(attempt))
    }

    // MARK: - Request building

    private func buildRequest(_ endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(
            url: Self.baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: false
        )
        if !endpoint.queryItems.isEmpty {
            components?.queryItems = endpoint.queryItems
        }
        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if !endpoint.isPublic {
            guard let token = tokenProvider() else { throw APIError.notAuthenticated }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = endpoint.body {
            request.httpBody = try encoder.encode(body)
        }
        return request
    }

    private func enqueueOffline(_ endpoint: Endpoint, request: URLRequest) async {
        let pending = OfflineQueue.PendingRequest(
            id: UUID(),
            path: endpoint.path,
            method: endpoint.method.rawValue,
            body: request.httpBody,
            createdAt: Date()
        )
        await offlineQueue.enqueue(pending)
    }

    func clearCaches() async {
        await cache.clear()
    }
}

// MARK: - Envelope

/// Laravel API responses are typically wrapped. Support both `{ "data": … }`
/// and bare payloads by attempting the envelope first, then the raw value.
struct APIResponse<T: Decodable>: Decodable {
    private let data: T?
    private let raw: T?

    init(from decoder: Decoder) throws {
        // Try { "data": T }
        if let keyed = try? decoder.container(keyedBy: CodingKeys.self),
           let value = try? keyed.decode(T.self, forKey: .data) {
            data = value
            raw = nil
            return
        }
        // Fall back to bare T
        let single = try decoder.singleValueContainer()
        raw = try single.decode(T.self)
        data = nil
    }

    private enum CodingKeys: String, CodingKey { case data }

    func unwrap() throws -> T {
        if let data { return data }
        if let raw { return raw }
        throw APIError.decoding("Empty response envelope")
    }
}
