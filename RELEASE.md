# Release Guide — Legacy Network iOS

Version **1.0.0** (build **1**). Bundle id `com.legacynetwork.app`. Team `XF783932R2`.

> All build/sign/archive steps require **macOS + Xcode**. This scaffold was
> authored in a Linux CI environment, so the commands below must be run on a Mac.

## 0. What this build is

A **front-end visual replica** with **no backend integration**. Every screen,
tab, button, and the full checkout flow are present and interactive, but they run
entirely on in-memory fixtures — no network calls, no real user/payment data, no
payment processing.

- **Data source:** `MockDataService` (see `LegacyNetwork/Networking/DataService.swift`).
  A discreet **Current / Growth** skin toggle on the Settings page switches the
  whole app between a populated "current snapshot" and a "growth" skin whose
  numbers ramp up over real elapsed time.
- **Going live later:** the real `APIClient` + `LiveDataService` are retained.
  Swap the one line in `AppState.data` from `MockDataService(...)` to
  `LiveDataService(client:)` to run against the backend (after reconciling models
  and endpoint paths against captured responses).
- **Checkout:** `LegacyNetwork/Views/Checkout/CheckoutView.swift` — plan select →
  card + billing form → review → Pay → confirmation. Interactive but
  **non-processing**; the "Pay" button simulates a delay then shows a confirmation.
- **Fonts:** Open Sans (Regular/Medium/SemiBold/Bold, SIL OFL) is bundled under
  `Resources/Fonts` and registered via `UIAppFonts`. `Theme.Font` references each
  face by its exact PostScript name.

> **Not yet compiled.** Authored on Linux with no Swift toolchain. Expect to run
> `xcodegen generate` + a first Xcode build to catch any first-compile
> adjustments before it runs on device.

## 1. Prerequisites

```bash
brew install xcodegen        # project generation
xcode-select -p              # ensure Xcode CLT selected
```

## 2. Generate the project

`project.yml` is the single source of truth. Never edit `.xcodeproj` or
`Info.plist` by hand.

```bash
xcodegen generate
open LegacyNetwork.xcodeproj
```

## 3. Local run (simulator)

```bash
./build-and-install.sh          # defaults to iPhone 16 Pro simulator UDID
# or pass a UDID / device id:
./build-and-install.sh <DEVICE_UDID>
```

## 4. Archive for the App Store

```bash
xcodegen generate
xcodebuild \
  -project LegacyNetwork.xcodeproj \
  -scheme LegacyNetwork \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -allowProvisioningUpdates \
  -archivePath build/LegacyNetwork.xcarchive \
  archive
```

## 5. Export & upload

`ExportOptions.plist` (repo root) is configured for `app-store` distribution
with automatic signing under team `XF783932R2`.

```bash
xcodebuild -exportArchive \
  -archivePath build/LegacyNetwork.xcarchive \
  -exportOptionsPlist ExportOptions.plist \
  -exportPath build/export \
  -allowProvisioningUpdates

# Upload with either:
xcrun altool --upload-app -f build/export/*.ipa -t ios \
  --apiKey "$ASC_KEY_ID" --apiIssuer "$ASC_ISSUER_ID"
# or Transporter.app (drag the .ipa)
```

## 6. App Store readiness checklist

- [x] Version 1.0.0, build 1 (`MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in `project.yml`)
- [x] App icon 1024 (globe on #3171CC, full-bleed, no white space)
- [x] Display name **Legacy Network**
- [x] Privacy usage descriptions (camera, photo library, Face ID, notifications) in `Info.plist`
- [x] ATS enabled — `NSAllowsArbitraryLoads = false`, TLS 1.2+ pinned for `api.legacynetwork.com`
- [x] `aps-environment` entitlement (push scaffold) — flip to `production` before store submit
- [x] No hardcoded credentials, debug `print`, or extraction artifacts in the shipping target
- [x] Open Sans faces bundled + registered via `UIAppFonts`
- [ ] `xcodegen generate` + first Xcode build on a Mac; resolve any first-compile adjustments
- [ ] Provide screenshots of the logged-in web screens and reconcile each screen's
      mock data + copy to exact fidelity (blocked on owner-supplied screenshots)
- [ ] (Only if wiring the real backend) reconcile models + endpoint paths against
      captured live responses (see `LegacyNetwork/Models/README_MODELS.md`)
- [ ] Provide App Store screenshots + privacy nutrition label in App Store Connect
- [ ] Switch push entitlement to `production` and add real APNs handling

## Notes

- The Sanctum token is stored only in the Keychain; credentials are never persisted.
- `extraction/` and `EXTRACTION.md` remain gitignored — they are for authorized,
  locally-run forensic capture only and must never be committed.

## Finish it entirely from CI (no local Mac)

Building/signing needs macOS. If you don't want to run Xcode locally, a macOS
GitHub Actions runner does all of it. Three workflows are wired:

| Workflow | Trigger | What it does |
|---|---|---|
| `ci.yml` | push / PR / dispatch | Compiles for the iOS Simulator (no signing) — the compile gate. |
| `screenshots.yml` | push / dispatch | Installs on an iPhone 16 Pro sim, runs the UI-test pass, and uploads a PNG of **every screen** (plus the raw `.xcresult`). |
| `release.yml` | dispatch | Archives, signs, exports a distributable `.ipa`, and (optionally) uploads to TestFlight. |

**To turn them on:**

1. Enable GitHub-hosted macOS Actions for the repo (Settings → Billing → set an
   Actions spending limit; macOS minutes are billable), **or** register a
   self-hosted macOS runner. Until then these jobs fail fast with "no runner".
2. `ci.yml` and `screenshots.yml` need nothing else — they run unsigned.
3. For `release.yml`, add these repository **secrets**:
   - `BUILD_CERTIFICATE_BASE64` — `base64 -i AppleDistribution.p12`
   - `P12_PASSWORD` — that .p12's password
   - `APP_STORE_CONNECT_KEY_ID`, `APP_STORE_CONNECT_ISSUER_ID`
   - `APP_STORE_CONNECT_KEY_BASE64` — `base64 -i AuthKey_XXXX.p8`
   Optionally set repo **variable** `UPLOAD_TO_TESTFLIGHT=true` to auto-upload.

Once macOS minutes are on, every push compiles and screenshots automatically;
`release.yml` produces the signed build on demand. Until then, build locally on a
Mac with `./build-and-install.sh` (see above) — the workflows are armed and will
start passing the moment a macOS runner is available, with no further edits.
