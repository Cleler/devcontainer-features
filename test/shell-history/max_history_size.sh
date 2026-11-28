#!/bin/bash

# Scenario 'max_history_size': the option maxHistorySize is applied.

set -e

source dev-container-features-test-lib

check "HISTSIZE follows the option" bash -ic '[ "$HISTSIZE" = 500 ]'
check "HISTFILESIZE follows the option" bash -ic '[ "$HISTFILESIZE" = 500 ]'

reportResults
