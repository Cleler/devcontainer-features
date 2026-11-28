#!/bin/bash

# Scenario 'node_user': an image whose user is 'node'. The history file belongs to that user.

set -e

source dev-container-features-test-lib

check "the user is node" bash -c '[ "$(id -un)" = node ]'
check "the history volume belongs to the user" bash -c '[ "$(stat -c %U /mnt/shell-history)" = node ]'
check "bash history is written to the volume" bash -ic 'history -s shell_history_marker; history -a; grep -q shell_history_marker /mnt/shell-history/.bash_history'

reportResults
