#!/bin/bash
# Exit code 0 if the README of a feature changed since a tag, ignoring its Changelog section (every release adds a
# line there: it is not a change of the documentation).
#
# usage: docs-changed.sh <id> <tag>
set -euo pipefail

id="$1"
tag="$2"
readme="src/${id}/README.md"

# The README without its "## Changelog" section (up to the next "## " title or the final "---")
strip() {
    awk '/^## Changelog/ {skip = 1; next} skip && (/^## / || /^---$/) {skip = 0} !skip' 
}

if ! git cat-file -e "${tag}:${readme}" 2>/dev/null; then
    exit 0
fi
! diff -q <(git show "${tag}:${readme}" | strip) <(strip < "${readme}") > /dev/null
