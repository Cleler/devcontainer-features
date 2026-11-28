#!/bin/bash

# Scenario 'alpine': the feature on the Alpine Dev Containers base image.

set -e

source dev-container-features-test-lib

check "alpine" test -f /etc/alpine-release
check "history volume is writable" bash -c "touch /mnt/shell-history/.write-test && rm /mnt/shell-history/.write-test"
check "bash history is written to the volume" bash -ic 'history -s shell_history_marker; history -a; grep -q shell_history_marker /mnt/shell-history/.bash_history'

reportResults
