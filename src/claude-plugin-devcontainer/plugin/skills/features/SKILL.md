---
name: features
description: "Choose, configure and order Dev Container Features; when to prefer them over a Dockerfile."
---
# Dev Container Features

A feature is a reusable installation module (`install.sh` + options) referenced in `features`:

```jsonc
"features": {
  "ghcr.io/devcontainers/features/node:1": { "version": "20" },
  "ghcr.io/devcontainers/features/github-cli:1": {},
  "./local-feature": {}            // local feature: folder relative to .devcontainer/
}
```

Identifier: `<registry>/<namespace>/<feature>:<major>`; pin the **major** version (`:1`). Options are
described in each feature's README; default values apply if you omit them.

## Common features (`ghcr.io/devcontainers/features/…`)

`common-utils` (non-root user, zsh, basic tools), `git`, `git-lfs`, `github-cli`, `node`, `python`, `go`,
`rust`, `java`, `dotnet`, `ruby`, `php`, `docker-in-docker`, `docker-outside-of-docker`, `sshd`, `terraform`,
`aws-cli`, `azure-cli`, `kubectl-helm-minikube`. Full catalog: https://containers.dev/features.
Check that a feature exists before using it.

## Choosing

- Need a standard runtime or tool → **feature** (fast, maintained, version options).
- Specific system package → `RUN apt-get` in a Dockerfile (skill `dockerfile`).
- Installation that depends on the project code → `postCreateCommand`.
- Docker inside the container: `docker-in-docker` (isolated daemon, requires `privileged`) or `docker-outside-of-docker`
  (uses the host daemon: mounted paths are the host's). Only add them if the project builds or
  runs containers.

## Order and dependencies

The installation order is computed automatically (`installsAfter`, `dependsOn` in the feature). Only force it with
`overrideFeatureInstallOrder` (list of identifiers without version) in case of a real conflict.

## Writing a feature

A folder with `devcontainer-feature.json` (`id`, `version`, `options`, `dependsOn`, `mounts`, `containerEnv`,
lifecycle commands...) and `install.sh` (run as root at build time, options passed as uppercase environment
variables). The features in this repository (`claude`, `claude-plugin-devcontainer`) serve as examples.
