import Foundation

/// Reusable async loader that drives a `Loadable` state for a screen.
/// Keeps view models thin — each screen constructs one with a closure.
@MainActor
final class DataStore<Value>: ObservableObject {
    @Published private(set) var state: Loadable<Value> = .idle

    private let loader: () async throws -> Value

    init(_ loader: @escaping () async throws -> Value) {
        self.loader = loader
    }

    func load(force: Bool = false) async {
        if case .loaded = state, !force { return }
        state = .loading
        do {
            let value = try await loader()
            state = .loaded(value)
        } catch let error as APIError {
            state = .failed(error)
        } catch {
            state = .failed(.transport(error.localizedDescription))
        }
    }

    func reload() async { await load(force: true) }
}
