#!/bin/bash

# Scenario 'root_user': the remote user is root (no sudo needed to own the volume).

set -e

source dev-container-features-test-lib

check "the user is root" bash -c '[ "$(id -u)" = 0 ]'
check "bash keeps its history in the volume" bash -ic 'case "$HISTFILE" in /mnt/shell-history/*) exit 0 ;; *) exit 1 ;; esac'
check "bash history is written to the volume" bash -ic 'history -s shell_history_marker; history -a; grep -q shell_history_marker /mnt/shell-history/.bash_history'

reportResults
