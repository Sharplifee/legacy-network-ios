#!/usr/bin/env bash
#
# Legacy Network iOS — regenerate, build signed, and install to a device.
#
# Reproduces the app from a clean clone on any Mac. No extra context needed:
#   git clone https://github.com/Sharplifee/legacy-network-ios.git
#   cd legacy-network-ios && ./build-and-install.sh
#
# The app is a STATIC REPLICA — it makes zero network calls, so no credentials,
# API keys, or backend access are required to build or run it.
#
# Usage: ./build-and-install.sh [-l|--launch] [-b|--build-only] [DEVICE_ID]
#   -l, --launch      launch the app after a successful install
#   -b, --build-only  build and sign, skip install (no device needed)
#   DEVICE_ID         install to this devicectl identifier only.
#                     Default: auto-discover every connected iOS device.
#
# Requires: macOS, Xcode, XcodeGen (brew install xcodegen).

set -euo pipefail

TEAM_ID="XF783932R2"
SCHEME="LegacyNetwork"
BUNDLE_ID="com.legacynetwork.app"
PROJECT="LegacyNetwork.xcodeproj"

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LAUNCH=0
BUILD_ONLY=0
DEVICE_ARG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -l|--launch)     LAUNCH=1; shift ;;
    -b|--build-only) BUILD_ONLY=1; shift ;;
    -h|--help)       sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)              echo "ERROR: unknown option: $1" >&2; exit 2 ;;
    *)               DEVICE_ARG="$1"; shift ;;
  esac
done

# --- STEP 0: PREFLIGHT -------------------------------------------------------
if ! command -v xcodegen >/dev/null 2>&1; then
  echo "ERROR: XcodeGen not found. Install it with:  brew install xcodegen" >&2
  exit 1
fi
if ! command -v xcodebuild >/dev/null 2>&1; then
  echo "ERROR: xcodebuild not found. Install Xcode from the App Store." >&2
  exit 1
fi

# --- STEP 1: GENERATE --------------------------------------------------------
# project.yml is the single source of truth; the .xcodeproj is gitignored and
# regenerated every run, so a clean clone always produces the same project.
echo "▸ Generating $PROJECT from project.yml"
xcodegen generate

# --- STEP 2: BUILD (SIGNED, DEVICE) -----------------------------------------
echo "▸ Building signed iphoneos build (team $TEAM_ID)"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  build

# --- STEP 3: LOCATE THE BUILT .app ------------------------------------------
# PRODUCT_NAME is "Legacy Network" (with a space) while the scheme is
# "LegacyNetwork" — read WRAPPER_NAME rather than assuming they match.
SETTINGS=$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration Debug \
  -showBuildSettings 2>/dev/null)
WRAPPER=$(echo "$SETTINGS" | awk -F' = ' '/ WRAPPER_NAME = /{print $2; exit}')
WRAPPER="${WRAPPER:-$SCHEME.app}"

APP=$(find ~/Library/Developer/Xcode/DerivedData -name "$WRAPPER" \
  -path "*/Debug-iphoneos/*" ! -path "*/PlugIns/*" ! -path "*.app/*" \
  -prune -print0 2>/dev/null \
  | xargs -0 stat -f '%m %N' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
if [[ -z "${APP:-}" || ! -d "$APP" ]]; then
  echo "ERROR: built app '$WRAPPER' not found in DerivedData" >&2
  exit 1
fi
echo "▸ Built: $APP"

if [[ $BUILD_ONLY -eq 1 ]]; then
  echo "OK: build complete (--build-only, skipping install)."
  exit 0
fi

# --- STEP 4: DISCOVER DEVICES ------------------------------------------------
# Hardcoded UDIDs go stale across re-pairs and machines, so discover live.
DEVICES=()
if [[ -n "$DEVICE_ARG" ]]; then
  DEVICES+=("$DEVICE_ARG"$'\t'"(specified)")
else
  TMP=$(mktemp)
  xcrun devicectl list devices --json-output "$TMP" >/dev/null 2>&1 || true
  while IFS= read -r line; do
    [[ -n "$line" ]] && DEVICES+=("$line")
  done < <(python3 - "$TMP" <<'PY'
import json, sys
try:
    d = json.load(open(sys.argv[1]))
except Exception:
    sys.exit(0)
for dev in d.get("result", {}).get("devices", []):
    hw = dev.get("hardwareProperties", {})
    if hw.get("platform") != "iOS":
        continue
    # Only devices actually reachable right now.
    state = dev.get("connectionProperties", {}).get("tunnelState", "")
    if state == "unavailable":
        continue
    print(f'{dev["identifier"]}\t{dev.get("deviceProperties", {}).get("name", "?")}')
PY
)
  rm -f "$TMP"
fi

if [[ ${#DEVICES[@]} -eq 0 ]]; then
  echo "ERROR: no connected iOS device found." >&2
  echo "  Plug in an iPhone, unlock it, and trust this Mac." >&2
  echo "  To build without installing:  ./build-and-install.sh --build-only" >&2
  exit 1
fi

# --- STEP 5: INSTALL ---------------------------------------------------------
rc=0
for entry in "${DEVICES[@]}"; do
  id="${entry%%$'\t'*}"
  name="${entry#*$'\t'}"
  echo "▸ Installing to $name ($id)"

  ok=0
  out=""
  for attempt in 1 2 3; do
    if out=$(xcrun devicectl device install app --device "$id" "$APP" 2>&1); then
      ok=1; break
    fi
    # The device being locked is by far the most common failure, and no amount
    # of retrying fixes it — surface it plainly instead of burning attempts.
    if grep -q "DeviceLocked\|device is locked" <<<"$out"; then
      echo "  BLOCKED: $name is locked. Unlock the screen and re-run this script." >&2
      break
    fi
    echo "  attempt $attempt failed; retrying in $((attempt*3))s..." >&2
    sleep $((attempt*3))
  done

  if [[ $ok -eq 1 ]]; then
    echo "  OK: installed to $name"
    if [[ $LAUNCH -eq 1 ]]; then
      if xcrun devicectl device process launch --device "$id" "$BUNDLE_ID" >/dev/null 2>&1; then
        echo "  LAUNCHED on $name"
      else
        echo "  WARN: launch failed on $name (unlock the device and retry)" >&2
      fi
    fi
  else
    echo "  FAILED: $name" >&2
    echo "$out" | tail -3 >&2
    rc=1
  fi
done

exit $rc
