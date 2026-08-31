# Legacy Network iOS — Handoff

Complete project state. A fresh clone plus this file is everything a new session
on any Mac needs — no prior context, no credentials, no backend access.

**Last updated:** 2026-08-31

---

## 1. What this is

A **static visual replica** of the Legacy Network web app (`app.legacynetwork.com`)
as a native SwiftUI iOS app. Every screen renders fully populated, offline.

**The shipped app makes zero network calls.** There is no live backend, no login
that contacts a server, and no credentials anywhere in the repo. All screen
content comes from `MockDataService`. This is a deliberate architectural
constraint, not a stopgap — see §6 before "wiring up the API".

### Data provenance — read this before comparing to production

The baked-in values are **representative, not scraped from the live account**.
They match the *shape, units, and formatting* of real API responses so layout and
spacing are faithful, but the numbers are illustrative.

This was deliberate: **this GitHub repo is public** (verify:
`curl -s https://api.github.com/repos/Sharplifee/legacy-network-ios | grep '"private"'`).
Baking a real distributor's payment history, payment methods, commission balances,
and downline tree into it would publish other members' names and earnings — people
who never consented — to a world-readable URL. The account holder can consent to
her own records; she cannot consent on her downline's behalf. `.gitignore` already
encodes the same rule (`extraction/`, `*.har`, "contain live production user data,
never commit").

If you want real values in a local build, edit `MockDataService.swift` directly
and **do not commit the change**. Do not add a JSON-overlay loader that reads a
gitignored data file — that reintroduces the same exposure with extra steps and
makes it easy to commit by accident.

---

## 2. Repo, identifiers, and build target

| Thing | Value |
|---|---|
| Repo | `https://github.com/Sharplifee/legacy-network-ios` (**public**) |
| Default branch | `main` |
| Local clone | `/Users/connorsharp/LegacyNetwork` |
| ⚠️ Superseded copy | `/Users/connorsharp/LegacyNetwork.stale-scaffold-backup` — **do not use** |
| Bundle ID | `com.legacynetwork.app` |
| Development team | `XF783932R2` (free personal team, Connor Sharp) |
| Signing | Automatic, `-allowProvisioningUpdates` |
| Product name | `Legacy Network` (with a space — the `.app` is `Legacy Network.app`) |
| Scheme | `LegacyNetwork` (no space) |
| Deployment target | iOS 17.0 |
| Device family | iPhone + iPad (`TARGETED_DEVICE_FAMILY = "1,2"`) |

**Free-team constraints.** The push-notification entitlement was removed so a free
personal team can auto-sign (`LegacyNetwork.entitlements` is intentionally empty).
Do not re-add entitlements requiring a paid account. Free-team provisioning
profiles expire after 7 days — if the app stops launching, just re-run
`./build-and-install.sh`.

**About the superseded copy.** Before 2026-08-31, `~/LegacyNetwork` held an
untracked, divergent early scaffold (~2,000 LOC, a `Sources/` layout, no
`MockDataService`, bundle ID `com.connor.legacynetwork`). It was never a clone of
this repo and shares no history with it. It was moved aside to
`~/LegacyNetwork.stale-scaffold-backup` and `~/LegacyNetwork` replaced with a real
clone. Nothing in it is needed; it is kept only so nothing was destroyed. Delete
it once you are confident, and never `git init`/force-push from it.

### Target device

The paired iPhone 16 Pro on Connor's Mac:

| ID kind | Value |
|---|---|
| `devicectl` identifier (use for install) | `8B9459D4-67C1-53A8-906D-C79A34679CB9` |
| Hardware UDID (`xcrun xctrace list devices`) | `00008140-000E18EC1489801C` |

⚠️ An older device ID (`E345E8D2-A17B-425B-A046-1D223A2B412D`) appears in earlier
notes and in the pre-2026-08-31 build script. **It matches nothing on this
machine** — not a device, not a simulator. It is stale; ignore it.
`build-and-install.sh` now discovers devices live rather than hardcoding an ID,
which is the durable fix.

---

## 3. Build and install

```bash
git clone https://github.com/Sharplifee/legacy-network-ios.git
cd legacy-network-ios
./build-and-install.sh              # generate + sign + install to all connected devices
./build-and-install.sh --launch     # ...and launch it
./build-and-install.sh --build-only # sign only, no device required
./build-and-install.sh <device-id>  # target one specific device
```

Requires macOS, Xcode, and XcodeGen (`brew install xcodegen`). The script
preflights both and tells you what is missing.

**The `.xcodeproj` is gitignored and regenerated on every run** — `project.yml` is
the single source of truth. Never hand-edit the Xcode project; edit `project.yml`
and re-run `xcodegen generate`.

Manual equivalent — note `-derivedDataPath`. Without it, `xcodebuild` writes to
shared `~/Library/Developer/Xcode/DerivedData` and you have to guess which
`Legacy Network.app` is yours; with two clones of this repo on one machine that
silently installs the wrong build. Keep the build output inside the checkout:

```bash
xcodegen generate
xcodebuild -project LegacyNetwork.xcodeproj -scheme LegacyNetwork \
  -configuration Debug -destination 'generic/platform=iOS' \
  -derivedDataPath "$(pwd)/build/DerivedData" \
  -allowProvisioningUpdates DEVELOPMENT_TEAM=XF783932R2 build

xcrun devicectl device install app \
  --device 8B9459D4-67C1-53A8-906D-C79A34679CB9 \
  "$(pwd)/build/DerivedData/Build/Products/Debug-iphoneos/Legacy Network.app"
```

`build/` is gitignored, so this leaves the working tree clean.

### Install troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `kAMDMobileImageMounterDeviceLocked` | **iPhone screen is locked** | Unlock the phone, re-run. Retrying will not help. |
| `CoreDeviceError error 3` / tunnel errors | transient | The script retries 3×. |
| App installs but won't launch | free-team profile expired (7 days) | Re-run the script. |
| "Untrusted Developer" on device | first install from this team | Settings → General → VPN & Device Management → trust. |

---

## 4. Architecture

```
LegacyNetwork/
├─ App/           LegacyNetworkApp.swift — @main, injects AppState
├─ State/         Composition root and observable app state
│   ├─ AppState.swift     ← wires everything; `data` returns MockDataService
│   ├─ AuthManager.swift  ← session phase (unknown/signedOut/signedIn)
│   ├─ RoleManager.swift  ← Distributor / Admin, persisted
│   ├─ SkinManager.swift  ← Current / Growth toggle (in AppSkin.swift)
│   └─ DataStore.swift
├─ Networking/    Data layer (see §6 — the live half is dormant)
├─ Models/        Codable structs mirroring real API response shapes
├─ Views/         One folder per feature area
├─ DesignSystem/  Theme.swift (tokens) + Components.swift (shared UI)
└─ Resources/     Info.plist, entitlements, Open Sans TTFs, Assets.xcassets
```

**Data flow:** `View` → `AppState.data` → `MockDataService(skin:)` → fixture → render.
Screens use the `AsyncScreen` component + `Loadable` enum, so they still exercise
real loading/loaded/error states even though the data is local and instant.

---

## 5. Screens and their data sources

Every screen is backed by one method on the `DataService` protocol
(`Networking/DataService.swift`), served by `MockDataService`.

Tab bar (`Views/MainTabView.swift`): **Home · Network · Earnings · Learn · [Admin] · Settings**.
The Admin tab appears only when `role == .admin && canUseAdmin`.

⚠️ In Admin role that is 6 tabs, and SwiftUI's `TabView` collapses anything past
the fifth into a system **"More"** list. Confirmed on the simulator: the visible
bar reads Home · Network · Earnings · Learn · **More**, with Admin and Settings
(including the Current/Growth toggle) one tap deeper. Functional, but it does not
match the web app's flat sidebar. If that fidelity matters, the fix is to move a
destination off the tab bar — e.g. Settings behind a toolbar gear — rather than
to add a sixth tab.

| Screen | View | `DataService` method |
|---|---|---|
| Dashboard | `Dashboard/DashboardView` | `dashboard()` — greeting, 4 stat tiles, XP/level/streak, recent activity |
| Network tree | `Network/NetworkTreeView` | `networkTree()` — 3-level downline, ranks, volume |
| Leaderboard | `Leaderboard/LeaderboardView` | `leaderboard(period:)` — 8 ranked entries |
| Earnings | `Earnings/EarningsView` | `earningsSummary()` — totals + 4-way breakdown |
| Commissions | `Commissions/CommissionsView` | `commissions(page:)` — 8 paid/pending rows |
| LGCT token | `Token/TokenView` | `tokenBalance()`, `tokenTransactions(page:)` |
| Quizzes | `Quiz/QuizListView`, `QuizSessionView`, `QuizResultsView` | `quizzes()`, `quizSession(id:)`, `submitQuiz(id:answers:)` |
| Achievements / XP | `Gamification/AchievementsView` | `achievements()` |
| Notifications | `Notifications/NotificationsView` | `notifications(page:)` |
| Profile | `Profile/ProfileView` | `profile()` |
| Login | `Auth/LoginView` | `login(...)` — **visual only**, returns a fixture, contacts nothing |
| Settings | `Settings/SettingsView` | local state + role/skin toggles |
| Manage Subscription | `Settings/BillingViews` | `subscription()` |
| Payment Information | `Settings/BillingViews` | `paymentMethods()` — test-card brands/last4 |
| Payment History | `Settings/BillingViews` | `paymentHistory(page:)` |
| Checkout / plans | `Checkout/CheckoutView` | `checkoutPlans()` — Starter / Pro / Elite |
| Admin dashboard | `Admin/AdminViews` | `adminMetrics()` |
| Admin members | `Admin/AdminViews` | `adminMembers(page:)`, `adminMemberDetail(id:)` |
| Admin payouts | `Admin/AdminViews` | `adminPayouts(page:)` |

---

## 6. The Networking folder — important

`Networking/` contains a complete, working live API layer: `APIClient` (async/await,
retry/backoff, caching, 401 handling), a typed `Endpoint` enum, `KeychainStore`,
`OfflineQueue`, `ResponseCache`, and `LiveDataService`.

**None of it runs.** `LiveDataService` is never instantiated. `APIClient` is
constructed in `AppState.init` but never issues a request (its init only assigns
properties and configures JSON coders — no I/O). `URLSession` appears solely as an
unused stored property inside `APIClient.swift`.

Verify the app is still offline after any change:
```bash
grep -rn "URLSession\|dataTask\|api\.legacynetwork" LegacyNetwork --include="*.swift"
grep -rn "LiveDataService(" LegacyNetwork --include="*.swift"
```
Expected: hits only inside `APIClient.swift`, and **no** `LiveDataService(` construction.

Switching to a real backend is a one-line change in `AppState.data` — but note that
would make it a live app, not the static replica this project is specified to be.

---

## 7. `MockDataService` structure

Single file: `LegacyNetwork/Networking/MockDataService.swift` (~294 lines). One
struct implementing every `DataService` method, organised by `// MARK:` sections
matching §5: auth → dashboard → network → earnings → token → gamification →
billing → admin.

To change what a screen shows, edit that screen's method. Nothing else reads
fixtures, so it is a one-file edit.

**Growth scaling.** A private computed `g: Double` scales every number:
- `.current` skin → `g == 1.0` (values render exactly as written)
- `.growth` skin → `g` starts at `0.15` and climbs `+0.03`/day toward `1.0`,
  anchored to first launch via the `growth_anchor_epoch` UserDefaults key.

Helpers `money(_:)`, `count(_:min:)`, `daysAgo(_:)`, `daysAhead(_:)` apply it.
Write the **Current-skin** value and let `g` derive the Growth one.

To reset the growth ramp: delete the app, or clear `growth_anchor_epoch`.

The demo identity is `Dianne Leavitt` / `dianne@legacynetwork.com`. It appears in
`demoUser`, `networkTree()` root, and `leaderboard()` — keep those three in sync
(they had drifted to "Dianne Powell" in two of them; fixed 2026-08-31).

---

## 8. Toggles

**Current / Growth** (`State/AppSkin.swift`, control in `SettingsView.dataSkinControl`)
— switches the data skin as described above. Persisted under `app_skin`.

**Distributor / Admin** (`State/RoleManager.swift`) — Admin is the default when the
account allows it, matching the web app. Changes the tab set and gates admin
screens. Persisted under `active_role`. `MainTabView` carries
`.id("\(role)-\(skin)")` so flipping either re-renders and re-reads data.

---

## 9. Design system

`LegacyNetwork/DesignSystem/Theme.swift`. Tokens were ported from the web app's
compiled stylesheet, archived at `DesignReference/legacy-web-app.css`.

| Token | Value |
|---|---|
| Primary blue | `#3171CC` (`Theme.Color.primary`) |
| Primary pressed | `#265399` |
| Teal accent | `#21BCAA` (`Theme.Color.accent`) |
| Dark header | `#1B1E23` (`Theme.Color.headerDark`) |
| Success | `#28A745` · bright `#30DF80` |
| Warning / orange | `#F4A45E` |
| Danger | `#DC3545` · bright `#DE0E0E` |
| Neutral text | `#7E7E7E` |
| Neutral fill | `#F1F1F2` · alt `#FBFBFD` |
| **Corner radius** | `Radius.md = 10` (default) · sm 6 · lg 16 · pill 999 |
| Spacing scale | 2 / 4 / 8 / 12 / 16 / 24 / 32 (`xxs`…`xxl`) |
| Card shadow | black 8%, radius 8, y+2 |

**Font — deliberate deviation from the original spec.** Earlier notes said
"Helvetica Neue". The app actually bundles and registers **Open Sans**
(`Resources/Fonts/*.ttf`, declared in `Info.plist` → `UIAppFonts`), because Open
Sans is the font the *real web app* uses; Helvetica Neue was only ever the
approximate iOS stand-in. Using the real face matches the design system more
exactly, which is the actual goal. Type ramp: largeTitle 32 bold, title 24 bold,
headline 18 medium, body 16, callout 15, subhead 14 medium, footnote 13, caption 12.

---

## 10. Current status

**Done**
- Full SwiftUI app, ~4,300 LOC, every screen in §5 implemented and populated
- Both Distributor and Admin modes; Current/Growth toggle working
- Design tokens ported from the real stylesheet; Open Sans bundled
- Zero network calls in the shipped app (verified by grep, §6)
- Signed device build succeeds against team `XF783932R2`
- `build-and-install.sh` rewritten: preflight, live device discovery, retry,
  locked-device detection, `--build-only` and `--launch` modes, and a
  checkout-local `-derivedDataPath` so it can never install another clone's build
- Verified reproducible: a fresh `git clone` into a temp dir, script invoked from
  an unrelated cwd, produced a signed `Legacy Network.app` inside its own checkout
- Verified it actually runs: installed and launched on the iPhone 16 Pro
  **simulator**; the app launches, stays up, and renders correctly (brand blue,
  teal accents, cream input fill, bundled Open Sans resolving — a missing
  `UIAppFonts` entry would silently fall back to the system font, and does not)

**Known gaps / next steps**
- Install to the **physical iPhone** was blocked the entire session by the device
  being locked (`kAMDMobileImageMounterDeviceLocked`). The signed device build
  itself succeeds — only the install step is pending. Unlock the phone and run
  `./build-and-install.sh --launch`. Nothing in the project needs changing.
- Consequently the populated screens were confirmed on the **simulator**, not on
  the physical device. Worth a look on-device once it installs.
- Admin role overflows the tab bar into a system "More" list (see §5) — a
  fidelity gap against the web sidebar, not a bug.
- Large numbers render unseparated on the dashboard ("48210 BV", "1284"). The web
  app most likely groups these ("48,210"). Left alone rather than guessed at,
  since verifying it needs a look at the live UI.
- No automated tests. `.github/workflows/ci.yml` builds only.
- App icon is a placeholder in several sizes.
- Numbers are representative, not live (§1).

---

## 11. Credentials

**None are stored in this repo, and none should ever be added.**

The app needs no credentials to build, install, or run — it is fully offline.

Web-app logins, the API base URL, and any GitHub PAT live in Connor's master
credentials store, not here, not in `HANDOFF.md`, and not in `MockDataService`.
Push to this repo with `gh auth login` (the `repo` scope is sufficient) rather
than embedding a token in `.git/config` or a remote URL.

`.gitignore` already blocks `extraction/`, `*.har`, `EXTRACTION.md`, `*.env`,
`Secrets.swift`, and `Credentials.plist`. Keep it that way.
