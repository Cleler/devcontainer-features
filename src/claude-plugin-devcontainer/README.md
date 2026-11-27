
# Claude Code plugin for devcontainers (claude-plugin-devcontainer)

A Claude Code plugin ('devcontainer') with the skills and agents for working in a devcontainer

## Example Usage

```json
"features": {
    "ghcr.io/Cleler/devcontainer-features/claude-plugin-devcontainer:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|


# Using the devcontainer plugin

## Requirements

This feature only provides configuration for Claude Code: it depends on the
[`claude`](../claude) feature, which provides Claude Code in the container.

## How it works

`plugin/` is packaged as a Claude Code plugin named `devcontainer`, baked in the image in
`/var/lib/claude/devcontainer` and loaded in place through `CLAUDE_CODE_PLUGIN_DIRS`, so nothing is copied in the
user's config.

Its components are namespaced, e.g. `/devcontainer:auto`, so they never collide with the user's own, and they
follow the version of the feature. Run `/devcontainer:guide` for the full user manual.

## What it provides

The plugin lets Claude manage the devcontainer side of a project: the `devcontainer.json` (following the
[specification](https://containers.dev/implementors/json_reference/)), the Dockerfile, Docker Compose services and
Features, and their upkeep over time.

### Two ways to use it

- **Autopilot**: give a few instructions (or none) and the plugin does the rest: it inspects the project, plans,
  writes, validates and has the result reviewed. It only asks when something blocking can't be deduced from the
  project, and lists the assumptions it made at the end.
- **Step by step**: describe exactly what you want. The plugin asks one decision at a time (shape, image, runtimes,
  features, services, ports, commands, editor, user, secrets...), with a recommendation each time, then summarizes and
  waits for your approval before writing anything.

### Workflows

| Command | Use |
|-----|-----|
| `/devcontainer:auto [instructions]` | Autopilot: creates a devcontainer from the project's files and a few instructions. |
| `/devcontainer:guided [topic]` | Step-by-step interview, then the same build, validation and review pipeline. |
| `/devcontainer:update [change]` | Changes an existing devcontainer (`add Redis`, `Node 22`...) or, with no argument, audits it and proposes updates. |
| `/devcontainer:fix [error or log]` | Diagnoses and fixes a container that doesn't build, doesn't start or misbehaves. |
| `/devcontainer:status` | Where the devcontainer stands: the real container, the configuration and the project, and the gaps between them (rebuild needed, drift). Read-only. |
| `/devcontainer:validate` | Static checks (JSONC syntax, consistency, Dockerfile, Compose) without rebuilding. |
| `/devcontainer:guide` | User manual, also read by Claude to route a request to the right workflow. |

Asking in plain language works too: the matching workflow is started.

### Reference skills

`/devcontainer:config` (properties, lifecycle order, variables), `/devcontainer:dockerfile`, `/devcontainer:compose`
and `/devcontainer:features`. The workflows and the agents rely on them.

### The team

| Agent | Role | Writes files |
|-----|-----|-----|
| `devcontainer:scout` | Inspects the project and returns its profile (stack, versions, services, ports, existing setup). | no |
| `devcontainer:planner` | Turns the profile and the requirements into a plan (shape, image, features, files, risks, open questions). | no |
| `devcontainer:builder` | Creates or changes the files from the plan. | **yes** |
| `devcontainer:reviewer` | Read-only review against the specification and good practices. | no |
| `devcontainer:troubleshooter` | Diagnoses a failure from an error or a log and proposes a fix. | no |
| `devcontainer:maintainer` | Audits an existing devcontainer for drift with the project and outdated pins. | no |

Pipelines: creation `scout → planner → builder → validate → reviewer` (one correction loop when the reviewer finds
defects, then a second pass limited to the fixed points); update `scout + maintainer → planner → builder → validate → reviewer`; repair
`troubleshooter → builder → validate → reviewer`. Questions to the user are asked by the workflows, from the main
session, because agents can't ask any.

### Cost

Each agent works in its own context, so a full pipeline starts 3 to 4 agents. To keep it cheap:

- the agents run on economical models (`haiku` for the scout, `sonnet` for the others) with `maxTurns` caps, and only
  load the reference skills they need;
- a small, precise change (`/devcontainer:update "add Redis"`) takes a short path with a single agent;
- `/devcontainer:status` and `/devcontainer:validate` don't rewrite anything;
- the permanent footprint is the descriptions of the skills and agents (about 900 tokens) plus the managed `CLAUDE.md`.

Claude usually runs *inside* the container, so it can't rebuild it: after a change, the container has to be rebuilt from
the host (VS Code: *Dev Containers: Rebuild Container*, or `devcontainer up --workspace-folder . --remove-existing-container`).
The workflows say so, never write secrets in `.devcontainer/` and never run git operations.

## Changelog

| Version | Notes |
| ------- | ----- |
| 1.1.0 | Add docker-outside-of-docker, and bump the other features to 1.1.0 |
| 1.0.1 | No functional change (the keys of `devcontainer-feature.json` are ordered like the generator's) |
| 1.0.0 | Initial version |


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/Cleler/devcontainer-features/blob/main/src/claude-plugin-devcontainer/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
