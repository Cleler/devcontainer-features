---
name: update
description: "Modifies or upgrades an existing devcontainer (service, feature, version, port) or audits its drift."
argument-hint: "[desired change, or empty for an upgrade audit]"
---
# Update an existing devcontainer

Requested change (may be empty): $ARGUMENTS

You orchestrate the agents; changes are **targeted**: keep the user's existing style, comments and choices, and do
not rewrite what works. Keep a visible task list.

## Short path (default for a specific change)

If the requested change is **specific, local and unambiguous** (add a feature, a port, an extension,
change a runtime version): skip the scout, the maintainer and the planner. Launch `devcontainer:builder` directly
with the instruction and the directive to modify through targeted changes, apply the checks of the `validate` skill,
and launch `devcontainer:reviewer` only if a Dockerfile or a compose file is touched. Report as in step 7.

For any broader or ambiguous change, or an upgrade without instructions, follow the full path below.

## Full path

1. **Check.** `.devcontainer/` (or `.devcontainer.json`) must exist; otherwise suggest `/devcontainer:auto`.
2. **Observe** (in parallel): `devcontainer:scout` (current project profile, including what exists) and
   `devcontainer:maintainer` (gap between the configuration and the project, pinning, compliance). If the requested
   change is specific and local ("add Redis"), the maintainer is mostly used to spot what it touches.
3. **Decide what to change.**
   - *Requested change*: it is the main requirement; only add the fixes the maintainer deems
     **Required** because they depend on it, and flag the rest without applying it.
   - *No instruction* (upgrade): present the maintainer's findings ranked (Required / Recommended /
     Optional) and ask with AskUserQuestion (multiple choice) which to apply; recommend Required + Recommended.
4. **Plan.** `devcontainer:planner` with the profile, the audit and the selected changes: it returns the precise list
   of modifications and the risks (feature major version, long rebuild, image change). Blocking questions
   go to the user; the others take their default.
5. **Apply.** `devcontainer:builder` with the plan (paste it in full: the agent cannot see this conversation),
   reminding it to modify through targeted changes.
6. **Validate** with the checks of the `validate` skill, then **get it reviewed** by `devcontainer:reviewer`
   (a single loop back to the builder, second pass limited to the fixed items).
7. **Report.** What changed (before → after, file by file), what was deliberately left alone, the
   risks, `git diff` to review, and a reminder to **rebuild from the host** (VS Code: "Dev Containers: Rebuild
   Container"; CLI: `devcontainer up --workspace-folder . --remove-existing-container`).

## Guardrails

Never overwrite a file without having read it; no secrets in files; no git operations; do not try to rebuild the
container.
