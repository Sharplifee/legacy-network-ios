/* Mock data for the Legacy Network member-area replica.
 * Shape mirrors what the live app renders, so real data captured from a HAR
 * (api.legacynetwork.com responses) can replace window.LN field-for-field.
 * NO real member PII — all names/figures are fabricated demo values. */
window.LN = {
  user: {
    name: "Dianne Lawson",
    initials: "DL",
    rank: "Director",
    nextRank: "Senior Director",
    memberId: "LN-480219",
    joined: "2024-08-12",
    email: "dianne@legacynetwork.com",
    personalUrl: "https://legacynetwork.com/u/dianne",
    avatar: null
  },
  dashboard: {
    earningsMonth: 4820.50,
    earningsDelta: 12.4,
    availableBalance: 1265.00,
    lifetime: 38940.00,
    rankProgress: 0.68,
    kpis: [
      { k: "Personal Volume", v: "1,240 PV", d: "+8%", up: true, color: "var(--primary)" },
      { k: "Team Volume", v: "18,760 GV", d: "+15%", up: true, color: "var(--green)" },
      { k: "Active Team", v: "34", d: "+3", up: true, color: "var(--orange)" },
      { k: "Autoship", v: "Active", d: "Next: Dec 1", up: true, color: "var(--peach)" }
    ],
    earningsByMonth: [
      { m: "Jun", v: 2900 }, { m: "Jul", v: 3350 }, { m: "Aug", v: 3100 },
      { m: "Sep", v: 3980 }, { m: "Oct", v: 4290 }, { m: "Nov", v: 4820 }
    ],
    recentCommissions: [
      { who: "Retail bonus", when: "Nov 16", amt: 142.00, type: "retail" },
      { who: "Team override — Tier 2", when: "Nov 14", amt: 318.50, type: "override" },
      { who: "Fast-start — M. Reyes", when: "Nov 12", amt: 75.00, type: "faststart" },
      { who: "Rank bonus — Director", when: "Nov 01", amt: 500.00, type: "rank" }
    ]
  },
  commissions: {
    paidYTD: 32110.00,
    pending: 612.50,
    nextPayout: "2026-11-30",
    breakdown: [
      { label: "Retail profit", value: 8120, color: "var(--primary)" },
      { label: "Team overrides", value: 15640, color: "var(--green)" },
      { label: "Fast-start bonuses", value: 4350, color: "var(--orange)" },
      { label: "Rank bonuses", value: 4000, color: "var(--peach)" }
    ],
    history: [
      { when: "Nov 16, 2026", type: "Retail bonus", status: "Paid", amt: 142.00 },
      { when: "Nov 14, 2026", type: "Team override", status: "Paid", amt: 318.50 },
      { when: "Nov 12, 2026", type: "Fast-start", status: "Paid", amt: 75.00 },
      { when: "Nov 01, 2026", type: "Rank bonus", status: "Paid", amt: 500.00 },
      { when: "Oct 30, 2026", type: "Monthly override", status: "Paid", amt: 1240.00 },
      { when: "Oct 16, 2026", type: "Retail bonus", status: "Paid", amt: 96.00 }
    ]
  },
  team: {
    frontline: 6, total: 34, active: 28,
    members: [
      { name: "Marcus Reyes", rank: "Manager", lvl: 1, pv: 420, team: 9, on: true },
      { name: "Priya Nair", rank: "Senior Associate", lvl: 1, pv: 310, team: 4, on: true },
      { name: "Tom Becker", rank: "Associate", lvl: 2, pv: 180, team: 1, on: false },
      { name: "Ava Mitchell", rank: "Manager", lvl: 1, pv: 560, team: 12, on: true },
      { name: "Lena Osei", rank: "Associate", lvl: 2, pv: 140, team: 0, on: true },
      { name: "Diego Santos", rank: "Associate", lvl: 3, pv: 95, team: 0, on: false }
    ]
  },
  shop: {
    products: [
      { id: "p1", name: "Daily Essentials Pack", price: 89.00, cv: 60, emoji: "🧴", auto: true },
      { id: "p2", name: "Vitality Blend — 30ct", price: 54.00, cv: 40, emoji: "🫗", auto: true },
      { id: "p3", name: "Restore Night Formula", price: 68.00, cv: 50, emoji: "🌙", auto: false },
      { id: "p4", name: "Hydrate+ Electrolytes", price: 39.00, cv: 28, emoji: "💧", auto: true },
      { id: "p5", name: "Starter Business Kit", price: 199.00, cv: 150, emoji: "📦", auto: false },
      { id: "p6", name: "Focus Botanicals", price: 47.00, cv: 34, emoji: "🌿", auto: false }
    ]
  },
  orders: [
    { id: "ORD-20412", date: "Nov 10, 2026", items: 3, total: 182.00, status: "Delivered" },
    { id: "ORD-20288", date: "Oct 12, 2026", items: 2, total: 143.00, status: "Delivered" },
    { id: "ORD-20102", date: "Sep 14, 2026", items: 4, total: 221.00, status: "Delivered" },
    { id: "ORD-19980", date: "Aug 15, 2026", items: 1, total: 89.00, status: "Delivered" }
  ],
  achievements: [
    { em: "🚀", name: "Fast Start", desc: "First 30 days", got: true },
    { em: "🤝", name: "First Enrollment", desc: "Sponsored a member", got: true },
    { em: "📈", name: "1k PV Month", desc: "1,000 personal volume", got: true },
    { em: "👥", name: "Team of 10", desc: "10 active members", got: true },
    { em: "🏅", name: "Director", desc: "Reached Director", got: true },
    { em: "💎", name: "Senior Director", desc: "Next rank up", got: false },
    { em: "🌟", name: "10k Month", desc: "$10k in a month", got: false },
    { em: "👑", name: "Executive", desc: "Top rank", got: false }
  ]
};
