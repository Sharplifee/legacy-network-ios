import Foundation

/// Queues mutating requests made while offline so they can be replayed once
/// connectivity returns. Persisted to disk so the queue survives relaunch.
actor OfflineQueue {
    struct PendingRequest: Codable {
        let id: UUID
        let path: String
        let method: String
        let body: Data?
        let createdAt: Date
    }

    private var queue: [PendingRequest] = []
    private let fileURL: URL

    init(filename: String = "offline_queue.json") {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        fileURL = dir.appendingPathComponent(filename)
        load()
    }

    func enqueue(_ request: PendingRequest) {
        queue.append(request)
        persist()
    }

    func dequeueAll() -> [PendingRequest] {
        let items = queue
        queue.removeAll()
        persist()
        return items
    }

    var count: Int { queue.count }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([PendingRequest].self, from: data) else { return }
        queue = decoded
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(queue) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
