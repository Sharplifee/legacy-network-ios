import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var appState: AppState
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        AsyncScreen(title: "Achievements",
                    isEmpty: { $0.isEmpty },
                    emptyTitle: "No achievements yet",
                    load: {
            try await appState.data.achievements()
        }) { items in
            ScrollView {
                LazyVGrid(columns: columns, spacing: Theme.Spacing.md) {
                    ForEach(items) { a in
                        Card {
                            VStack(spacing: Theme.Spacing.sm) {
                                ZStack {
                                    Circle().fill(a.unlocked ? Theme.Color.primary.opacity(0.15) : Theme.Color.surfaceSecondary)
                                        .frame(width: 56, height: 56)
                                    Image(systemName: a.unlocked ? "rosette" : "lock.fill")
                                        .foregroundStyle(a.unlocked ? Theme.Color.primary : Theme.Color.textSecondary)
                                }
                                Text(a.name).font(Theme.Font.subhead).multilineTextAlignment(.center)
                                if let progress = a.progress, !a.unlocked {
                                    ProgressView(value: progress).tint(Theme.Color.accent)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
        }
    }
}
