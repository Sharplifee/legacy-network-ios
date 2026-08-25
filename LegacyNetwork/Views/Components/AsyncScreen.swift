import SwiftUI

/// Wraps a screen's async load in the standard loading/error/empty/loaded
/// states, with pull-to-refresh. Each feature screen supplies a loader and a
/// content builder.
struct AsyncScreen<Value, Content: View>: View {
    var title: String
    var isEmpty: (Value) -> Bool = { _ in false }
    var emptyTitle: String = "Nothing here yet"
    let load: () async throws -> Value
    @ViewBuilder let content: (Value) -> Content

    @State private var state: Loadable<Value> = .idle

    var body: some View {
        LoadableContent(
            state: state,
            retry: { Task { await run() } },
            isEmpty: isEmpty,
            emptyTitle: emptyTitle,
            content: content
        )
        .navigationTitle(title)
        .task { if case .idle = state { await run() } }
        .refreshable { await run() }
    }

    private func run() async {
        state = .loading
        do {
            state = .loaded(try await load())
        } catch let error as APIError {
            state = .failed(error)
        } catch {
            state = .failed(.transport(error.localizedDescription))
        }
    }
}

/// Small labeled stat tile used across dashboard/earnings/admin.
struct StatTile: View {
    let label: String
    let value: String
    var delta: Double?

    var body: some View {
        Card(padding: Theme.Spacing.lg) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(label.uppercased())
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Color.textSecondary)
                Text(value)
                    .font(Theme.Font.title)
                    .foregroundStyle(Theme.Color.textPrimary)
                if let delta {
                    Label("\(delta >= 0 ? "+" : "")\(String(format: "%.1f", delta))%",
                          systemImage: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(Theme.Font.caption)
                        .foregroundStyle(delta >= 0 ? Theme.Color.success : Theme.Color.danger)
                }
            }
        }
    }
}
