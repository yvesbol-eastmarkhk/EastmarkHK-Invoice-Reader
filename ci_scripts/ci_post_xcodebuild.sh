#!/bin/bash
# Xcode Cloud: optionally package archived app as DMG (direct download distribution).
#
# App Store Connect archive workflows should NOT set PACKAGE_DMG — post-xcodebuild must
# not fail an otherwise successful Mac App Store upload.
#
# Env:
#   PACKAGE_DMG=1     Build EastmarkHK Invoice Reader.dmg after archive
#   NOTARIZE=1        Notarize the DMG (requires NOTARY_KEYCHAIN_PROFILE on CI)
set -eu

cd "${CI_PRIMARY_REPOSITORY_PATH:-.}"

if [ "${PACKAGE_DMG:-0}" != "1" ]; then
  echo "PACKAGE_DMG is not 1 — skipping DMG packaging (App Store archives unaffected)."
  exit 0
fi

if [ -z "${CI_ARCHIVE_PATH:-}" ]; then
  echo "CI_ARCHIVE_PATH is empty — nothing to package."
  exit 0
fi

APP_NAME="EastmarkHK Invoice Reader.app"
DMG_NAME="EastmarkHK Invoice Reader.dmg"
CODESIGN_TIMESTAMP="${CODESIGN_TIMESTAMP:---timestamp}"
APP_PATH="${CI_ARCHIVE_PATH}/Products/Applications/${APP_NAME}"
APP_DIR="$(dirname "$APP_PATH")"

if [ ! -d "$APP_PATH" ]; then
  echo "App not found at ${APP_PATH}"
  exit 1
fi

if ! command -v create-dmg >/dev/null 2>&1; then
  echo "Installing create-dmg…"
  brew install create-dmg
fi

# shellcheck source=scripts/eastmark_signing.sh
source "${CI_PRIMARY_REPOSITORY_PATH}/scripts/eastmark_signing.sh"

SIGN_IDENTITY="$(eastmark_resolve_signing_identity || true)"
NOTARY_PROFILE="$(eastmark_resolve_notary_profile)"
DMG_PATH="${CI_PRIMARY_REPOSITORY_PATH}/${DMG_NAME}"

echo "Packaging ${APP_NAME} as DMG…"
"${CI_PRIMARY_REPOSITORY_PATH}/scripts/package_dmg.sh" "$APP_DIR" "$DMG_PATH"

if [ -n "$SIGN_IDENTITY" ]; then
  echo "Signing DMG with: ${SIGN_IDENTITY}"
  codesign --force $CODESIGN_TIMESTAMP --sign "$SIGN_IDENTITY" "$DMG_PATH"
else
  echo "No Developer ID identity — DMG left unsigned."
fi

if [ "${NOTARIZE:-0}" != "1" ]; then
  echo "NOTARIZE is not 1 — DMG built but not notarized."
  echo "DMG: ${DMG_PATH}"
  exit 0
fi

echo "Notarizing DMG (profile: ${NOTARY_PROFILE})…"
xcrun notarytool submit "$DMG_PATH" --keychain-profile "$NOTARY_PROFILE" --wait
xcrun stapler staple "$DMG_PATH"
xcrun stapler validate "$DMG_PATH"
echo "Notarized + stapled DMG: ${DMG_PATH}"
