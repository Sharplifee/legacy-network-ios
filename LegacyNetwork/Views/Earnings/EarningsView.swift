import SwiftUI

struct EarningsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        AsyncScreen(title: "Earnings", load: {
            try await appState.data.earningsSummary()
        }) { summary in
            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Theme.Spacing.md) {
                        StatTile(label: "Total Earned", value: money(summary.totalEarned, summary.currency))
                        StatTile(label: "This Period", value: money(summary.thisPeriod, summary.currency))
                        StatTile(label: "Pending", value: money(summary.pending, summary.currency))
                    }

                    if let breakdown = summary.breakdown, !breakdown.isEmpty {
                        Text("Breakdown").font(Theme.Font.headline)
                        Card(padding: 0) {
                            VStack(spacing: 0) {
                                ForEach(breakdown) { row in
                                    HStack {
                                        Text(row.label).font(Theme.Font.body)
                                        Spacer()
                                        Text(money(row.amount, summary.currency)).font(Theme.Font.subhead)
                                    }
                                    .padding(Theme.Spacing.lg)
                                    if row.id != breakdown.last?.id { Divider().padding(.leading, Theme.Spacing.lg) }
                                }
                            }
                        }
                    }

                    NavigationLink { CommissionsView() } label: {
                        HStack {
                            Text("View Commissions").font(Theme.Font.body)
                            Spacer()
                            CircleChevron()
                        }
                        .padding(Theme.Spacing.lg)
                        .background(Theme.Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    NavigationLink { TokenView() } label: {
                        HStack {
                            Text("LGCT Token Wallet").font(Theme.Font.body)
                            Spacer()
                            CircleChevron()
                        }
                        .padding(Theme.Spacing.lg)
                        .background(Theme.Color.surface)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
        }
    }
}

func money(_ value: Double, _ currency: String? = nil) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = currency ?? "USD"
    return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
}
