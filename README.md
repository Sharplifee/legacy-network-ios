# Legacy Network iOS

Native SwiftUI client for the Legacy Network platform.

## Overview

Full native iOS replication of the Legacy Network web application, built as a
**static visual replica**: every screen renders fully populated, entirely offline.

The shipped app makes **zero network calls** and needs no credentials to build or
run. All content is served from `MockDataService`. A complete live API layer
exists under `Networking/` but is dormant and never instantiated.

> **See [HANDOFF.md](HANDOFF.md)** for full project state: architecture, every
> screen and its data source, design tokens, build/install commands, and status.

## Stack

- **UI:** SwiftUI, iOS 17.0+
- **Project generation:** XcodeGen — `project.yml` is the single source of truth
- **Data:** `MockDataService` — in-memory fixtures, no I/O
- **Networking:** async/await URLSession + typed endpoint enum — present but dormant
- **Backend:** none in the shipped app

## Design System

| Token | Value |
|---|---|
| Primary blue | `#3171CC` |
| Teal accent | `#21BCAA` |
| Dark header | `#1B1E23` |
| Font | Open Sans (bundled, matches the web app) |
| Corner radius | 10px |

## Roles

The app supports two role modes via a toggle in Settings:

- **Distributor** — standard member view
- **Admin** — elevated access, additional screens and data surfaces

Admin-only screens must never render for Distributor-role users.

## Build

Requires Xcode and XcodeGen (`brew install xcodegen`). From a clean clone:

```bash
./build-and-install.sh              # generate + sign + install to connected devices
./build-and-install.sh --launch     # ...and launch
./build-and-install.sh --build-only # sign only, no device needed
```

Bundle ID `com.legacynetwork.app`, development team `XF783932R2`.

## Project Structure

```
LegacyNetwork/
├── App/            # App entry point
├── Views/          # SwiftUI screens by feature
├── Models/         # Codable data models
├── Networking/     # APIClient, AuthManager, Endpoints, Keychain
├── DesignSystem/   # Colors, typography, spacing, components
└── Resources/      # Assets, Info.plist
```

## Notes

- Never edit `.xcodeproj` or `Info.plist` directly — they are generated from `project.yml`
- The `extraction/` directory is gitignored: it contains live production user data
- No credentials are committed to this repository, and none are needed
- Mock data is **representative**, not scraped from a real account — this repo is
  public, so real member/payment records must never be baked in (see HANDOFF.md §1)
## Status

This branch is a **complete, self-consistent SwiftUI scaffold** authored in a
Linux CI environment. It has **not** been compiled or signed (that requires
macOS + Xcode) and no live production data was extracted to build it.

- **Design system, networking, auth, and navigation** are production-shaped:
  typed `Endpoint` enum, async/await `APIClient` (retry + backoff, response
  cache, offline queue, 401 handling, role-aware routing), Keychain-stored
  Sanctum token, and role-based tab navigation.
- **Every screen** in the spec is implemented with loading / error / empty
  states: Login, Settings, Dashboard, Profile, Network tree (expand/collapse),
  Leaderboard, Commissions, Earnings, LGCT token wallet, Quiz list/session/
  results, Achievements, XP/Level/Streak, Notifications, Subscription, Payment
  Information, Payment History, plus admin Dashboard/Members/Member detail/
  Payouts.
- **Models are seeded from the documented domain, not captured JSON.** Before
  shipping, reconcile field names and endpoint paths against real responses —
  see `LegacyNetwork/Models/README_MODELS.md` and `RELEASE.md`.

### Next steps to a shippable build (on a Mac)

1. `brew install xcodegen && xcodegen generate`
2. Open in Xcode, resolve any first-compile adjustments.
3. Run the authorized forensic capture, then reconcile `Models/*` + `Endpoint.path`.
4. `./build-and-install.sh` to run on device/simulator; `RELEASE.md` for archive/upload.
