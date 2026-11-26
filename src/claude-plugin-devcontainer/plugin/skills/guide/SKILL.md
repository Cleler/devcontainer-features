---
name: guide
description: "User manual for the devcontainer plugin: auto and step-by-step modes, workflows, agents. Use when asked how to use it."
---
# devcontainer plugin: user manual

The plugin lets Claude **manage the devcontainer side of a project**: a spec-compliant `devcontainer.json`,
a devcontainer-oriented Dockerfile, Docker Compose services, Features, and their maintenance over time.

## Two ways to use it

| | Autopilot | Step by step |
|---|---|---|
| Command | `/devcontainer:auto [instructions]` | `/devcontainer:guided [topic]` |
| For whom | You give a few instructions (or none) and the plugin handles the rest | You want full control and to decide every point |
| Flow | The plugin analyzes the project, plans, writes, verifies and has the result reviewed | The plugin analyzes, then asks you one question per decision, summarizes, waits for your approval, then writes |
| Questions | Only if a blocking point cannot be inferred from the project; everything else is assumed and listed at the end | Every decision, with a recommendation each time (you can answer "choose for me") |
| Result | A reviewed devcontainer, with the list of assumptions made | The exact devcontainer you described |

You can also simply ask in natural language ("create a devcontainer for this project", "I want to
set up my devcontainer step by step"): the matching workflow is launched.

## The workflows

| Command | When |
|---|---|
| `/devcontainer:auto [instructions]` | Create a devcontainer on autopilot |
| `/devcontainer:guided [topic]` | Create or review a devcontainer step by step |
| `/devcontainer:update [change]` | Modify an existing devcontainer ("add Redis", "switch to Node 22"...) or, with no argument, bring it up to date |
| `/devcontainer:fix [error or log]` | Diagnose and fix a container that fails to build, fails to start or misbehaves |
| `/devcontainer:status` | Where the devcontainer stands: actual container, configuration, project, and gaps between the three |
| `/devcontainer:validate` | Statically check the configuration (syntax, consistency), without a rebuild |

## The reference skills (knowledge)

`/devcontainer:config` (properties, lifecycle, variables), `/devcontainer:dockerfile`, `/devcontainer:compose`,
`/devcontainer:features`. The workflows and agents use them; you can also call them to understand a point.

## The team (agents)

| Agent | Role | Writes? |
|---|---|---|
| `devcontainer:scout` | Inspects the project and returns its profile (stack, versions, services, ports, existing setup) | no |
| `devcontainer:planner` | Turns profile + requirements into a plan (shape, image, features, files, risks, questions) | no |
| `devcontainer:builder` | Writes or modifies the files according to the plan | **yes** |
| `devcontainer:reviewer` | Reviews the configuration (spec, best practices, secrets) | no |
| `devcontainer:troubleshooter` | Diagnoses a failure and proposes a fix | no |
| `devcontainer:maintainer` | Audits drift in an existing devcontainer | no |

Chains: **creation** `scout → planner → builder → validate → reviewer` (one correction loop if the reviewer
finds defects); **update** `scout + maintainer → planner → builder → validate → reviewer`;
**troubleshooting** `troubleshooter → builder → validate → reviewer`.

## What it costs

Each agent works in its own context: a full pipeline (`auto`, `guided`, extended `update`) launches 3 to 4
agents. To limit spending:

- small change to an existing devcontainer → `/devcontainer:update "add Redis"` (short path: a single agent);
- simple check → `/devcontainer:validate` or `/devcontainer:status` (no rewriting agent);
- the agents run on an economical model (`haiku` for exploration, `sonnet` elsewhere), with a capped number of
  turns, and only load the references useful to their task.

## Good to know

- Claude usually runs **inside** the container: it cannot rebuild it. After any change, a rebuild is needed
  from the host (VS Code: "Dev Containers: Rebuild Container"; CLI:
  `devcontainer up --workspace-folder . --remove-existing-container`).
- The plugin never overwrites an existing file without reading it, puts no secrets in `.devcontainer/` and performs
  no git operations: review `git diff`, then commit yourself.
- To get Claude Code and this plugin in the container: features `ghcr.io/Cleler/devcontainer-features/claude:1` and
  `ghcr.io/Cleler/devcontainer-features/claude-plugin-devcontainer:1`.

## Rules for the AI

1. **Route first.** Creation request with no details → `auto`. User who wants to decide, compare or "control
   everything" → `guided`. If the mode is unclear, ask with AskUserQuestion (autopilot recommended).
   Change to an existing `.devcontainer/` → `update`. Error, log, "it won't start" → `fix`. "Where does my devcontainer stand?", "is it up to date?" → `status`.
2. **Never write a configuration without having inspected the project** (scout): every choice must come from a file of the
   project, an instruction or a declared default.
3. **Delegate to the agents** rather than doing everything yourself: scout to understand, planner to decide, builder
   to write, reviewer to check. Wait for an agent's result before the next step; run independent ones in parallel
   (several scouts on a monorepo).
4. **Questions to the user are asked from the main session** (AskUserQuestion): agents cannot
   ask any and report their open questions back.
5. **Always finish** with a report: files created or modified, decisions and their source, assumptions, what remains
   to be verified, and the rebuild reminder.
6. Answer in the user's language.
