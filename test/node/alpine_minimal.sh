#!/bin/bash

# This test file will be executed against the 'alpine_minimal' scenario of scenarios.json: a bare
# alpine image with only bash (see Dockerfile.alpine). There is no 'vscode' user, no curl, no git:
# the feature has to install its own dependencies, and falls back on root.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "alpine" test -f /etc/alpine-release
check "there is no vscode user" bash -c "! id vscode"

# Dependencies installed by the feature
check "curl installed" curl --version
check "git installed" git --version

# Falls back on root as there is no other user
check "root is in the nvm group" bash -c "id -nG root | grep -qw nvm"
check "node installed" node --version
check "npm installed" npm --version

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
