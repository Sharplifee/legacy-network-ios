import Foundation

/// Subscription + payment models.
///
/// The payment processor behind Manage Subscription / Payment Information /
/// Payment History is identified by `Subscription.processor` and the shape of
/// `PaymentMethod` (e.g. Stripe card brand/last4/expiry). Confirm the processor
/// from captured responses before wiring any client SDK.
struct Subscription: Codable, Equatable {
    var planName: String
    var status: String            // "active" | "past_due" | "canceled" | ...
    var renewsAt: Date?
    var priceLabel: String?
    var processor: String?        // e.g. "stripe"
}

struct PaymentMethod: Codable, Equatable, Identifiable {
    let id: String
    var brand: String?            // "visa" | "mastercard" | ...
    var last4: String?
    var expMonth: Int?
    var expYear: Int?
    var isDefault: Bool?
}

struct PaymentHistoryItem: Codable, Equatable, Identifiable {
    let id: String
    let amount: Double
    var currency: String?
    let date: Date
    var status: String?
    var description: String?
    var receiptURL: URL?
}
