#!/bin/bash

# This test file will be executed against the 'alpine' scenario of scenarios.json: the 'claude-code'
# feature alone on the Alpine Dev Containers base image. Node.js comes from the 'node' feature of this
# repository, declared in 'dependsOn' (the official node feature doesn't support Alpine).

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "alpine" test -f /etc/alpine-release
check "node installed by the node feature (nvm)" bash -c "command -v node | grep -q /usr/local/share/nvm"
check "claude cli installed" command -v claude
check "claude version" claude --version

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
