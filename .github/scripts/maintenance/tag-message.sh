#!/bin/bash
# Prints the message of the tag of a feature:
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

here="$(dirname "${BASH_SOURCE[0]}")"
id="$1"
version="$2"
previous_tag="${3:-}"
docs_changed="${4:-false}"

echo "feature_${id}_${version}"
if [ -n "${previous_tag}" ]; then
    echo "Version change: ${previous_tag#feature_"${id}"_} -> ${version}"
else
    echo "First version: ${version}"
fi
echo "Changes:"
"${here}/changes.sh" "${id}" "${previous_tag}" | sed 's/^/- /'
if [ "${docs_changed}" = "true" ]; then
    echo "Documentation: updated"
fi
