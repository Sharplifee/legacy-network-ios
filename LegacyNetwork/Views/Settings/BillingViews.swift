import SwiftUI

struct SubscriptionView: View {
    @EnvironmentObject private var appState: AppState
    var body: some View {
        AsyncScreen(title: "Subscription", load: {
            try await appState.data.subscription()
        }) { sub in
            ScrollView {
                VStack(spacing: Theme.Spacing.lg) {
                    Card {
                        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                            HStack {
                                Text(sub.planName).font(Theme.Font.headline)
                                Spacer()
                                StatusBadge(status: sub.status)
                            }
                            if let price = sub.priceLabel { LabeledRow(label: "Price", value: price) }
                            if let renews = sub.renewsAt {
                                LabeledRow(label: "Renews", value: renews.formatted(date: .abbreviated, time: .omitted))
                            }
                            if let processor = sub.processor {
                                LabeledRow(label: "Billed via", value: processor.capitalized)
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

struct PaymentMethodsView: View {
    @EnvironmentObject private var appState: AppState
    var body: some View {
        AsyncScreen(title: "Payment Information",
                    isEmpty: { $0.isEmpty },
                    emptyTitle: "No payment methods",
                    load: {
            try await appState.data.paymentMethods()
        }) { methods in
            List(methods) { m in
                HStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "creditcard.fill").foregroundStyle(Theme.Color.primary)
                    Text("\(m.brand?.capitalized ?? "Card") •••• \(m.last4 ?? "----")").font(Theme.Font.body)
                    Spacer()
                    if m.isDefault == true {
                        Text("Default").font(Theme.Font.caption).foregroundStyle(Theme.Color.textSecondary)
                    }
                    if let mo = m.expMonth, let yr = m.expYear {
                        Text(String(format: "%02d/%02d", mo, yr % 100)).font(Theme.Font.caption).foregroundStyle(Theme.Color.textSecondary)
                    }
                }
                .listRowInsets(EdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16))
            }
            .listStyle(.plain)
        }
    }
}

struct PaymentHistoryView: View {
    @EnvironmentObject private var appState: AppState
    var body: some View {
        AsyncScreen(title: "Payment History",
                    isEmpty: { $0.items.isEmpty },
                    emptyTitle: "No payments yet",
                    load: {
            try await appState.data.paymentHistory(page: 1)
        }) { page in
            List(page.items) { p in
                HStack {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        Text(p.description ?? "Payment").font(Theme.Font.body)
                        Text(p.date, style: .date).font(Theme.Font.caption).foregroundStyle(Theme.Color.textSecondary)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                        Text(money(p.amount, p.currency)).font(Theme.Font.subhead)
                        if let status = p.status { StatusBadge(status: status) }
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .listStyle(.plain)
        }
    }
}

struct StatusBadge: View {
    let status: String
    var body: some View {
        Text(status.capitalized)
            .font(Theme.Font.caption)
            .foregroundStyle(color)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, Theme.Spacing.xxs)
            .background(color.opacity(0.14))
            .clipShape(Capsule())
    }
    private var color: Color {
        switch status.lowercased() {
        case "active", "paid", "completed", "succeeded": return Theme.Color.success
        case "past_due", "pending", "processing": return Theme.Color.warning
        case "canceled", "cancelled", "failed": return Theme.Color.danger
        default: return Theme.Color.textSecondary
        }
    }
}
