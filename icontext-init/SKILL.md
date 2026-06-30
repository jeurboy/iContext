---
name: icontext-init
version: 1.4.0
description: Use this skill to establish or refresh the foundational, whole-project context that
             lets any AI session instantly understand a codebase's architecture — the "iContext" /
             CONTEXT.md backbone (L1 agent files / L2 CONTEXT.md / L3 plans) plus web/mobile/api/db
             service skeletons. Trigger in two situations. (1) Setting up from scratch — "set up
             iContext", "bootstrap the project context", "scaffold the context backbone", or
             "onboard our architecture" — for a new project or by reading an existing codebase,
             naming the stack, services, ports, and data model so the AI knows the system from day
             one. (2) Updating an existing backbone — a stale or partial CONTEXT.md, an unfinished
             data-model or security section, a newly added service or second app to sync in, or a
             missing scaffolded artifact like the OpenAPI spec or style tokens; it interviews the
             owner section by section and adds only what's missing, never overwriting their words.
             Do NOT use for per-feature work — planning or building one feature or endpoint,
             generating a standalone OpenAPI spec, rewriting a README, or showing a plan-status
             dashboard.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
  - Agent
---

# icontext-init

> **Run `bash check-update.sh` first** (via `Bash`) and surface its output — it shows the local
> version and whether an update is available. Doing this up front means you and the user both know
> which version is in play before anything changes; it's cheap, best-effort, and never blocks
> (offline/unpublished just prints "skipped"). If an update is available, mention it, then continue.

The full, agent-neutral workflow lives in **[PROCEDURE.md](./PROCEDURE.md)** — read it and execute
its steps. Templates are in `templates/`. Portable across agents — see [adapters/](./adapters/)
for Claude/Gemini/Codex/Cursor; SKILL.md is the Claude Code entry point (`adapters/claude.md`
mirrors the mapping).

Two invariants worth holding in mind (full detail in PROCEDURE):
- **Non-destructive & idempotent** — the skill only *adds* what's missing. It doesn't delete or
  rewrite existing context, because the owner's wording is the source of truth; on an existing
  backbone it runs in UPDATE/SYNC mode and fills only the gaps (Step 2C).
- **Confirm every section with the owner** — walk CONTEXT.md §1–13 via `AskUserQuestion` before
  writing (Step 2D): a deep interview on a first-time init, a light touch on update/sync, and
  mandatory fields (e.g. project description) are asked rather than left blank.

## Claude-specific mappings
- **Step 0 update check** — run `bash check-update.sh` via `Bash` and show its one-line result.
- **Step 0 / Step 1 detection** — use `Bash` for the file-presence checks shown in PROCEDURE.md.
- **Step 2A params** — gather with `AskUserQuestion` (or read them straight from the user's
  prompt if already provided).
- **Step 2B brownfield inventory** — for large repos, dispatch the `Explore` agent (read-only
  fan-out) to map architecture, data model, and API surface; synthesize into CONTEXT.md.
- **Step 2C update/sync** — when a backbone already exists, inventory artifacts and create only
  the missing ones; never overwrite files that contain author content.
- **Step 2D section confirm** — drive the per-section confirm/edit/skip loop with
  `AskUserQuestion` (batch related sections into one prompt to keep it short).
- **File creation** — use `Write`/`Edit`, copying from `templates/` and substituting `{{VARS}}`.
- **Git** — `git init` only; **confirm the repo strategy (submodules / monorepo / separate repos)
  with `AskUserQuestion` before wiring services as submodules** (PROCEDURE Step 2A). Never
  commit/push unless told.

## Stop rule
Finish at context review (PROCEDURE Step 3). Do not create feature plans here — that is the
separate `icontext-feature` skill.
