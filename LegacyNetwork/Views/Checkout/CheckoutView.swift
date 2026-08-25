import SwiftUI

/// Full checkout / upgrade flow — a **front-end replica**.
///
/// Every field and button of a real checkout is present (plan selection, card
/// details, billing address, order review, Pay, confirmation) but nothing is
/// submitted to a payment processor: the "Pay" action simulates processing and
/// lands on a confirmation screen. This mirrors the visual + interaction design
/// of the web app's checkout without any backend integration.
struct CheckoutView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        AsyncScreen(title: "Checkout",
                    isEmpty: { $0.isEmpty },
                    emptyTitle: "No plans available",
                    load: { try await appState.data.checkoutPlans() }) { plans in
            CheckoutFlow(plans: plans)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Steps

private enum CheckoutStep: Int, CaseIterable {
    case plan, payment, review, done

    var title: String {
        switch self {
        case .plan:    return "Choose a plan"
        case .payment: return "Payment details"
        case .review:  return "Review order"
        case .done:    return "Confirmed"
        }
    }
}

// MARK: - Flow container

private struct CheckoutFlow: View {
    let plans: [CheckoutPlan]

    @State private var step: CheckoutStep = .plan
    @State private var selectedPlanID: String
    @State private var form = CheckoutForm()
    @State private var isProcessing = false

    init(plans: [CheckoutPlan]) {
        self.plans = plans
        // Preselect the popular plan if present, else the first.
        _selectedPlanID = State(initialValue:
            (plans.first(where: { $0.isPopular }) ?? plans.first)?.id ?? "")
    }

    private var selectedPlan: CheckoutPlan? {
        plans.first(where: { $0.id == selectedPlanID })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                if step != .done {
                    CheckoutProgressBar(current: step)
                }

                switch step {
                case .plan:
                    PlanStep(plans: plans, selectedPlanID: $selectedPlanID)
                case .payment:
                    PaymentStep(form: $form, plan: selectedPlan)
                case .review:
                    if let plan = selectedPlan {
                        ReviewStep(plan: plan, form: form)
                    }
                case .done:
                    if let plan = selectedPlan {
                        ConfirmationStep(plan: plan, form: form)
                    }
                }

                footer
            }
            .padding(Theme.Spacing.lg)
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.Color.surfaceGrouped.ignoresSafeArea())
        .animation(Theme.Motion.standard, value: step)
    }

    // MARK: Footer / primary actions

    @ViewBuilder private var footer: some View {
        switch step {
        case .plan:
            PrimaryButton(title: "Continue", isEnabled: selectedPlan != nil) {
                step = .payment
            }
        case .payment:
            VStack(spacing: Theme.Spacing.sm) {
                PrimaryButton(title: "Review order", isEnabled: form.isPaymentValid) {
                    step = .review
                }
                backButton(to: .plan)
            }
        case .review:
            VStack(spacing: Theme.Spacing.sm) {
                PrimaryButton(
                    title: payTitle,
                    isLoading: isProcessing,
                    isEnabled: selectedPlan != nil
                ) { pay() }

                Text("This is a demo checkout — no payment is processed and no card is charged.")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Color.textSecondary)
                    .multilineTextAlignment(.center)

                backButton(to: .payment)
            }
        case .done:
            EmptyView()
        }
    }

    private var payTitle: String {
        guard let plan = selectedPlan else { return "Pay" }
        return "Pay \(plan.priceLabel)"
    }

    private func backButton(to target: CheckoutStep) -> some View {
        Button("Back") { step = target }
            .font(Theme.Font.subhead)
            .foregroundStyle(Theme.Color.primary)
            .disabled(isProcessing)
    }

    /// Simulated, non-processing "payment". No network, no charge.
    private func pay() {
        isProcessing = true
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            isProcessing = false
            step = .done
        }
    }
}

// MARK: - Progress bar

private struct CheckoutProgressBar: View {
    let current: CheckoutStep
    private let steps: [CheckoutStep] = [.plan, .payment, .review]

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, s in
                let isDone = s.rawValue < current.rawValue
                let isActive = s == current
                HStack(spacing: Theme.Spacing.xs) {
                    ZStack {
                        Circle()
                            .fill(isDone || isActive ? Theme.Color.primary : Theme.Color.neutralFill)
                            .frame(width: 26, height: 26)
                        if isDone {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Theme.Color.textOnPrimary)
                        } else {
                            Text("\(index + 1)")
                                .font(Theme.Font.caption)
                                .foregroundStyle(isActive ? Theme.Color.textOnPrimary : Theme.Color.textSecondary)
                        }
                    }
                    if index < steps.count - 1 {
                        Rectangle()
                            .fill(isDone ? Theme.Color.primary : Theme.Color.neutralFill)
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}

// MARK: - Step 1: Plan selection

private struct PlanStep: View {
    let plans: [CheckoutPlan]
    @Binding var selectedPlanID: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            StepHeader(title: "Choose a plan",
                       subtitle: "Pick the plan that fits your goals. Change or cancel anytime.")

            ForEach(plans) { plan in
                PlanCard(plan: plan, isSelected: plan.id == selectedPlanID) {
                    withAnimation(Theme.Motion.quick) { selectedPlanID = plan.id }
                }
            }
        }
    }
}

private struct PlanCard: View {
    let plan: CheckoutPlan
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                        HStack(spacing: Theme.Spacing.sm) {
                            Text(plan.name)
                                .font(Theme.Font.headline)
                                .foregroundStyle(Theme.Color.textPrimary)
                            if let badge = plan.badge {
                                Text(badge)
                                    .font(Theme.Font.caption)
                                    .foregroundStyle(Theme.Color.textOnPrimary)
                                    .padding(.horizontal, Theme.Spacing.sm)
                                    .padding(.vertical, 2)
                                    .background(Theme.Color.accent)
                                    .clipShape(Capsule())
                            }
                        }
                        if let tagline = plan.tagline {
                            Text(tagline)
                                .font(Theme.Font.footnote)
                                .foregroundStyle(Theme.Color.textSecondary)
                        }
                    }
                    Spacer()
                    RadioMark(isSelected: isSelected)
                }

                HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.xs) {
                    Text(plan.priceLabel)
                        .font(Theme.Font.title)
                        .foregroundStyle(Theme.Color.textPrimary)
                    Text(plan.period)
                        .font(Theme.Font.footnote)
                        .foregroundStyle(Theme.Color.textSecondary)
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    ForEach(plan.features, id: \.self) { feature in
                        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundStyle(Theme.Color.success)
                            Text(feature)
                                .font(Theme.Font.footnote)
                                .foregroundStyle(Theme.Color.textPrimary)
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
            .padding(Theme.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.md, style: .continuous)
                    .stroke(isSelected ? Theme.Color.primary : Theme.Color.separator,
                            lineWidth: isSelected ? 2 : 1)
            )
            .themeShadow(Theme.Shadow.card)
        }
        .buttonStyle(.plain)
    }
}

private struct RadioMark: View {
    let isSelected: Bool
    var body: some View {
        ZStack {
            Circle()
                .stroke(isSelected ? Theme.Color.primary : Theme.Color.separator, lineWidth: 2)
                .frame(width: 22, height: 22)
            if isSelected {
                Circle()
                    .fill(Theme.Color.primary)
                    .frame(width: 12, height: 12)
            }
        }
    }
}

// MARK: - Step 2: Payment details

private struct PaymentStep: View {
    @Binding var form: CheckoutForm
    let plan: CheckoutPlan?

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            StepHeader(title: "Payment details",
                       subtitle: "Enter your card and billing information.")

            // Card
            Card {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    SectionLabel("Card")

                    CheckoutField(
                        label: "Cardholder name",
                        text: $form.cardName,
                        placeholder: "Name on card",
                        textContentType: .name
                    )

                    CheckoutField(
                        label: "Card number",
                        text: Binding(
                            get: { form.cardNumber },
                            set: { form.cardNumber = CheckoutFormat.cardNumber($0) }
                        ),
                        placeholder: "1234 5678 9012 3456",
                        keyboard: .numberPad,
                        textContentType: .creditCardNumber,
                        trailing: {
                            AnyView(
                                Image(systemName: "creditcard")
                                    .foregroundStyle(Theme.Color.neutralText)
                            )
                        }
                    )

                    HStack(spacing: Theme.Spacing.md) {
                        CheckoutField(
                            label: "Expiry",
                            text: Binding(
                                get: { form.expiry },
                                set: { form.expiry = CheckoutFormat.expiry($0) }
                            ),
                            placeholder: "MM/YY",
                            keyboard: .numberPad
                        )
                        CheckoutField(
                            label: "CVC",
                            text: Binding(
                                get: { form.cvc },
                                set: { form.cvc = CheckoutFormat.digits($0, max: 4) }
                            ),
                            placeholder: "123",
                            keyboard: .numberPad
                        )
                    }
                }
            }

            // Billing
            Card {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    SectionLabel("Billing address")

                    CheckoutField(
                        label: "Email",
                        text: $form.email,
                        placeholder: "you@example.com",
                        keyboard: .emailAddress,
                        textContentType: .emailAddress,
                        autocapitalize: false
                    )
                    CheckoutField(
                        label: "Address",
                        text: $form.address1,
                        placeholder: "Street address",
                        textContentType: .fullStreetAddress
                    )
                    CheckoutField(
                        label: "Apartment, suite (optional)",
                        text: $form.address2,
                        placeholder: "Apt, suite, unit"
                    )
                    HStack(spacing: Theme.Spacing.md) {
                        CheckoutField(
                            label: "City",
                            text: $form.city,
                            placeholder: "City",
                            textContentType: .addressCity
                        )
                        CheckoutField(
                            label: "State / Province",
                            text: $form.state,
                            placeholder: "State",
                            textContentType: .addressState
                        )
                    }
                    HStack(spacing: Theme.Spacing.md) {
                        CheckoutField(
                            label: "ZIP / Postal code",
                            text: $form.postalCode,
                            placeholder: "ZIP",
                            keyboard: .numbersAndPunctuation,
                            textContentType: .postalCode
                        )
                        CountryField(selection: $form.country)
                    }
                }
            }

            Toggle(isOn: $form.savePaymentMethod) {
                Text("Save this card for future payments")
                    .font(Theme.Font.footnote)
                    .foregroundStyle(Theme.Color.textPrimary)
            }
            .tint(Theme.Color.primary)
            .padding(.horizontal, Theme.Spacing.xs)

            HStack(spacing: Theme.Spacing.xs) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(Theme.Color.textSecondary)
                Text("Your details are entered securely. Demo only — nothing is stored.")
                    .font(Theme.Font.caption)
                    .foregroundStyle(Theme.Color.textSecondary)
            }
            .padding(.horizontal, Theme.Spacing.xs)
        }
    }
}

private struct CountryField: View {
    @Binding var selection: String
    private let countries = ["United States", "Canada", "United Kingdom", "Australia",
                             "Germany", "France", "Mexico", "Other"]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Country")
                .font(Theme.Font.footnote)
                .foregroundStyle(Theme.Color.textSecondary)
            Menu {
                ForEach(countries, id: \.self) { c in
                    Button(c) { selection = c }
                }
            } label: {
                HStack {
                    Text(selection.isEmpty ? "Select" : selection)
                        .font(Theme.Font.body)
                        .foregroundStyle(selection.isEmpty ? Theme.Color.neutralText : Theme.Color.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.Color.neutralText)
                }
                .padding(.horizontal, Theme.Spacing.md)
                .frame(height: 46)
                .background(Theme.Color.neutralFill)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
            }
        }
    }
}

// MARK: - Step 3: Review

private struct ReviewStep: View {
    let plan: CheckoutPlan
    let form: CheckoutForm

    private var tax: Double { (plan.priceMonthly * 0.0 * 100).rounded() / 100 } // demo: no tax
    private var total: Double { plan.priceMonthly + tax }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            StepHeader(title: "Review order",
                       subtitle: "Confirm the details below before paying.")

            Card {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    SectionLabel("Plan")
                    HStack {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                            Text(plan.name).font(Theme.Font.subhead)
                            Text(plan.period).font(Theme.Font.caption)
                                .foregroundStyle(Theme.Color.textSecondary)
                        }
                        Spacer()
                        Text(plan.priceLabel).font(Theme.Font.subhead)
                    }
                    Divider()
                    LabeledRow(label: "Subtotal", value: money(plan.priceMonthly))
                    LabeledRow(label: "Tax", value: money(tax))
                    Divider()
                    HStack {
                        Text("Total due today").font(Theme.Font.headline)
                        Spacer()
                        Text(money(total)).font(Theme.Font.headline)
                            .foregroundStyle(Theme.Color.primary)
                    }
                }
            }

            Card {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    SectionLabel("Payment method")
                    HStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "creditcard.fill")
                            .foregroundStyle(Theme.Color.primary)
                        Text("\(CheckoutFormat.brand(form.cardNumber)) •••• \(CheckoutFormat.last4(form.cardNumber))")
                            .font(Theme.Font.body)
                        Spacer()
                        Text(form.expiry).font(Theme.Font.footnote)
                            .foregroundStyle(Theme.Color.textSecondary)
                    }
                    if !form.cardName.isEmpty {
                        LabeledRow(label: "Name", value: form.cardName)
                    }
                }
            }

            Card {
                VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                    SectionLabel("Billing")
                    if !form.email.isEmpty { LabeledRow(label: "Email", value: form.email) }
                    LabeledRow(label: "Address", value: form.addressSummary)
                }
            }
        }
    }
}

// MARK: - Step 4: Confirmation

private struct ConfirmationStep: View {
    @Environment(\.dismiss) private var dismiss
    let plan: CheckoutPlan
    let form: CheckoutForm

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            ZStack {
                Circle().fill(Theme.Color.success.opacity(0.15)).frame(width: 88, height: 88)
                Image(systemName: "checkmark")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(Theme.Color.success)
            }
            .padding(.top, Theme.Spacing.xl)

            Text("You're all set!")
                .font(Theme.Font.title)
                .foregroundStyle(Theme.Color.textPrimary)

            Text("Your \(plan.name) subscription is active.")
                .font(Theme.Font.body)
                .foregroundStyle(Theme.Color.textSecondary)
                .multilineTextAlignment(.center)

            Card {
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    LabeledRow(label: "Plan", value: plan.name)
                    Divider()
                    LabeledRow(label: "Amount", value: "\(plan.priceLabel) \(plan.period)")
                    Divider()
                    LabeledRow(label: "Card", value: "•••• \(CheckoutFormat.last4(form.cardNumber))")
                    if !form.email.isEmpty {
                        Divider()
                        LabeledRow(label: "Receipt sent to", value: form.email)
                    }
                }
            }

            PrimaryButton(title: "Done") { dismiss() }
                .padding(.top, Theme.Spacing.sm)

            Text("Demo confirmation — no charge was made.")
                .font(Theme.Font.caption)
                .foregroundStyle(Theme.Color.textSecondary)
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - Shared field/section components

private struct StepHeader: View {
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            Text(title).font(Theme.Font.title).foregroundStyle(Theme.Color.textPrimary)
            Text(subtitle).font(Theme.Font.footnote).foregroundStyle(Theme.Color.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SectionLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text.uppercased())
            .font(Theme.Font.caption)
            .foregroundStyle(Theme.Color.textSecondary)
    }
}

/// A labeled text field styled like the app's inputs.
private struct CheckoutField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var keyboard: UIKeyboardType = .default
    var textContentType: UITextContentType? = nil
    var autocapitalize: Bool = true
    var trailing: (() -> AnyView)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(label)
                .font(Theme.Font.footnote)
                .foregroundStyle(Theme.Color.textSecondary)
            HStack {
                TextField(placeholder, text: $text)
                    .font(Theme.Font.body)
                    .keyboardType(keyboard)
                    .textContentType(textContentType)
                    .textInputAutocapitalization(autocapitalize ? .words : .never)
                    .autocorrectionDisabled()
                if let trailing {
                    trailing()
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .frame(height: 46)
            .background(Theme.Color.neutralFill)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm, style: .continuous))
        }
    }
}

// MARK: - Form state + formatting

private struct CheckoutForm {
    var cardName = ""
    var cardNumber = ""
    var expiry = ""
    var cvc = ""

    var email = ""
    var address1 = ""
    var address2 = ""
    var city = ""
    var state = ""
    var postalCode = ""
    var country = "United States"

    var savePaymentMethod = true

    /// Enough to enable the review/pay button in this demo. Not real validation.
    var isPaymentValid: Bool {
        CheckoutFormat.digits(cardNumber, max: 19).count >= 15 &&
        expiry.count == 5 &&
        cvc.count >= 3 &&
        !cardName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !address1.trimmingCharacters(in: .whitespaces).isEmpty &&
        !city.trimmingCharacters(in: .whitespaces).isEmpty &&
        !postalCode.trimmingCharacters(in: .whitespaces).isEmpty &&
        !country.isEmpty
    }

    var addressSummary: String {
        var parts = [address1]
        if !address2.isEmpty { parts.append(address2) }
        let locality = [city, state].filter { !$0.isEmpty }.joined(separator: ", ")
        if !locality.isEmpty { parts.append(locality) }
        if !postalCode.isEmpty { parts.append(postalCode) }
        if !country.isEmpty { parts.append(country) }
        return parts.joined(separator: "\n")
    }
}

/// Pure formatting helpers for the card inputs.
private enum CheckoutFormat {
    static func digits(_ s: String, max: Int) -> String {
        String(s.filter(\.isNumber).prefix(max))
    }

    static func cardNumber(_ s: String) -> String {
        let d = digits(s, max: 19)
        return stride(from: 0, to: d.count, by: 4).map { i -> String in
            let start = d.index(d.startIndex, offsetBy: i)
            let end = d.index(start, offsetBy: min(4, d.count - i))
            return String(d[start..<end])
        }.joined(separator: " ")
    }

    static func expiry(_ s: String) -> String {
        let d = digits(s, max: 4)
        guard d.count > 2 else { return d }
        let idx = d.index(d.startIndex, offsetBy: 2)
        return "\(d[..<idx])/\(d[idx...])"
    }

    static func last4(_ number: String) -> String {
        let d = digits(number, max: 19)
        return d.count >= 4 ? String(d.suffix(4)) : "----"
    }

    /// Very small brand guess from the leading digit — display only.
    static func brand(_ number: String) -> String {
        guard let first = digits(number, max: 19).first else { return "Card" }
        switch first {
        case "4": return "Visa"
        case "5": return "Mastercard"
        case "3": return "Amex"
        case "6": return "Discover"
        default:  return "Card"
        }
    }
}

#Preview {
    NavigationStack { CheckoutView() }
        .environmentObject(AppState())
}
