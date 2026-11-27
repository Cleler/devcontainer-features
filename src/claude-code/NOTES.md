# Using Claude Code in devcontainers

## Requirements

This feature requires Node.js and npm. They are installed by the `node` feature of this repository, declared in
`dependsOn`: there is nothing to add. To choose the Node.js version, declare the `node` feature yourself in
your `devcontainer.json`:

```json
"features": {
    "ghcr.io/Cleler/devcontainer-features/node:1": { "version": "22" },
    "ghcr.io/Cleler/devcontainer-features/claude-code:1": {}
}
```

## How it works

The script checks that `node` and `npm` are there, then installs `@anthropic-ai/claude-code` globally with npm.

It is a copy of the official [`claude-code`](https://github.com/anthropics/devcontainer-features/tree/main/src/claude-code)
feature with two changes: it depends on the [`node`](../node) feature of this repository (`dependsOn`) instead of
ordering itself after the official one (`installsAfter`), and it no longer installs Node.js itself (the apt, apk, dnf
and yum code of the official `install.sh` is removed: `node` handles those distributions).

Why: the official feature only runs after the official `node` feature. With another `node` feature, nothing orders
the installation, and `claude-code` can run before Node.js is there (its own best-effort installation of Node.js
fails on recent Ubuntu). Here `node` is always installed first.

## Changelog

| Version | Notes |
| ------- | ----- |
| 1.1.0 | Add docker-outside-of-docker, and bump the other features to 1.1.0 |
| 1.0.0 | Initial version |

## Source

This feature is taken from [anthropics/devcontainer-features](https://github.com/anthropics/devcontainer-features/tree/main/src/claude-code).
