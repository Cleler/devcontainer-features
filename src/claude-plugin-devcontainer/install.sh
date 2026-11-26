#!/bin/sh
set -e

echo "Activating feature 'claude-plugin-devcontainer'"

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

FEATURE_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_SRC="$FEATURE_DIR/plugin"
PLUGIN_DIR=/var/lib/claude/devcontainer

# Skills and agents: a plugin named 'devcontainer', loaded
# in place from PLUGIN_DIR through CLAUDE_CODE_PLUGIN_DIRS (see devcontainer-feature.json).
rm -rf "$PLUGIN_DIR"
install -d -m 755 "$PLUGIN_DIR/.claude-plugin"
cat > "$PLUGIN_DIR/.claude-plugin/plugin.json" \
<< EOF2
{
    "name": "devcontainer",
    "description": "Base configuration of the 'claude-plugin-devcontainer' devcontainer feature"
}
EOF2

for d in agents skills; do
    [ -d "$PLUGIN_SRC/$d" ] && cp -R "$PLUGIN_SRC/$d" "$PLUGIN_DIR/$d"
done

chmod -R a+rX "$PLUGIN_DIR"
