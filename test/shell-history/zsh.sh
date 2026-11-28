#!/bin/bash

# Scenario 'zsh': zsh is the default shell. Its history goes to the volume too.

set -e

source dev-container-features-test-lib

check "zsh keeps its history in the volume" zsh -ic 'case "$HISTFILE" in /mnt/shell-history/*) exit 0 ;; *) exit 1 ;; esac'
check "zsh history is written to the volume" zsh -ic 'print -s shell_history_marker; fc -AI; grep -q shell_history_marker /mnt/shell-history/.zsh_history'
check "bash still works" bash -ic 'case "$HISTFILE" in /mnt/shell-history/*) exit 0 ;; *) exit 1 ;; esac'

reportResults
