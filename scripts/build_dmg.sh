#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
# shellcheck source=scripts/eastmark_signing.sh
source "$ROOT/scripts/eastmark_signing.sh"

APP_DISPLAY_NAME="EastmarkHK Invoice Reader"
ENTITLEMENTS="$ROOT/EastmarkHK_Invoice_Reader/EastmarkHK_Invoice_Reader.entitlements"
NOTARIZE="${NOTARIZE:-0}"
CODESIGN_TIMESTAMP="${CODESIGN_TIMESTAMP:---timestamp}"

DEVELOPER_ID_SIGNING_IDENTITY="$(eastmark_resolve_signing_identity)"
DEVELOPMENT_TEAM="$(eastmark_resolve_team_id)"
NOTARY_PROFILE="$(eastmark_resolve_notary_profile)"

xcodegen generate

XCODEBUILD_ARGS=(
  -project "EastmarkHK Invoice Reader.xcodeproj"
  -scheme EastmarkHK_Invoice_Reader
  -configuration Release
  -derivedDataPath build/DerivedData
  DEVELOPMENT_TEAM="$DEVELOPMENT_TEAM"
)

xcodebuild "${XCODEBUILD_ARGS[@]}" build

APP="build/DerivedData/Build/Products/Release/${APP_DISPLAY_NAME}.app"
DIST="dist/${APP_DISPLAY_NAME}.app"
DMG="${APP_DISPLAY_NAME}.dmg"

rm -rf "$DIST"
mkdir -p dist
ditto "$APP" "$DIST"

if [ -n "$DEVELOPER_ID_SIGNING_IDENTITY" ]; then
  echo "==> Codesign (Developer ID + hardened runtime): $DEVELOPER_ID_SIGNING_IDENTITY"
  codesign --force --deep $CODESIGN_TIMESTAMP --options runtime \
    --entitlements "$ENTITLEMENTS" \
    --sign "$DEVELOPER_ID_SIGNING_IDENTITY" \
    "$DIST"
  codesign --verify --deep --strict --verbose=2 "$DIST"
else
  echo "warning: no Developer ID identity found — app is unsigned" >&2
fi

rm -f "$DMG" "EastmarkHK_Invoice_Reader.dmg"
"$ROOT/scripts/package_dmg.sh" dist "$DMG"

if [ -n "$DEVELOPER_ID_SIGNING_IDENTITY" ]; then
  echo "==> Signing DMG…"
  codesign --force $CODESIGN_TIMESTAMP --sign "$DEVELOPER_ID_SIGNING_IDENTITY" "$DMG"
fi

echo "Built: $DIST"

if [ "$NOTARIZE" != "1" ]; then
  echo "Notarization skipped (NOTARIZE=0). Run: NOTARIZE=1 ./scripts/build_dmg.sh"
  exit 0
fi

echo "==> Notarizing (keychain profile: $NOTARY_PROFILE)…"
xcrun notarytool submit "$DMG" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG"
xcrun stapler validate "$DMG"
echo "Notarized + stapled: $DMG"
