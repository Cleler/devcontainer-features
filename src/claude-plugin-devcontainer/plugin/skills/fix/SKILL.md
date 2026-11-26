---
name: fix
description: "Diagnoses and fixes a devcontainer that fails to build, fails to start, or misbehaves."
argument-hint: "[error message, log path, or description of the symptom]"
---
# Troubleshoot a devcontainer

Symptom provided (may be empty): $ARGUMENTS

## Steps

1. **Gather evidence.** Without a usable symptom, ask the user: at which stage it fails (build,
   startup, after connecting), the **exact error message**, and the full **creation log**. To get it:
   VS Code → "Dev Containers: Show Container Log"; or, from the host,
   `devcontainer up --workspace-folder . --log-level trace`. Do not guess from a truncated message.
2. **Diagnose.** Launch `devcontainer:troubleshooter` with the symptom, the log (paste it: the agent cannot see this
   conversation) and the useful context (devcontainer shape, failing step). It returns a substantiated likely cause,
   alternative hypotheses and a minimal fix.
3. **Present** the diagnosis in a few lines (cause, evidence, fix) and ask for confirmation with
   AskUserQuestion before changing anything: *Apply the fix* / *Explore another hypothesis* /
   *I will provide more information*.
4. **Fix.** `devcontainer:builder` with the exact fix (minimal change, nothing else), then the
   checks of the `validate` skill, then `devcontainer:reviewer` only if the fix touches more than one file.
5. **Report**: cause, change made, and how to verify: **rebuild from the host** (VS Code: "Dev
   Containers: Rebuild Container"; CLI: `devcontainer up --workspace-folder . --remove-existing-container`),
   then send back the new log if it still fails (the loop starts again with the new evidence).

## Guardrails

No fix without evidence; one change at a time when the cause is uncertain; never overwrite a file
without having read it; no secrets in files; no git operations.
