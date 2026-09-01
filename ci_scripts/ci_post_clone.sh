#!/bin/sh
# Xcode Cloud post-clone: this repo's Xcode project is generated from
# project.yml by XcodeGen and is not committed, so generate it before build.
set -e
if ! command -v xcodegen >/dev/null 2>&1; then
  brew install xcodegen
fi
cd "$CI_PRIMARY_REPOSITORY_PATH"
xcodegen generate
echo "xcodegen: project generated"
