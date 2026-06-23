---
name: icontext-feature
version: 1.0.0
description: Generate a numbered feature plan (plans/NNN-name.md) with the standard
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

The full, agent-neutral workflow lives in **[PROCEDURE.md](./PROCEDURE.md)**.
**Read PROCEDURE.md and execute its steps.** The plan template is in `templates/plan-template.md`.

Portable across agents - see [adapters/](./adapters/). SKILL.md is the Claude Code entry point.

## Claude-specific mappings
- **Find next number** - use `Bash` to list `plans/` and compute `NNN`.
- **Feature brief + persona prompt** - gather with `AskUserQuestion`.
- **Persona Panel** - read `ROLE.md`; for each persona produce works / concern / suggestion
  notes (the plan's section 4).
- **Write plan** - use `Write` from `templates/plan-template.md`, fill sections, set
  `status: todo`, ref `CONTEXT.md`. Then register status in `plans/README.md` + `PLAN.md`.

## Stop rule
Finish at the written plan. Do not implement the feature.
