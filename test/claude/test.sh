#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'claude' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# Eg:
# {
#    "image": "<..some-base-image...>",
#    "features": {
#      "claude": {}
#    },
#    "remoteUser": "root"
# }
#
# These scripts are run as 'root' by default. Although that can be changed
# with the '--remote-user' flag.
#
# This test can be run with the following command:
#
#    devcontainer features test    \
#               --features claude  \
#               --remote-user root \
#               --skip-scenarios   \
#               --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#               /path/to/this/repo

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]
check "claude cli installed" bash -c "command -v claude"
check "CLAUDE_CONFIG_DIR is set" bash -c "[ \"\$CLAUDE_CONFIG_DIR\" = /home/vscode/.claude ]"
check "config dir is writable" bash -c "touch \"\$CLAUDE_CONFIG_DIR/.write-test\" && rm \"\$CLAUDE_CONFIG_DIR/.write-test\""
check "auto-update is disabled" bash -c "[ \"\$DISABLE_AUTOUPDATER\" = 1 ]"

# Settings and CLAUDE.md, at Claude Code's managed level
check "managed settings carries the default settings" grep -q '"allow"' /etc/claude-code/managed-settings.json
check "managed settings does not restrict anything" bash -c "! grep -q '\"deny\"' /etc/claude-code/managed-settings.json"
check "managed CLAUDE.md installed" test -s /etc/claude-code/CLAUDE.md

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
