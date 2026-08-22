import SwiftUI

struct TokenView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        AsyncScreen(title: "LGCT", load: {
            async let balance = appState.client.request(.tokenBalance, as: TokenBalance.self)
            async let txns = appState.client.request(.tokenTransactions(page: 1), as: Paginated<TokenTransaction>.self)
            return try await (balance: balance, txns: txns)
        }) { data in
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    Card {
                        VStack(spacing: Theme.Spacing.xs) {
                            Text("Balance").font(Theme.Font.caption).foregroundStyle(Theme.Color.textSecondary)
                            Text("\(String(format: "%.2f", data.balance.balance)) \(data.balance.symbol ?? "LGCT")")
                                .font(Theme.Font.largeTitle)
                                .foregroundStyle(Theme.Color.primary)
                            if let usd = data.balance.usdValue {
                                Text("≈ \(money(usd))").font(Theme.Font.footnote).foregroundStyle(Theme.Color.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }

                    if data.txns.items.isEmpty {
                        EmptyStateView(title: "No transactions yet")
                    } else {
                        Card(padding: 0) {
                            VStack(spacing: 0) {
                                ForEach(data.txns.items) { txn in
                                    HStack {
                                        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                                            Text(txn.description ?? txn.type.capitalized).font(Theme.Font.body)
                                            Text(txn.date, style: .date).font(Theme.Font.caption).foregroundStyle(Theme.Color.textSecondary)
                                        }
                                        Spacer()
                                        Text("\(txn.amount >= 0 ? "+" : "")\(String(format: "%.2f", txn.amount))")
                                            .font(Theme.Font.subhead)
                                            .foregroundStyle(txn.amount >= 0 ? Theme.Color.success : Theme.Color.danger)
                                    }
                                    .padding(Theme.Spacing.lg)
                                    if txn.id != data.txns.items.last?.id { Divider().padding(.leading, Theme.Spacing.lg) }
                                }
                            }
                        }
                    }
                }
                .padding(Theme.Spacing.lg)
            }
            .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
        }
    }
}
