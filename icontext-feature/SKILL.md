---
name: icontext-feature
version: 1.2.0
description: Generate a numbered feature plan (plans/NNN-name/ folder, split by role) with the standard
             section-0-to-11 structure + role owners + status lifecycle + optional persona
             panel. Use AFTER icontext-init, whenever adding a new feature to the project.
             Stops at the plan - does not implement.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

# icontext-feature

> **ALWAYS DO THIS FIRST — every single invocation, no exceptions:**
> run `bash check-update.sh` via `Bash` and surface its output (shows the local **version** line
> + whether an update is available). Do this *before* reading the rest or asking anything. It is
> best-effort and never blocks (offline/unpublished just prints "skipped"). If an update is
> available, mention it, then continue.

The full, agent-neutral workflow lives in **[PROCEDURE.md](./PROCEDURE.md)**.
**Read PROCEDURE.md and execute its steps.** The plan template folder is `templates/plan-template/`.

Portable across agents - see [adapters/](./adapters/). SKILL.md is the Claude Code entry point.

## Claude-specific mappings
- **Step 0 update check** - run `bash check-update.sh` via `Bash` and show its one-line result.
- **Step 1 scaffolding check** - use `Bash` to check for `styles/` (style guide),
  `docs/openapi.yaml`, and `.vscode/launch.json`. For any that are missing, ask with
  `AskUserQuestion` (multi-select) whether to create them, then create approved ones from the
  `icontext-init` templates. Don't block if declined.
- **Find next number** - use `Bash` to list `plans/` and compute `NNN`.
- **Feature brief + persona prompt** - gather with `AskUserQuestion`.
- **Persona Panel** - read `ROLE.md`; for each persona produce works / concern / suggestion
  notes (the plan's section 4).
- **Write plan** - a plan is a **folder** `plans/NNN-<slug>/`. Copy `templates/plan-template/`
  (role files bu/po/dev/qa/ops/stk.md + README.md), fill sections, set `Task status: plan` in the
  folder README, ref `CONTEXT.md`. Then register status in `plans/README.md` + `PLAN.md`.

## Stop rule
Finish at the written plan. Do not implement the feature.
