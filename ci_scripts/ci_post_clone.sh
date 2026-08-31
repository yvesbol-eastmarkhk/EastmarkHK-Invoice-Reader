#!/bin/sh
# Xcode Cloud: generate the Xcode project and install tools before the build.
set -eu

cd "${CI_PRIMARY_REPOSITORY_PATH:-.}"

if ! command -v xcodegen >/dev/null 2>&1; then
  echo "Installing XcodeGen…"
  brew install xcodegen
fi

echo "Generating Xcode project…"
xcodegen generate
