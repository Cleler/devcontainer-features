#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'shell-history' Feature with no options, on every image of the CI matrix.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# This test can be run with the following command:
#
#    devcontainer features test    \
#               --features shell-history \
#               --remote-user root \
#               --skip-scenarios   \
#               --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#               /path/to/this/repo

set -e

# Optional: Import test library bundled with the devcontainer CLI
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]

# The volume
check "history volume is mounted" test -d /mnt/shell-history
check "history volume is writable" bash -c "touch /mnt/shell-history/.write-test && rm /mnt/shell-history/.write-test"

# bash
check "bash keeps its history in the volume" bash -ic 'case "$HISTFILE" in /mnt/shell-history/*) exit 0 ;; *) exit 1 ;; esac'
check "bash history is written to the volume" bash -ic 'history -s shell_history_marker; history -a; grep -q shell_history_marker /mnt/shell-history/.bash_history'
check "bash history has no limit by default" bash -ic '[ "$HISTSIZE" = -1 ] && [ "$HISTFILESIZE" = -1 ]'
check "the bashrc block is there once" bash -c '[ "$(grep -c ">>> shell-history >>>" "$HOME/.bashrc")" = 1 ]'

# Report result
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults
