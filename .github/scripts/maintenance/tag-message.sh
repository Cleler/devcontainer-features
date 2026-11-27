#!/bin/bash
# Prints the message of the tag (and so the part of the release notes) of a feature:
#
#   feature_node_1.0.2
#   Version change: 1.0.1 -> 1.0.2
#   Changes:
#   - <subjects of the commits touching src/node since the previous tag>
#   Documentation: updated
#
# usage: tag-message.sh <id> <version> <previous-tag|""> [docs-changed: true|false]
#   previous-tag: the tag of the previous version ("" for a first version: all the commits of the feature)
set -euo pipefail

id="$1"
version="$2"
previous_tag="${3:-}"
docs_changed="${4:-false}"
src="src/${id}"

echo "feature_${id}_${version}"
if [ -n "${previous_tag}" ]; then
    echo "Version change: ${previous_tag#feature_"${id}"_} -> ${version}"
    range="${previous_tag}..HEAD"
else
    echo "First version: ${version}"
    range="HEAD"
fi
echo "Changes:"
# Merge commits only say "Merge pull request #n": leave them out
git log --no-merges --format='- %s' "${range}" -- "${src}" ":!${src}/README.md" ":!${src}/NOTES.md"
if [ "${docs_changed}" = "true" ]; then
    echo "Documentation: updated"
fi
