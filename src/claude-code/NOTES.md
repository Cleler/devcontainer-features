# Using Claude Code in devcontainers

This feature is a copy of the official
[`claude-code`](https://github.com/anthropics/devcontainer-features/tree/main/src/claude-code) feature
with one change: it depends on the [`node`](../node) feature of this repository (`dependsOn`) instead of
ordering itself after the official one (`installsAfter`).

Why: the official feature only runs after the official `node` feature, which doesn't support Alpine.
With a different `node` feature, nothing orders the installation, and `claude-code` can run before Node.js
is there (and its own best-effort Node.js installation fails on recent Ubuntu).
Here `node` is always installed first, on Debian, Ubuntu and Alpine.

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

The Node.js installation script of the official feature is still in `install.sh`, but it only runs
if `node` or `npm` is missing, which doesn't happen with the dependency above.
