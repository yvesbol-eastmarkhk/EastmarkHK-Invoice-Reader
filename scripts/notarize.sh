#!/bin/bash
# Notarize a local Release build (app + DMG).
#
# Uses the same EastmarkHK keychain profile as e-Invoicing (default: EastmarkHK).
#
# Usage:
#   ./scripts/notarize.sh
#   NOTARIZE_DMG_ONLY=1 ./scripts/notarize.sh
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
# shellcheck source=scripts/eastmark_signing.sh
source "$ROOT/scripts/eastmark_signing.sh"

APP_NAME="EastmarkHK Invoice Reader"
APP_PATH="dist/${APP_NAME}.app"
DMG_PATH="${APP_NAME}.dmg"
ENTITLEMENTS="$ROOT/EastmarkHK_Invoice_Reader/EastmarkHK_Invoice_Reader.entitlements"
PROFILE="$(eastmark_resolve_notary_profile)"
SIGN_IDENTITY="$(eastmark_resolve_signing_identity)"
CODESIGN_TIMESTAMP="${CODESIGN_TIMESTAMP:---timestamp}"

if [ -z "$SIGN_IDENTITY" ]; then
  echo "error: no Developer ID Application identity in Keychain" >&2
  exit 1
fi

notarize_path() {
  local artifact="$1"
  echo "Submitting: $artifact"
  xcrun notarytool submit "$artifact" --keychain-profile "$PROFILE" --wait
}

sign_app() {
  if [ ! -d "$APP_PATH" ]; then
    echo "Missing app bundle: $APP_PATH (run ./scripts/build_dmg.sh first)"
    exit 1
  fi
  echo "Signing app with: $SIGN_IDENTITY"
  codesign --force --deep $CODESIGN_TIMESTAMP --options runtime \
    --entitlements "$ENTITLEMENTS" \
    --sign "$SIGN_IDENTITY" "$APP_PATH"
  codesign --verify --deep --strict --verbose=2 "$APP_PATH"
}

if [ "${NOTARIZE_DMG_ONLY:-0}" != "1" ]; then
  sign_app
  ZIP_PATH="$(mktemp -t notarize).zip"
  ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"
  xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$PROFILE" --wait
  rm -f "$ZIP_PATH"
  xcrun stapler staple "$APP_PATH"
  echo "Stapled app: $APP_PATH"
fi

if [ -f "$DMG_PATH" ]; then
  notarize_path "$DMG_PATH"
  xcrun stapler staple "$DMG_PATH"
  echo "Stapled DMG: $DMG_PATH"
fi

echo "Notarization complete."
