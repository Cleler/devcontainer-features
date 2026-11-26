---
name: validate
description: "Statically checks `.devcontainer/` (JSONC syntax, consistency, Dockerfile, Compose) without a rebuild."
---
# Validate a devcontainer

You are probably **inside** the container: you can neither rebuild nor restart it. So check what can be
checked statically, then say what can only be checked at rebuild.

## 1. Syntax

- `devcontainer.json` is JSONC. If the `devcontainer` CLI is installed:
  `devcontainer read-configuration --workspace-folder .` (prints the merged configuration, features and metadata
  included, and fails on a schema or path error).
- Otherwise, strip the comments and parse:
  `node -e "const s=require('fs').readFileSync('.devcontainer/devcontainer.json','utf8').replace(/\\/\\*[\\s\\S]*?\\*\\/|^\\s*\\/\\/.*$/gm,'');JSON.parse(s)"`
  (trailing commas and duplicate keys are errors).

## 2. Consistency (to review in the file)

- A single scenario: `image` **or** `build.dockerfile` **or** `dockerComposeFile` + `service`.
- `workspaceFolder` ⇔ `workspaceMount`; `workspaceFolder` inside the mounted folder.
- Paths relative to `devcontainer.json`: `build.dockerfile`, `build.context`, `dockerComposeFile`.
- `${containerEnv:...}` only in `remoteEnv`; `runArgs` as an array; features as `<id>:<major>`.
- No plaintext secrets; no `appPort` if `forwardPorts` is enough.
- `forwardPorts` match the ports actually listened on (see startup scripts, `.env.example`, compose).
- Lifecycle commands exist and are idempotent (`postCreateCommand` may be re-run).

## 3. Dockerfile and Compose

- `hadolint .devcontainer/Dockerfile` if available.
- `docker compose -f .devcontainer/docker-compose.yml config` if Docker is available.
- Otherwise: pinned `FROM`, a single `apt-get update && install && rm -rf /var/lib/apt/lists/*` layer, no final `USER root`,
  no `COPY` of the project sources.

## 4. Report

List: ✔ what is verified, ✖ what is wrong (with file and line), ⚠ what can only be verified at rebuild.
Remind that changes only apply after "Dev Containers: Rebuild Container" (or
`devcontainer up --workspace-folder . --remove-existing-container` from the host).

For a thorough, independent review, delegate to the `devcontainer:reviewer` agent.
