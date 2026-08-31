#!/bin/bash
# Initialize git and create a public GitHub repo for Xcode Cloud.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

REPO_NAME="${GITHUB_REPO_NAME:-EastmarkHK-Invoice-Reader}"
VISIBILITY="${GITHUB_VISIBILITY:-public}"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Git repository already initialized."
else
  git init -b main
fi

if ! git diff --cached --quiet 2>/dev/null || [ -n "$(git status --porcelain)" ]; then
  git add -A
  git commit -m "$(cat <<'EOF'
Initial commit: EastmarkHK Invoice Reader macOS app.

Swift/SwiftUI PEPPOL invoice reader with XcodeGen, DMG packaging, and Xcode Cloud CI scripts.
EOF
)"
fi

if git remote get-url origin >/dev/null 2>&1; then
  echo "Remote origin already configured:"
  git remote -v
  exit 0
fi

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required. Install with: brew install gh"
  exit 1
fi

gh auth status

gh repo create "$REPO_NAME" \
  --"${VISIBILITY}" \
  --source=. \
  --remote=origin \
  --description "Native macOS PEPPOL invoice reader (EastmarkHK)" \
  --push

echo ""
echo "Repository: $(gh repo view --json url -q .url)"
echo "Next: connect this repo in Xcode → Product → Xcode Cloud → Create Workflow."
