---
name: config
description: "Reference for `devcontainer.json`: properties, lifecycle, variables, pitfalls. Load when writing or editing this file."
---
# `devcontainer.json`: writing good JSONC

File: `.devcontainer/devcontainer.json` (or `.devcontainer.json` at the root, or
`.devcontainer/<folder>/devcontainer.json` for several configurations). `//` and `/* */` comments are
allowed (JSONC). Reference schema: `https://raw.githubusercontent.com/devcontainers/spec/main/schemas/devContainer.base.schema.json`.

## Pick a single "scenario"

| Scenario | Required properties |
|---|---|
| Image | `image` |
| Dockerfile | `build.dockerfile` (path relative to `devcontainer.json`), and **no** `image` |
| Docker Compose | `dockerComposeFile`, `service` (and `workspaceFolder`) |

## Common properties

- **Identity**: `name`.
- **Environment**: `containerEnv` (set at the container level, changes after a rebuild); `remoteEnv` (tools and
  tool processes, can be changed without a rebuild, the only place where `${containerEnv:VAR}` is allowed).
- **Users**: `remoteUser` (user for tools), `containerUser` (whole container),
  `updateRemoteUserUID` (Linux: aligns the UID/GID with the host, `true` by default).
- **Ports**: `forwardPorts` (preferred over `appPort`), `portsAttributes` (`label`, `onAutoForward`, `protocol`...),
  `otherPortsAttributes`. In Compose, `"service:port"` for another service.
- **Features**: `features` (`"<id>": { options }`), `overrideFeatureInstallOrder`.
- **Docker**: `mounts` (`--mount` syntax, object or string), `runArgs` (array only), `init`, `privileged`,
  `capAdd`, `securityOpt`, `overrideCommand` (true by default for image/Dockerfile, false for Compose),
  `shutdownAction`, `hostRequirements` (`cpus`, `memory`, `storage`, `gpu`).
- **Folders**: `workspaceFolder` and `workspaceMount` go together; `workspaceFolder` must stay inside the mounted
  folder.
- **Tools**: `customizations.vscode.extensions` / `.settings`, `customizations.codespaces`...

## Lifecycle (execution order)

1. `initializeCommand`: on the **host**, at creation and at every start.
2. `onCreateCommand`: in the container, on first start (usable for prebuilds, so no secrets).
3. `updateContentCommand`: when the repository content has changed (at least once; prebuild target).
4. `postCreateCommand`: once, when the container is assigned to a user. **Good place to install the project's
   dependencies.**
5. `postStartCommand`: at every start.
6. `postAttachCommand`: every time a tool attaches.

`waitFor` (default `updateContentCommand`) tells which step the tools wait for. If a step fails, the following
ones are skipped. A command can be a string, an array (no shell) or an object (commands run in parallel).

## Variables

`${localEnv:VAR[:default]}` (host), `${containerEnv:VAR[:default]}` (`remoteEnv` only),
`${localWorkspaceFolder}`, `${localWorkspaceFolderBasename}`, `${containerWorkspaceFolder}`,
`${containerWorkspaceFolderBasename}`, `${devcontainerId}` (stable identifier, limited to certain properties:
`name`, `runArgs`, lifecycle commands, `workspaceFolder`, `workspaceMount`, `mounts`, `containerEnv`,
`remoteEnv`, `containerUser`, `remoteUser`, `customizations`).

## Quality rules

- Minimal: every property answers a real need of the project; don't write default values.
- Reproducible: install from lockfiles, pin runtime versions (the `version` option of features or the image tag)
  to what the project already uses.
- No secrets in the file: `${localEnv:...}` or a git-ignored `.env`.
- Prefer a feature over a `RUN apt-get` when a feature exists; prefer `postCreateCommand` over a build step
  for anything that depends on the project code (the repository is not in the image).
- Services (DB, cache) go in a Compose file, not in `postStartCommand`.
- A change to `devcontainer.json`, a Dockerfile or a feature only takes effect after a **rebuild**.
