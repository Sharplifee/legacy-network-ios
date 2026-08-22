# Release Guide — Legacy Network iOS

Version **1.0.0** (build **1**). Bundle id `com.legacynetwork.app`. Team `XF783932R2`.

> All build/sign/archive steps require **macOS + Xcode**. This scaffold was
> authored in a Linux CI environment, so the commands below must be run on a Mac.

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
- [ ] Reconcile all models + endpoint paths against captured live responses (see `LegacyNetwork/Models/README_MODELS.md`)
- [ ] Provide App Store screenshots + privacy nutrition label in App Store Connect
- [ ] Switch push entitlement to `production` and add real APNs handling

## Notes

- The Sanctum token is stored only in the Keychain; credentials are never persisted.
- `extraction/` and `EXTRACTION.md` remain gitignored — they are for authorized,
  locally-run forensic capture only and must never be committed.
