---
name: icontext-feature
description: Generate a numbered feature plan (plans/NNN-name/ folder, split by role) with the standard
             section-0-to-11 structure + role owners + task-status lifecycle + optional persona
             panel. Use AFTER icontext-init, whenever adding a new feature or capability to a project
             that already has a CONTEXT.md backbone — even if the user just says "plan this feature",
             "write a plan for X", or "spec out the next thing". Stops at the plan - does not implement.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

# icontext-feature

> **Run `bash check-update.sh` first** (via `Bash`) and surface its output — it shows the local
> version and whether an update is available, so you and the user share the same picture before
> anything changes. It's best-effort and never blocks (offline/unpublished just prints "skipped").
> If an update is available, mention it, then continue.

> **Then gather a minimal brief, grill, and review requirements before writing (required).** Capture
> the feature name, intent, touched services, and known constraints, then run
> **`/grill-with-docs`** — interview the user until the decision tree is resolved, sharpening domain
> terminology and updating `CONTEXT.md` + ADRs inline. Next, use `ROLE.md` as a multi-agent panel to
> review the requirement. Only start scaffolding / writing the plan **after** the grill + role
> review. (Falls back to `/grill-me` or a manual grilling pass if `grill-with-docs` isn't installed.)

The full, agent-neutral workflow lives in **[PROCEDURE.md](./PROCEDURE.md)**.
**Read PROCEDURE.md and execute its steps.** The plan template folder is `templates/plan-template/`.

Portable across agents - see [adapters/](./adapters/). SKILL.md is the Claude Code entry point.

## Claude-specific mappings
- **Step 0 update check** - run `bash check-update.sh` via `Bash` and show its one-line result.
- **Step 3/3.5 brief + grill (required)** - gather a minimal brief, then run
  **`/grill-with-docs`** to stress-test the feature and build/refresh `CONTEXT.md` + ADRs before
  writing anything. Proceed to the plan only once the key decisions are resolved.
- **Step 4 ROLE.md review (required)** - read `ROLE.md` and use it as a multi-agent requirement
  review panel. Put Works / Concern / Suggestion / Plan impact into `stk.md` §4 and fold accepted
  changes into the role files before `/autoplan`.
- **Step 1 scaffolding check** - use `Bash` to check for `styles/` (style guide),
  `docs/openapi.yaml`, and `.vscode/launch.json`. For any that are missing, ask with
  `AskUserQuestion` (multi-select) whether to create them, then create approved ones from the
  `icontext-init` templates. Don't block if declined.
- **Find next number** - use `Bash` to list `plans/` and compute `NNN`.
- **Feature brief + persona prompt** - gather with `AskUserQuestion`.
- **Plan preparation** - after writing and registering the plan, run gstack `/autoplan` (or the
  individual review chain) before moving toward `ready to implement`.
- **Write plan** - a plan is a **folder** `plans/NNN-<slug>/`. Copy `templates/plan-template/`
  (role files bu/po/dev/qa/ops/stk.md + README.md), fill sections, set `Task status: plan` in the
  folder README, ref `CONTEXT.md`. Then register status in `plans/README.md` + `PLAN.md`.

## Stop rule
Finish at the written plan. Do not implement the feature.
