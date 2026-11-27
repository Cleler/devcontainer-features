#!/bin/bash
# Plans the versions of the features, from the git tags (feature_<id>_<version>, created at each release).
# Stateless: it only compares the working tree with the tag of the version currently in devcontainer-feature.json.
#
# For each feature of src/, prints (one JSON object per line):
#   - action "release":   the current version has no tag yet (new feature, or version bumped by hand): it has to be
#                         published as is.
#   - action "bump":      the current version is released, and src/<id>/ changed since its tag (README.md and NOTES.md
#                         excluded): the patch version has to be incremented, then released.
#   - action "changelog": nothing to publish, but the Changelog table of NOTES.md has no line for the current version.
# "changelog": true on every line whose version needs its line in the Changelog table (a "bump", a "release" or a
# "changelog" action whose feature has an earlier tag to list the changes from); bump.sh adds it.
# Nothing is printed for a feature that is up to date.
#
# usage: plan.sh [src-dir]   (run from the root of the repository, with the tags fetched)
set -euo pipefail

src="${1:-src}"

# The tag of the version that comes just before $2 among the tags of the feature $1 ("" if none)
tag_before() {
    git tag -l "feature_${1}_*" | sed "s/^feature_${1}_//" | sort -V | awk -v v="$2" '$0 == v {exit} {p = $0} END {print p}' | sed "s/^./feature_${1}_&/"
}

for dir in "${src}"/*/; do
    id="$(basename "${dir}")"
    json="${dir}devcontainer-feature.json"
    [ -f "${json}" ] || continue
    version="$(jq -r .version "${json}")"
    tag="feature_${id}_${version}"
    has_row=true
    grep -q "^| ${version//./\\.} |" "${dir}NOTES.md" 2> /dev/null || has_row=false

    if ! git rev-parse -q --verify "refs/tags/${tag}" > /dev/null; then
        # The tag of the previous version: the latest one of the feature
        previous="$(git tag -l "feature_${id}_*" | sort -V | tail -n 1)"
        changelog=false
        if [ -n "${previous}" ] && [ "${has_row}" = false ]; then
            changelog=true
        fi
        jq -cn --arg id "${id}" --arg version "${version}" --arg previous "${previous}" --argjson changelog "${changelog}" \
            '{id: $id, action: "release", version: $version, new_version: $version,
              previous_version: (if $previous == "" then null else ($previous | sub("^feature_.*_"; "")) end),
              base_tag: (if $previous == "" then null else $previous end), changelog: $changelog}'
        continue
    fi

    changed="$(git diff --name-only "${tag}" HEAD -- "${dir}" ":!${dir}README.md" ":!${dir}NOTES.md")"
    if [ -n "${changed}" ]; then
        new_version="$(echo "${version}" | awk -F. -v OFS=. '{$NF = $NF + 1; print}')"
        jq -cn --arg id "${id}" --arg version "${version}" --arg new_version "${new_version}" --arg base_tag "${tag}" \
            '{id: $id, action: "bump", version: $version, new_version: $new_version, previous_version: $version,
              base_tag: $base_tag, changelog: true}'
    elif [ "${has_row}" = false ]; then
        previous="$(tag_before "${id}" "${version}")"
        if [ -n "${previous}" ]; then
            jq -cn --arg id "${id}" --arg version "${version}" --arg previous "${previous}" \
                '{id: $id, action: "changelog", version: $version, new_version: $version,
                  previous_version: ($previous | sub("^feature_.*_"; "")), base_tag: $previous, changelog: true}'
        fi
    fi
done
