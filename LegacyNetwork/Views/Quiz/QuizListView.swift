import SwiftUI

struct QuizListView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        AsyncScreen(title: "Learn",
                    isEmpty: { $0.isEmpty },
                    emptyTitle: "No quizzes available",
                    load: {
            try await appState.client.request(.quizList, as: [Quiz].self)
        }) { quizzes in
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    ForEach(quizzes) { quiz in
                        NavigationLink { QuizSessionView(quizId: quiz.id) } label: {
                            Card {
                                HStack {
                                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                                        Text(quiz.title).font(Theme.Font.headline)
                                        if let desc = quiz.description {
                                            Text(desc).font(Theme.Font.footnote).foregroundStyle(Theme.Color.textSecondary).lineLimit(2)
                                        }
                                        HStack(spacing: Theme.Spacing.md) {
                                            if let q = quiz.questionCount { Label("\(q)", systemImage: "list.bullet") }
                                            if let xp = quiz.xpReward { Label("\(xp) XP", systemImage: "star.fill") }
                                        }
                                        .font(Theme.Font.caption)
                                        .foregroundStyle(Theme.Color.textSecondary)
                                    }
                                    Spacer()
                                    if quiz.completed == true {
                                        Image(systemName: "checkmark.seal.fill").foregroundStyle(Theme.Color.success)
                                    } else {
                                        CircleChevron()
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
        }
    }
}
