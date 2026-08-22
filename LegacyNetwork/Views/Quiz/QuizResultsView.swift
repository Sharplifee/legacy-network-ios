import SwiftUI

struct QuizResultsView: View {
    let result: QuizResult

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Image(systemName: (result.passed ?? false) ? "checkmark.seal.fill" : "xmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle((result.passed ?? false) ? Theme.Color.success : Theme.Color.danger)
            Text("\(result.score) / \(result.total)")
                .font(Theme.Font.largeTitle)
            if let xp = result.xpEarned {
                Label("+\(xp) XP", systemImage: "star.fill")
                    .font(Theme.Font.headline)
                    .foregroundStyle(Theme.Color.warning)
            }
            Text((result.passed ?? false) ? "Nicely done!" : "Keep practicing.")
                .font(Theme.Font.body)
                .foregroundStyle(Theme.Color.textSecondary)
        }
        .padding(Theme.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
    }
}
