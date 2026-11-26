# Legacy Network iOS

The app **is** the Legacy Network web replica. `LegacyNetwork/Resources/replica.html`
(one self-contained file: fonts, logo, photos and charts are all inlined) is shown
full-screen in WebKit by `LegacyNetwork/App/LegacyNetworkApp.swift`. Nothing is
redrawn natively, so the app matches the replica pixel for pixel.

- Loaded under the `https://app.legacynetwork.com` origin so the replica's real
  paths (`/settings/menu`, `/admin`, …) and history navigation work. No network
  requests are made; everything is in the bundled file.
- Distributor / Admin switch: Settings screen, under the profile header.
- Status-bar and home-indicator areas are painted with the color the page shows
  at its top and bottom edge (sampled live, translucent overlays composited).
- Every screen view, tap, JS error and load step goes to the append-only
  `event_log` via `EventLog.swift`.

Website (same file, deploys on every push to `main`): https://temporary-swift-platinum-irlncys.vercel.app

## Updating the app
Replace `LegacyNetwork/Resources/replica.html` with the new replica and push to
`main`. GitHub Actions (`.github/workflows/ios.yml`) builds on a hosted Mac,
signs, and uploads to TestFlight (build number = run number + 100). No local Mac
is needed.

Bundle id `com.connor.legacynetwork`, team `XF783932R2`, App Store Connect app 6807329508.
