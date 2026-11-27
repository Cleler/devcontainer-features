
# Claude Code CLI (claude-code)

Installs the Claude Code CLI globally, after the node feature of this repository (works on Alpine too)

## Example Usage

```json
"features": {
    "ghcr.io/Cleler/devcontainer-features/claude-code:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


## Customizations

### VS Code Extensions

- `anthropic.claude-code`

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
| 1.0.0 | Initial version |

## Source

This feature is taken from [anthropics/devcontainer-features](https://github.com/anthropics/devcontainer-features/tree/main/src/claude-code).


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/Cleler/devcontainer-features/blob/main/src/claude-code/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
