import SwiftUI

struct QuizSessionView: View {
    @EnvironmentObject private var appState: AppState
    let quizId: String

    @State private var index = 0
    @State private var answers: [String: String] = [:]   // questionId -> optionId
    @State private var submitting = false
    @State private var result: QuizResult?

    var body: some View {
        AsyncScreen(title: "Quiz", load: {
            try await appState.data.quizSession(id: quizId)
        }) { session in
            if let result {
                QuizResultsView(result: result)
            } else {
                quizBody(session)
            }
        }
    }

    @ViewBuilder
    private func quizBody(_ session: QuizSession) -> some View {
        let question = session.questions[min(index, session.questions.count - 1)]
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            ProgressView(value: Double(index + 1), total: Double(session.questions.count))
                .tint(Theme.Color.primary)
            Text("Question \(index + 1) of \(session.questions.count)")
                .font(Theme.Font.caption).foregroundStyle(Theme.Color.textSecondary)
            Text(question.prompt).font(Theme.Font.title)

            ForEach(question.options) { option in
                Button {
                    answers[question.id] = option.id
                } label: {
                    HStack {
                        Text(option.text).font(Theme.Font.body).foregroundStyle(Theme.Color.textPrimary)
                        Spacer()
                        Image(systemName: answers[question.id] == option.id ? "largecircle.fill.circle" : "circle")
                            .foregroundStyle(Theme.Color.primary)
                    }
                    .padding(Theme.Spacing.lg)
                    .background(Theme.Color.surface)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            Spacer()

            PrimaryButton(
                title: index == session.questions.count - 1 ? "Submit" : "Next",
                isLoading: submitting,
                isEnabled: answers[question.id] != nil
            ) {
                if index == session.questions.count - 1 {
                    Task { await submit(session) }
                } else {
                    withAnimation(Theme.Motion.quick) { index += 1 }
                }
            }
        }
        .padding(Theme.Spacing.lg)
        .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
    }

    private func submit(_ session: QuizSession) async {
        submitting = true
        defer { submitting = false }
        do {
            result = try await appState.data.submitQuiz(id: quizId, answers: answers)
        } catch {
            // Surface via a lightweight alert hook in a fuller build.
        }
    }
}
