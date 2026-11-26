---
name: status
description: "Read-only status check: actual container, configuration, project and gaps (rebuild needed, drift)."
---
# Devcontainer status

This skill **modifies nothing**. It compares three things and concludes with what should be done.

## 1. Observe

Launch the `devcontainer:scout` agent: it returns the project profile (what the project uses) and the summary of
`.devcontainer/` (what the configuration declares). Meanwhile, gather the **actual** state of the container yourself
(read-only commands):

- `cat /etc/os-release`, `uname -m`, `whoami`, `id`
- versions of the tools that the configuration or the project mention (`node -v`, `python3 --version`, `go version`,
  `java -version`, `docker --version`...), the absence of a tool is information
- `ls /workspaces`, `mount | grep -E 'workspaces|\.claude'`
- `env | sort`: use only the variable **names** in your report, never the values

Outside a container (no `/.dockerenv`, no `/workspaces`), say so: only the configuration and the project can be
compared.

## 2. Present

Three short blocks, then the gaps:

```
CONTAINER (actual)    : OS, architecture, user, tools + versions, mounts
CONFIGURATION         : shape (image / Dockerfile / compose), image, features, ports, lifecycle commands
PROJECT               : runtimes and versions, services, ports, install command (with their source)

GAPS
- <tool> : container <x> ≠ configuration <y>      → rebuild probably needed
- <runtime> : configuration <x> ≠ project <y>     → configuration needs updating
- <service / port> : used by the project, absent from the configuration
```

A "container ≠ configuration" gap usually means the configuration has changed since the last build.
A "configuration ≠ project" gap means the project has evolved without the devcontainer keeping up.

## 3. Conclude

End with a single, concrete recommendation: everything is consistent; **rebuild** needed (VS Code: "Dev
Containers: Rebuild Container"; CLI: `devcontainer up --workspace-folder . --remove-existing-container`);
`/devcontainer:update` to catch up on drift; `/devcontainer:fix` if a symptom is already known;
`/devcontainer:auto` or `/devcontainer:guided` if there is no `.devcontainer/` yet.
