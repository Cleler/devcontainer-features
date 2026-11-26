---
name: auto
description: "Creates a solid, reviewed devcontainer from a few instructions (autopilot with agents)."
argument-hint: "[instructions: stack, services, tools, constraints...]"
---
# Autopilot devcontainer

User instructions (may be empty): $ARGUMENTS

You orchestrate a team of specialized agents. You do not write the configuration yourself: you chain the steps,
check each result, and ask a question only when it is essential. Keep a visible task list with one line per step.

## Guardrails

- **`.devcontainer/` already exists?** Do not create anything: follow the workflow of the `update` skill.
- Never overwrite a file without having read it; no secrets in files; no git operations; do not try to rebuild or
  start a container (you are probably inside one).
- Explicit user instructions take precedence over any default choice.

## Steps

1. **Scout.** Launch the `devcontainer:scout` agent to get the project profile. Monorepo with several distinct
   packages: one scout per package, **three at most** in parallel. Wait for the results.
2. **Plan.** Launch `devcontainer:planner` with the profile and the instructions above. It returns a plan and open
   questions (blocking or not, each with a default).
3. **Settle only what is strictly necessary.** For **blocking** questions only, ask the user all at once with
   AskUserQuestion (4 questions maximum, recommendation as the first option). Non-blocking questions take their
   default: note them as **assumptions**. If an answer changes the plan significantly, relaunch the planner with that
   answer.
4. **Build.** Launch `devcontainer:builder` with the final plan (paste it in full: the agent cannot see this
   conversation). It writes the files and returns the list of changes.
5. **Validate.** Apply the checks of the `validate` skill to the produced files (syntax, consistency, available
   tools). Send any error back to the builder.
6. **Get it reviewed.** Launch `devcontainer:reviewer`. If it raises "Blocking" or "Must fix" items, send them back to
   the builder, then relaunch the reviewer **only on the fixed items** (second pass). **A single loop**; if defects
   remain, present them honestly instead of hiding them.
7. **Report.** Short report:
   - files created (path + role);
   - key decisions and their source ('Node 20: `.nvmrc`');
   - **assumptions** made without confirmation, to be verified;
   - reviewer verdict and remaining items;
   - next steps: review `git diff`, **rebuild the container from the host** (VS Code: "Dev Containers: Rebuild
     Container"; CLI: `devcontainer up --workspace-folder . --remove-existing-container`), then `/devcontainer:fix`
     if something fails;
   - a reminder that `/devcontainer:guided` and `/devcontainer:update` can be used to adjust things afterwards.
