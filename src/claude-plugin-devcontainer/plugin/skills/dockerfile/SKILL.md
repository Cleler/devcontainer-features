---
name: dockerfile
description: "Rules for a devcontainer Dockerfile (base image, non-root, system packages, `build`)."
---
# Dockerfile for devcontainers

A devcontainer Dockerfile **sets up a development environment**, not an application image: it does not bundle
the project code (the repository is mounted in `/workspaces/...`), needs neither `CMD` nor `ENTRYPOINT` (the tool
keeps the container alive with `overrideCommand`) and does not copy the sources.

## When to have one

Only if a feature is not enough: system packages (`apt`), tools without a feature, OS settings. Otherwise stay on
`image` + `features`.

## Wiring in `devcontainer.json`

```jsonc
{
  "name": "my-project",
  // no "image" here
  "build": {
    "dockerfile": "Dockerfile",       // relative to devcontainer.json
    "context": "..",                  // only if the Dockerfile needs files from the repository root
    "args": { "VARIANT": "bookworm" } // → ARG VARIANT in the Dockerfile
  }
}
```

Common pitfalls: leaving `image` next to `build`; putting `workspaceFolder` outside the mounted workspace;
forgetting that `build.dockerfile` and `build.context` are relative to `devcontainer.json`, not to the repository root.

## Rules

- `FROM` a devcontainer image when possible: `mcr.microsoft.com/devcontainers/base:ubuntu` (or `:debian`),
  or a language image `mcr.microsoft.com/devcontainers/<language>:<tag>`. They provide a non-root user
  (`vscode`, UID 1000), `sudo`, git and a comfortable shell. Pin the tag.
- Third-party base image (`ubuntu`, `node`, `python`...): create the user with the feature
  `ghcr.io/devcontainers/features/common-utils:2` rather than by hand, then `remoteUser` if needed.
- Don't end with `USER root`: the development container runs as non-root.
- System packages, in a **single** layer and without cache:

```dockerfile
FROM mcr.microsoft.com/devcontainers/base:ubuntu
RUN apt-get update \
 && export DEBIAN_FRONTEND=noninteractive \
 && apt-get install -y --no-install-recommends libpq-dev \
 && rm -rf /var/lib/apt/lists/*
```

- Common runtimes and tools (node, python, go, java, docker, gh...): **features**, not `RUN`.
- Anything that depends on the project code (installing dependencies): `postCreateCommand`, not the Dockerfile.
- Variants: `ARG` + `build.args`; multiple stages: `build.target`.
- Prebuilt, shared image: `build.cacheFrom`, or publish the image with the `devcontainer.metadata` metadata.
- Add a `.dockerignore` if `build.context` is the repository root.
- Optional linter: `hadolint .devcontainer/Dockerfile` if installed.
