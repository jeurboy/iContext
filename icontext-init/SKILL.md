---
name: icontext-init
description: Establish or refresh the whole-project iContext backbone so agents understand a
             codebase's architecture, conventions, workflow, and plan status. Use for greenfield
             setup, brownfield onboarding, or update/sync when CONTEXT.md, L1 agent files
             (CLAUDE.md, AGENTS.md, AGENT.md, GEMINI.md), ROLE.md, plans/, docs/openapi.yaml,
             styles/, service skeletons, or data/security sections are missing or stale. It
             interviews section-by-section and only adds missing context. Do NOT use for
             per-feature planning, implementation, standalone OpenAPI generation, README rewrites,
             or plan dashboards; use icontext-feature for one feature plan.
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
