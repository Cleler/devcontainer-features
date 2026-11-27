#!/bin/bash
# Applies the "bump" lines of a plan (output of plan.sh, on stdin): writes the new version in
# src/<id>/devcontainer-feature.json, leaving the rest of the file untouched.
#
# usage: plan.sh | bump.sh [src-dir]
set -euo pipefail

src="${1:-src}"

while read -r line; do
    [ "$(jq -r .action <<< "${line}")" = "bump" ] || continue
    id="$(jq -r .id <<< "${line}")"
    version="$(jq -r .version <<< "${line}")"
    new_version="$(jq -r .new_version <<< "${line}")"
    json="${src}/${id}/devcontainer-feature.json"
    sed -i "s/^\(\s*\"version\":\s*\)\"${version}\"/\1\"${new_version}\"/" "${json}"
    [ "$(jq -r .version "${json}")" = "${new_version}" ] || { echo "Failed to bump ${id}" >&2; exit 1; }
    echo "${id}: ${version} -> ${new_version}"
done
