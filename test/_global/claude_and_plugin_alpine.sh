#!/bin/bash

# The 'test/_global' folder is a special test folder that is not tied to a single feature.
#
# This test file is executed against a running container constructed
# from the value of 'claude_and_plugin_alpine' in the tests/_global/scenarios.json file.
#
# The value of a scenarios element is any properties available in the 'devcontainer.json'.
# Scenarios are useful for testing specific options in a feature, or to test a combination of features.
#
# This test can be run with the following command (from the root of this repo)
#    devcontainer features test --global-scenarios-only .

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
check "alpine" test -f /etc/alpine-release
check "node and npm installed (repository's node feature)" bash -c "command -v node && command -v npm"
# The 'check' command comes from the dev-container-features-test-lib.
check "claude cli installed" bash -c "command -v claude"
check "config dir is shared and writable" bash -c "touch \"\$CLAUDE_CONFIG_DIR/.write-test\" && rm \"\$CLAUDE_CONFIG_DIR/.write-test\""
check "managed settings deployed" test -s /etc/claude-code/managed-settings.json
check "managed CLAUDE.md deployed" test -s /etc/claude-code/CLAUDE.md
check "plugin is valid for Claude Code" claude plugin validate /var/lib/claude/devcontainer
check "plugin is loaded through CLAUDE_CODE_PLUGIN_DIRS" bash -c "[ \"\$CLAUDE_CODE_PLUGIN_DIRS\" = /var/lib/claude/devcontainer ]"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
