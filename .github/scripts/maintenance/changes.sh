#!/bin/bash
# Prints the subjects of the commits that touch src/<id>/ (README.md and NOTES.md excluded) since the previous tag
# of the feature, one per line. The merge commits ("Merge pull request #n ...") and the commits of the
# 'Automated maintenance' workflow are left out: they say nothing about the feature.
#
# usage: changes.sh <id> [previous-tag]   (no previous tag: every commit of the feature)
set -euo pipefail

id="$1"
previous_tag="${2:-}"
src="src/${id}"
range="HEAD"
[ -z "${previous_tag}" ] || range="${previous_tag}..HEAD"

git log --no-merges --invert-grep --grep='^Automated maintenance' --format='%s' "${range}" -- "${src}" ":!${src}/README.md" ":!${src}/NOTES.md"
