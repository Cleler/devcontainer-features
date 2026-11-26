#!/bin/bash

# This test file will be executed against one of the scenarios devcontainer.json test that
# includes the 'claude' feature with a non-root remote user ('octocat').

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib.
check "running as octocat" bash -c "[ \"\$(whoami)\" = octocat ]"
check "config dir writable by user" bash -c "touch \"\$CLAUDE_CONFIG_DIR/.write-test\" && rm \"\$CLAUDE_CONFIG_DIR/.write-test\""
check "managed settings readable by user" test -r /etc/claude-code/managed-settings.json
check "claude cli available" bash -c "command -v claude"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
