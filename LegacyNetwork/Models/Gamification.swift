import Foundation

struct XPSummary: Codable, Equatable {
    let level: Int
    let xp: Int
    let xpToNextLevel: Int
    var streakDays: Int?
    var title: String?
}

struct Achievement: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    var description: String?
    var iconURL: URL?
    var unlocked: Bool
    var unlockedAt: Date?
    var progress: Double?    // 0…1
}

struct Quiz: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    var description: String?
    var questionCount: Int?
    var xpReward: Int?
    var completed: Bool?
    var bestScore: Int?
}

struct QuizQuestion: Codable, Equatable, Identifiable {
    let id: String
    let prompt: String
    let options: [QuizOption]
    var type: String?    // "single" | "multiple"
}

struct QuizOption: Codable, Equatable, Identifiable {
    let id: String
    let text: String
}

struct QuizSession: Codable, Equatable, Identifiable {
    let id: String
    let title: String
    let questions: [QuizQuestion]
    var timeLimitSeconds: Int?
}

struct QuizResult: Codable, Equatable {
    let quizId: String
    let score: Int
    let total: Int
    var passed: Bool?
    var xpEarned: Int?
    var correctIds: [String]?
}
