#!/bin/bash
# Create a styled DMG from a folder that contains the .app bundle.
#
# Usage:
#   ./scripts/package_dmg.sh /path/to/folder/containing/App.app [output.dmg]
#
set -euo pipefail

APP_DIR="${1:?usage: package_dmg.sh <app-folder> [output.dmg]}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

APP_DISPLAY_NAME="EastmarkHK Invoice Reader"
DMG="${2:-${APP_DISPLAY_NAME}.dmg}"

if [ ! -d "${APP_DIR}/${APP_DISPLAY_NAME}.app" ]; then
  echo "error: ${APP_DIR}/${APP_DISPLAY_NAME}.app not found" >&2
  exit 1
fi

if ! command -v create-dmg >/dev/null 2>&1; then
  echo "error: create-dmg not found (brew install create-dmg)" >&2
  exit 1
fi

if [ ! -f "assets/dmg_background.png" ]; then
  python3 scripts/make_dmg_background.py
fi

rm -f "$DMG"
create-dmg \
  --volname "$APP_DISPLAY_NAME" \
  --volicon "AppIcon.icns" \
  --background "assets/dmg_background.png" \
  --window-pos 200 120 \
  --window-size 660 400 \
  --icon-size 96 \
  --icon "${APP_DISPLAY_NAME}.app" 170 185 \
  --hide-extension "${APP_DISPLAY_NAME}.app" \
  --app-drop-link 490 185 \
  --no-internet-enable \
  "$DMG" \
  "$APP_DIR"

echo "DMG: $ROOT/$DMG"
