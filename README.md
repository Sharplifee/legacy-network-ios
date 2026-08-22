# Legacy Network iOS

Native SwiftUI client for the Legacy Network platform.

## Overview

Full native iOS replication of the Legacy Network web application, talking to the
same live production backend. Same data, same users, same API — native experience.

## Stack

- **UI:** SwiftUI, iOS 17.0+
- **Project generation:** XcodeGen — `project.yml` is the single source of truth
- **Networking:** async/await URLSession, typed endpoint enum
- **Auth:** Laravel Sanctum bearer tokens, stored in Keychain
- **Backend:** `https://api.legacynetwork.com` (PHP 8.3 / Laravel)

## Design System

| Token | Value |
|---|---|
| Primary blue | `#3171CC` |
| Teal accent | `#21BCAA` |
| Dark header | `#1B1E23` |
| Font | Helvetica Neue |
| Corner radius | 10px |

## Roles

The app supports two role modes via a toggle in Settings:

- **Distributor** — standard member view
- **Admin** — elevated access, additional screens and data surfaces

Admin-only screens must never render for Distributor-role users.

## Build

```bash
xcodegen generate
./build-and-install.sh
```

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
- No credentials are committed to this repository