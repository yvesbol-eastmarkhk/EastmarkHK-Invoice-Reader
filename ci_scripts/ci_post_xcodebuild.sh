#!/bin/sh
# Xcode Cloud: optional notarization after archive (set env vars in App Store Connect).
set -eu

cd "${CI_PRIMARY_REPOSITORY_PATH:-.}"

if [ "${NOTARIZE:-0}" != "1" ]; then
  echo "NOTARIZE is not 1 — skipping notarization."
  exit 0
fi

if [ -z "${CI_ARCHIVE_PATH:-}" ]; then
  echo "CI_ARCHIVE_PATH is empty — skipping notarization."
  exit 0
fi

APP_NAME="EastmarkHK Invoice Reader.app"
APP_PATH="${CI_ARCHIVE_PATH}/Products/Applications/${APP_NAME}"

if [ ! -d "$APP_PATH" ]; then
  echo "App not found at ${APP_PATH}"
  exit 1
fi

ZIP_PATH="${CI_DERIVED_DATA_PATH:-/tmp}/notarize-app.zip"
/usr/bin/ditto -c -k --keepParent "$APP_PATH" "$ZIP_PATH"

PROFILE="${NOTARY_KEYCHAIN_PROFILE:-${NOTARYTOOL_PROFILE:-EastmarkHK}}"
echo "Submitting ${APP_NAME} for notarization (profile: ${PROFILE})…"
xcrun notarytool submit "$ZIP_PATH" --keychain-profile "$PROFILE" --wait

echo "Stapling notarization ticket…"
xcrun stapler staple "$APP_PATH"
