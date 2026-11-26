#!/bin/bash

# This test file will be executed against the 'alpine' scenario of scenarios.json: the 'node' feature
# on the Alpine Dev Containers base image (non-root user 'vscode', bash and curl already there).
# It checks what is specific to Alpine; the generic checks are in test.sh.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "alpine" test -f /etc/alpine-release

# Node.js must be the musl build: the glibc build from nodejs.org can't run on Alpine
check "node is a musl build" bash -c "[ -z \"\$(node -p 'process.report.getReport().header.glibcVersionRuntime || \"\"')\" ]"
check "musl mirror is set for the user's own nvm install" bash -ic 'echo "$NVM_NODEJS_ORG_MIRROR" | grep -q unofficial-builds.nodejs.org'

# BusyBox has no groupadd/usermod: the nvm group and its membership must come from addgroup
check "user is in the nvm group" bash -c "id -nG vscode | grep -qw nvm"
check "nvm is sourced by interactive bash" bash -ic "command -v nvm"

# musl headers are needed by gcc to compile native modules
check "musl-dev installed" apk info -e musl-dev

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
