import Foundation

/// Reconciled against the live /api/v2/login and /api/v2/user/current_user
/// responses (captured 2026-08). Field names and optionality mirror the
/// actual production JSON, not inferred shapes.
struct User: Codable, Identifiable, Equatable {
    let id: Int
    let email: String
    let fullname: String?
    let firstName: String?
    let middleName: String?
    let lastName: String?

    // Role / status flags — these are the real source of truth for role gating.
    let isAdmin: Bool?          // present on current_user; drives Admin mode
    let isDistributor: Bool?
    let isActivated: Bool?
    let isSubscribed: Bool?
    let isTrainingDone: Bool?
    let isPaid: Bool?
    let isOrphan: Bool?
    let partnerAdmin: Bool?

    // Tier
    let tierId: Int?
    let tier: Tier?

    // Trial
    let isTrial: Bool?
    let trialEndsAt: String?
    let trialDaysRemaining: Int?
    let isTrialActive: Bool?
    let isTrialExpired: Bool?

    // Profile
    let dateOfBirth: String?
    let gender: String?
    let mobile: String?
    let intlMobile: String?
    let avatar: String?         // relative path, e.g. "userassets/xx.png"
    let synergyId: String?
    let synergyStatus: String?
    let siteOrigin: String?
    let userLang: String?
    let status: String?
    let hash: String?
    let allowNotification: Bool?

    // Goals
    let incomeGoalAmount: String?
    let incomeGoalTargetDate: String?

    // Address (mailing)
    let mailingAddress1: String?
    let mailingAddress2: String?
    let mailingCity: String?
    let mailingState: String?
    let mailingPostalCode: String?
    let mailingCountry: String?

    /// Absolute avatar URL built from the relative `avatar` path.
    var avatarURL: URL? {
        guard let a = avatar, !a.isEmpty else { return nil }
        if a.hasPrefix("http") { return URL(string: a) }
        return URL(string: "https://app.legacynetwork.com/\(a)")
    }

    /// True when the account is allowed to enter Admin mode.
    var canUseAdmin: Bool { isAdmin ?? false }

    var displayName: String {
        fullname ?? [firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case id, email, fullname, tier, gender, mobile, avatar, status, hash
        case firstName = "first_name"
        case middleName = "middle_name"
        case lastName = "last_name"
        case isAdmin = "is_admin"
        case isDistributor = "is_distributor"
        case isActivated = "is_activated"
        case isSubscribed = "is_subscribed"
        case isTrainingDone = "is_training_done"
        case isPaid = "is_paid"
        case isOrphan = "is_orphan"
        case partnerAdmin = "partner_admin"
        case tierId = "tier_id"
        case isTrial = "is_trial"
        case trialEndsAt = "trial_ends_at"
        case trialDaysRemaining = "trial_days_remaining"
        case isTrialActive = "is_trial_active"
        case isTrialExpired = "is_trial_expired"
        case dateOfBirth = "date_of_birth"
        case intlMobile = "intl_mobile"
        case synergyId = "synergy_id"
        case synergyStatus = "synergy_status"
        case siteOrigin = "site_origin"
        case userLang = "user_lang"
        case allowNotification = "allow_notification"
        case incomeGoalAmount = "income_goal_amount"
        case incomeGoalTargetDate = "income_goal_target_date"
        case mailingAddress1 = "mailing_address_1"
        case mailingAddress2 = "mailing_address_2"
        case mailingCity = "mailing_city"
        case mailingState = "mailing_state"
        case mailingPostalCode = "mailing_postal_code"
        case mailingCountry = "mailing_country"
    }
}

struct Tier: Codable, Equatable {
    let id: Int
    let name: String
    let slug: String?
    let price: String?
    let formattedPrice: String?
    let isPaid: Bool?
    let isFree: Bool?
    let isActive: Bool?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id, name, slug, price, status
        case formattedPrice = "formatted_price"
        case isPaid = "is_paid"
        case isFree = "is_free"
        case isActive = "is_active"
    }
}

/// Real login envelope: user object under `data`, plus token set at the top level.
struct LoginResponse: Codable {
    let data: User
    let token: String
    let accessToken: String
    let refreshToken: String?
    let tokenType: String?
    let expiresIn: Int?
    let pelagoJwe: String?

    var user: User { data }

    enum CodingKeys: String, CodingKey {
        case data, token
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case pelagoJwe = "pelago_jwe"
    }
}

/// current_user returns the user object under `data`.
struct CurrentUserResponse: Codable {
    let data: User
}
