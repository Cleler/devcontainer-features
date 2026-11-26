#!/bin/sh
set -e

echo "Activating feature 'claude'"

# The option ids are exposed as upper-case environment variables.
MANAGED_CLAUDE_MD=${MANAGED_CLAUDE_MD:-true}
MANAGED_SETTINGS_JSON=${MANAGED_SETTINGS_JSON:-true}
echo "The provided managed-claude-md is: $MANAGED_CLAUDE_MD"
echo "The provided managed-settings-json is: $MANAGED_SETTINGS_JSON"

# The 'install.sh' entrypoint script is always executed as the root user.
#
# These following environment variables are passed in by the dev container CLI.
# These may be useful in instances where the context of the final
# remoteUser or containerUser is useful.
# For more details, see https://containers.dev/implementors/features#user-env-var
echo "The effective dev container remoteUser is '$_REMOTE_USER'"
echo "The effective dev container remoteUser's home directory is '$_REMOTE_USER_HOME'"

echo "The effective dev container containerUser is '$_CONTAINER_USER'"
echo "The effective dev container containerUser's home directory is '$_CONTAINER_USER_HOME'"

# Claude Code itself comes from the 'claude-code' feature declared in 'dependsOn',
# and the shared config dir is a bind mount (see devcontainer-feature.json).
#
# Settings and CLAUDE.md: deployed at Claude Code's managed level.
FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"
MANAGED_SRC="$FEATURE_DIR/managed"
MANAGED_DIR=/etc/claude-code

install -d -m 755 "$MANAGED_DIR"
if [ "$MANAGED_SETTINGS_JSON" = "true" ] && [ -f "$MANAGED_SRC/settings.json" ]; then
    install -m 644 "$MANAGED_SRC/settings.json" "$MANAGED_DIR/managed-settings.json"
fi
if [ "$MANAGED_CLAUDE_MD" = "true" ] && [ -f "$MANAGED_SRC/CLAUDE.md" ]; then
    install -m 644 "$MANAGED_SRC/CLAUDE.md" "$MANAGED_DIR/CLAUDE.md"
fi
