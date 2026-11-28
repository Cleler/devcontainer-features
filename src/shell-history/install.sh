#!/bin/bash
#
# Installs the script that, once the container is created, points the shells at the history volume.
# The volume itself is only there at runtime (see "mounts" in devcontainer-feature.json), so everything that
# touches it is done by setup-volume.sh, run as the remote user by the postCreateCommand.

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

SHARE_DIR=/usr/local/share/shell-history
MAX_HISTORY_SIZE="${MAXHISTORYSIZE:-10000}"

case "${MAX_HISTORY_SIZE}" in
    ''|*[!0-9]*)
        echo "Invalid maxHistorySize '${MAX_HISTORY_SIZE}': a number is expected."
        exit 1
        ;;
esac

echo "Activating feature 'shell-history'"

mkdir -p "${SHARE_DIR}"
cp "$(dirname "${BASH_SOURCE[0]}")/setup-volume.sh" "${SHARE_DIR}/setup-volume.sh"
chmod 755 "${SHARE_DIR}/setup-volume.sh"
echo "${MAX_HISTORY_SIZE}" > "${SHARE_DIR}/max-history-size"

echo "Done!"
