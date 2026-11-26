---
name: guided
description: "Configures a devcontainer step by step: one question per decision, summary, approval, then writing and review."
argument-hint: "[topic or starting point: 'new', 'review the existing one', a theme...]"
---
# Step-by-step devcontainer

Starting point given by the user (may be empty): $ARGUMENTS

You run a structured interview. The user decides; you propose, explain the trade-offs in one sentence, and
recommend. Keep a visible task list (one line per interview step). Ask questions with
AskUserQuestion (1 to 4 questions per call, 2 to 4 options, the **recommendation in first position** with its reason).
The user can always answer "choose for me" (take the recommendation), "skip", or go back.

## 0. Framing

Explain in three lines what is going to happen (analysis → questions → summary → approval → writing → verification).
If `.devcontainer/` exists, ask whether the goal is to **review** it (then take what exists as the starting values,
and modify through targeted changes) or to **start from scratch** (never without explicit approval).

## 1. Scout

Launch `devcontainer:scout` (one per package if monorepo, three at most) and present the profile in a few lines: what is detected, with
its source, and what is unknown. Ask the user to correct or complete it. Their corrections take precedence.

## 2. The decisions, in this order

For each topic: recall what you detected, ask the question, note the answer. Skip a topic only if it is
not applicable (no service → no Compose) and say so.

1. **Shape**: `image` + features, `Dockerfile`, or Docker Compose (see `config`, `dockerfile`, `compose`).
2. **Base image**: family (Ubuntu/Debian), generic image or language image, pinned version.
3. **Runtimes and versions**: confirm each detected language and its version (source: project files).
4. **Tools and features**: git, GitHub CLI, Docker (Docker-in-Docker or the host's), cloud CLI, others (see `features`).
5. **System packages**: those the project suggests, plus those the user adds.
6. **Services** (if Compose): which ones, version, persistent data, development passwords.
7. **Ports**: which to forward, with what label, and which open automatically.
8. **Install and startup**: dependency install command (from the lockfile), lifecycle
   steps to use (`postCreateCommand`, `postStartCommand`...), startup tasks.
9. **Editor**: VS Code extensions and settings useful to the project.
10. **User and filesystem**: `remoteUser`, UID/GID, extra mounts (cache, SSH keys, data).
11. **Variables and secrets**: required variables; secrets go through `${localEnv:...}` or an ignored `.env`, never
    in plain text in `.devcontainer/`.
12. **Claude Code in the container**: features `ghcr.io/Cleler/devcontainer-features/claude:1` and
    `claude-plugin-devcontainer:1`, with `"initializeCommand": "mkdir -p ~/.claude/devcontainer"` (Linux/macOS).
13. **Resources and performance**: `hostRequirements`, build cache, prebuilt image.
14. **Anything else**: one open question for whatever the list did not cover.

## 3. Summary and approval

Present a **Topic | Decision | Source** table (source: project, your choice, or accepted recommendation). Ask:
*Apply*, *Change a point* (which one), or *Cancel*. Also ask whether they want to **see each file before it
is written** (then have the builder produce the files one by one and show them before moving to the next) or
**write directly**.

## 4. Build, verify, get it reviewed

1. Launch `devcontainer:planner` with the profile and the decisions: it turns them into a file plan and flags
   inconsistencies or risks. If the planner raises a real problem, explain it to the user and go back to the
   decision concerned.
2. Launch `devcontainer:builder` with the full plan (the agent cannot see this conversation).
3. Apply the checks of the `validate` skill. Error → back to the builder.
4. Launch `devcontainer:reviewer`. "Blocking" or "Must fix" defects → builder, then a second pass by the reviewer on the
   fixed items; a single loop, then honestly present what remains.

## 5. Report

Files created or modified, decisions (recap of the table), items raised by the reviewer, review `git diff`, **rebuild
from the host** (VS Code: "Dev Containers: Rebuild Container"; CLI: `devcontainer up --workspace-folder .
--remove-existing-container`), and `/devcontainer:fix` in case of problems.

## Guardrails

Never overwrite a file without having read it; no secrets in files; no git operations; do not try to rebuild the
container.
