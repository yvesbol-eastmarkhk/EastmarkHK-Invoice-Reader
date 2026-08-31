#!/bin/bash
# Shared EastmarkHK signing helpers (aligned with e-Invoicing tool/build_dmg.sh).
set -euo pipefail

eastmark_resolve_signing_identity() {
  if [ -n "${DEVELOPER_ID_SIGNING_IDENTITY:-}" ]; then
    printf '%s\n' "$DEVELOPER_ID_SIGNING_IDENTITY"
    return 0
  fi
  if [ -n "${DEVELOPER_ID_APPLICATION:-}" ]; then
    printf '%s\n' "$DEVELOPER_ID_APPLICATION"
    return 0
  fi
  security find-identity -v -p codesigning 2>/dev/null \
    | sed -n 's/.*"\(Developer ID Application:.*\)"/\1/p' \
    | head -1
}

eastmark_resolve_team_id() {
  if [ -n "${DEVELOPMENT_TEAM:-}" ]; then
    printf '%s\n' "$DEVELOPMENT_TEAM"
    return 0
  fi
  printf '%s\n' "GXA7QXQK2X"
}

eastmark_resolve_notary_profile() {
  printf '%s\n' "${NOTARY_KEYCHAIN_PROFILE:-${NOTARYTOOL_PROFILE:-EastmarkHK}}"
}
