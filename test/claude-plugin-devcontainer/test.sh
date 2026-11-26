#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'claude-plugin-devcontainer' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# These scripts are run as 'root' by default. Although that can be changed
# with the '--remote-user' flag.
#
# This test can be run with the following command:
#
#    devcontainer features test                  \
#               --features claude-plugin-devcontainer \
#               --remote-user root               \
#               --skip-scenarios                 \
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

check "plugin manifest installed" grep -q '"name": "devcontainer"' /var/lib/claude/devcontainer/.claude-plugin/plugin.json
check "plugin ships the skills" bash -c "for s in guide auto guided update fix status validate config dockerfile compose features; do grep -q \"^name: \$s\\$\" /var/lib/claude/devcontainer/skills/\$s/SKILL.md || exit 1; done"
check "plugin ships the agents" bash -c "for a in scout planner builder reviewer troubleshooter maintainer; do grep -q \"^name: \$a\\$\" /var/lib/claude/devcontainer/agents/\$a.md || exit 1; done"
check "agents are capped (model and turns)" bash -c "cd /var/lib/claude/devcontainer/agents && for a in *.md; do grep -q '^model: ' \$a && grep -q '^maxTurns: ' \$a || exit 1; done"
check "only the builder can write" bash -c "cd /var/lib/claude/devcontainer/agents && [ \"\$(grep -l '^tools:.*\\(Write\\|Edit\\)' *.md)\" = builder.md ]"
check "plugin is valid for Claude Code" claude plugin validate /var/lib/claude/devcontainer
check "plugin is loaded through CLAUDE_CODE_PLUGIN_DIRS" bash -c "[ \"\$CLAUDE_CODE_PLUGIN_DIRS\" = /var/lib/claude/devcontainer ]"

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
