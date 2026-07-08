---
name: icontext-update
description: Update an existing iContext project to the latest template shape. Use when a project
             already has CONTEXT.md or an iContext backbone and the user wants to sync missing
             sections, L1 agent files including AGENTS.md, ROLE.md workflow guidance, plan
             templates, docs/openapi.yaml, styles, launch config, or service STRUCTURE files from
             the current iContext templates. Adds only missing artifacts or missing sections,
             confirms every proposed change with the user before writing, preserves owner-authored
             content, leaves TODOs for unknown facts, and stops after the context/template backfill.
             Do NOT use for greenfield setup or one feature plan; use icontext-init or
             icontext-feature instead.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

# icontext-update

> **Run `bash check-update.sh` first** and surface its one-line result. It shows the local version
> and whether an update is available. The check is best-effort and never blocks.

Read **[PROCEDURE.md](./PROCEDURE.md)** and execute it. This skill is a focused update/sync pass
for projects that already have `CONTEXT.md`: compare the project against the latest templates in
`icontext-init/templates/`, add only what is missing, confirm every change before writing, and
never overwrite owner-authored content.

## Mappings
- **Update check** — run `bash check-update.sh`.
- **Inventory** — use shell/file reads to compare the project against `icontext-init/templates/`.
- **Confirm changes** — before every file creation or patch, tell the user the file, reason, and
  exact action; write only after confirmation.
- **Backfill** — create missing files from templates and insert missing sections/headings only after
  confirmation.
- **Questions** — ask only when a value is mandatory and cannot be inferred; otherwise use TODOs.
- **Git** — never commit or push unless explicitly told.

## Stop rule
Finish after the gap table and summary. Do not create a feature plan or implement app code.
