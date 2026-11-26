#!/bin/bash

# This test file will be executed against one of the scenarios devcontainer.json test that
# includes the 'claude' feature with "managed-claude-md" and "managed-settings-json"
# set to false.

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "no managed settings" bash -c "[ ! -e /etc/claude-code/managed-settings.json ]"
check "no managed CLAUDE.md" bash -c "[ ! -e /etc/claude-code/CLAUDE.md ]"
check "claude cli still installed" bash -c "command -v claude"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
