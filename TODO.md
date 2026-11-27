# TODO

## Keep `node`, `claude-code` and `docker-outside-of-docker` up to date with their source of truth

`src/node`, `src/claude-code` and `src/docker-outside-of-docker` are copies of the official features
([devcontainers/features](https://github.com/devcontainers/features), [anthropics/devcontainer-features](https://github.com/anthropics/devcontainer-features))
with the Alpine (apk) support added on top (`claude-code`: a `dependsOn` on our `node` instead of the Node.js installation).
Nothing tells us when upstream changes, so the copies will drift.

Develop something to keep them up to date with their Alpine fix, from upstream:

- detect a new upstream version of each feature,
- re-apply our Alpine changes on top of it (e.g. one patch per file: `install.sh`, `devcontainer-feature.json`, `NOTES.md`; the README stays generated),
- open a PR automatically, with the tests (and then the release) running on it,
- report clearly when the patches no longer apply.
