import Foundation

/// Lightweight in-memory response cache with TTL, keyed by request URL.
/// Used to serve GET responses instantly on revisit and as an offline fallback.
actor ResponseCache {
    private struct Entry {
        let data: Data
        let storedAt: Date
    }

    private var storage: [String: Entry] = [:]
    private let ttl: TimeInterval

    init(ttl: TimeInterval = 120) {
        self.ttl = ttl
    }

    func store(_ data: Data, for key: String) {
        storage[key] = Entry(data: data, storedAt: Date())
    }

    /// Fresh (within TTL) cached data, if any.
    func fresh(for key: String) -> Data? {
        guard let entry = storage[key],
              Date().timeIntervalSince(entry.storedAt) < ttl else { return nil }
        return entry.data
    }

    /// Any cached data regardless of age (offline fallback).
    func stale(for key: String) -> Data? {
        storage[key]?.data
    }

    func clear() {
        storage.removeAll()
    }
}
