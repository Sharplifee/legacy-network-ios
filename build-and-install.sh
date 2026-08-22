#!/usr/bin/env bash
# Generate the Xcode project, build a signed iphoneos build, and install to a
# connected device / booted simulator. Requires macOS + Xcode + XcodeGen.
set -euo pipefail

TEAM_ID="XF783932R2"
SCHEME="LegacyNetwork"
DEVICE_ID="${1:-E345E8D2-A17B-425B-A046-1D223A2B412D}"   # iPhone 16 Pro (override as $1)

command -v xcodegen >/dev/null || { echo "Install XcodeGen: brew install xcodegen"; exit 1; }

echo "▸ Generating Xcode project from project.yml"
xcodegen generate

echo "▸ Building signed iphoneos build"
xcodebuild \
  -project LegacyNetwork.xcodeproj \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "id=$DEVICE_ID" \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  build

echo "▸ Installing to device/simulator $DEVICE_ID"
# For a simulator target, use: xcrun simctl install "$DEVICE_ID" <path-to.app>
# For a physical device, use: xcrun devicectl device install app --device "$DEVICE_ID" <path-to.app>
echo "Build complete. See RELEASE.md for archive + App Store upload steps."
