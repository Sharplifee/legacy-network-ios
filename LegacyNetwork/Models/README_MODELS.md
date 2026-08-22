# Models — reconciliation note

These `Codable` structs describe the shapes the app expects from
`https://api.legacynetwork.com`. They were seeded from the documented domain
model (Sanctum auth, dashboard, network genealogy, leaderboard, commissions,
earnings, LGCT token, quizzes, gamification, notifications, subscription /
payments) — **not** from captured live responses.

Before shipping, reconcile every field name and type against real captured
JSON (Step 2/3 of the build plan, run from an authorized environment). The
decoder uses `.convertFromSnakeCase`, so `snake_case` server keys map to
`camelCase` here automatically; add explicit `CodingKeys` only where that rule
doesn't hold.
