---
name: icontext-init
version: 1.1.0
description: Scaffold a layered context (L1 agent files / L2 CONTEXT.md / L3 plans) plus
             service skeletons (web/mobile/api/db) for a project. Greenfield (new) or
             brownfield (read & summarize an existing codebase). Asks a few key params,
             leaves the rest as placeholders, then writes CONTEXT.md for review.
             Use when starting/onboarding a web/mobile project and you want a context backbone.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
  - Agent
---

# icontext-init

The full, agent-neutral workflow lives in **[PROCEDURE.md](./PROCEDURE.md)** in this folder.
**Read PROCEDURE.md and execute its steps.** Templates are in `templates/`.

This skill is portable across agents — see [adapters/](./adapters/) for Gemini/Codex/Cursor.
SKILL.md is the Claude Code entry point.

## Claude-specific mappings
- **Step 0 update check** — run `bash check-update.sh` via `Bash` and show its one-line result.
- **Step 0 / Step 1 detection** — use `Bash` for the file-presence checks shown in PROCEDURE.md.
- **Step 2A params** — gather with `AskUserQuestion` (or read them straight from the user's
  prompt if already provided). Keep it hybrid: ask the few keys, placeholder the rest.
- **Step 2B brownfield inventory** — for large repos, dispatch the `Explore` agent (read-only
  fan-out) to map architecture, data model, and API surface; synthesize into CONTEXT.md.
- **File creation** — use `Write`/`Edit`, copying from `templates/` and substituting `{{VARS}}`.
- **Git** — `git init` only; never commit/push unless told.

## Stop rule
Finish at context review (PROCEDURE Step 3). Do not create feature plans here — that is the
separate `icontext-feature` skill.
