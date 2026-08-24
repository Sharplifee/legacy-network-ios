import Foundation

/// A purchasable plan shown on the checkout / upgrade flow.
///
/// This is a **front-end replica**: the checkout page renders every field and
/// button but performs no real payment. Plans mirror the shape a plans endpoint
/// would return so the same UI can later run against `LiveDataService`.
struct CheckoutPlan: Codable, Equatable, Identifiable {
    let id: String
    var name: String
    /// Numeric monthly price, used for the order-summary math.
    var priceMonthly: Double
    /// Pre-formatted price label as the web app prints it (e.g. "$49.00").
    var priceLabel: String
    /// Billing cadence copy, e.g. "per month", "billed annually".
    var period: String
    var tagline: String?
    var features: [String]
    var isPopular: Bool
    /// Small ribbon copy, e.g. "Most popular", "Best value". Optional.
    var badge: String?
}
