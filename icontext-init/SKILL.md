---
name: icontext-init
version: 1.2.0
description: Scaffold a layered context (L1 agent files / L2 CONTEXT.md / L3 plans) plus
             service skeletons (web/mobile/api/db) for a project. Greenfield (new),
             brownfield (read & summarize an existing codebase), or update/sync (fill only the
             missing pieces of an existing iContext backbone). Confirms every CONTEXT.md section
             with the project owner, then writes CONTEXT.md for review. Idempotent — safe to
             re-run. Use when starting/onboarding a web/mobile project and you want a context backbone.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
  - Agent
---

# icontext-init

> **ALWAYS DO THIS FIRST — every single invocation, no exceptions:**
> run `bash check-update.sh` via `Bash` and surface its output (shows the local **version** line
> + whether an update is available). Do this *before* reading the rest or asking anything. It is
> best-effort and never blocks (offline/unpublished just prints "skipped"). If an update is
> available, mention it, then continue.

The full, agent-neutral workflow lives in **[PROCEDURE.md](./PROCEDURE.md)** in this folder.
**Read PROCEDURE.md and execute its steps.** Templates are in `templates/`.

This skill is portable across agents — see [adapters/](./adapters/) for Claude/Gemini/Codex/Cursor.
SKILL.md is the Claude Code entry point (`adapters/claude.md` documents the same mapping for parity).

**Non-destructive (hard rule):** this skill NEVER deletes, overwrites, or rewrites existing
context — it only **adds the missing pieces**. Existing files and CONTEXT.md sections are kept
verbatim unless the owner explicitly edits them. It is **idempotent**: re-running on an existing
backbone enters **UPDATE/SYNC mode** and fills only the gaps (PROCEDURE Step 2C).
**Section-by-section confirmation:** every CONTEXT.md section (§1–13) is confirmed with the
project owner via `AskUserQuestion` before it is written/updated (PROCEDURE Step 2D). On a
**first-time init** the confirm is a deep, detailed interview per section; on UPDATE/SYNC it's a
light touch that only asks about the missing pieces. **Mandatory fields are always asked** in
every mode — e.g. if the context has no **project description** (§1), ask the user; never write
the context with it left blank/placeholder.

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
- **Git** — `git init` only; never commit/push unless told.

## Stop rule
Finish at context review (PROCEDURE Step 3). Do not create feature plans here — that is the
separate `icontext-feature` skill.
