#!/bin/bash
# Applies a plan (output of plan.sh, on stdin):
#   - "bump": writes the new version in src/<id>/devcontainer-feature.json (leaving the rest of the file untouched)
#     and adds its line at the top of the Changelog table of src/<id>/NOTES.md (changelog.py);
#   - "release" with "changelog": the version was incremented by hand, only the line of the Changelog table is added.
#
# usage: plan.sh | bump.sh [src-dir]
set -euo pipefail

src="${1:-src}"
here="$(dirname "${BASH_SOURCE[0]}")"

while read -r line; do
    action="$(jq -r .action <<< "${line}")"
    id="$(jq -r .id <<< "${line}")"
    version="$(jq -r .version <<< "${line}")"
    new_version="$(jq -r .new_version <<< "${line}")"
    base_tag="$(jq -r '.base_tag // ""' <<< "${line}")"

    if [ "${action}" = "bump" ]; then
        json="${src}/${id}/devcontainer-feature.json"
        sed -i "s/^\(\s*\"version\":\s*\)\"${version}\"/\1\"${new_version}\"/" "${json}"
        [ "$(jq -r .version "${json}")" = "${new_version}" ] || { echo "Failed to bump ${id}" >&2; exit 1; }
        "${here}/changelog.py" "${id}" "${new_version}" "${base_tag}"
        echo "${id}: ${version} -> ${new_version}"
    elif [ "${action}" = "release" ] && [ "$(jq -r .changelog <<< "${line}")" = "true" ]; then
        "${here}/changelog.py" "${id}" "${new_version}" "${base_tag}"
        echo "${id}: changelog line for ${new_version}"
    fi
done
