#!/bin/bash
# Plans the versions of the features, from the git tags (feature_<id>_<version>, created at each release).
# Stateless: it only compares the working tree with the tag of the version currently in devcontainer-feature.json.
#
# For each feature of src/, prints (one JSON object per line):
#   - action "release": the current version has no tag yet (new feature, or version bumped by hand): it has to be published as is.
#   - action "bump":    the current version is released, and src/<id>/ changed since its tag (README.md and NOTES.md
#                       excluded): the patch version has to be incremented, then released.
# Nothing is printed for a feature that is up to date.
#
# usage: plan.sh [src-dir]   (run from the root of the repository, with the tags fetched)
set -euo pipefail

src="${1:-src}"

for dir in "${src}"/*/; do
    id="$(basename "${dir}")"
    json="${dir}devcontainer-feature.json"
    [ -f "${json}" ] || continue
    version="$(jq -r .version "${json}")"
    tag="feature_${id}_${version}"

    if ! git rev-parse -q --verify "refs/tags/${tag}" > /dev/null; then
        jq -cn --arg id "${id}" --arg version "${version}" \
            '{id: $id, action: "release", version: $version, new_version: $version, base_tag: null}'
        continue
    fi

    changed="$(git diff --name-only "${tag}" HEAD -- "${dir}" ":!${dir}README.md" ":!${dir}NOTES.md")"
    if [ -n "${changed}" ]; then
        new_version="$(echo "${version}" | awk -F. -v OFS=. '{$NF = $NF + 1; print}')"
        jq -cn --arg id "${id}" --arg version "${version}" --arg new_version "${new_version}" --arg base_tag "${tag}" \
            '{id: $id, action: "bump", version: $version, new_version: $new_version, base_tag: $base_tag}'
    fi
done
