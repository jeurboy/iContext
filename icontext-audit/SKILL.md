---
name: icontext-audit
description: Audit an existing iContext project against the latest iContext template and the
             current repository reality. Use whenever the user asks to check whether project
             context is complete, validate CONTEXT.md/agent files/plans against the template,
             find stale or drifted context, clean unnecessary Markdown, or keep iContext up to
             date. It inventories L1/L2/L3 artifacts including AGENTS.md/agents.md and
             AGENT.md/agent.md casing aliases, missing sections, placeholders, workflow
             drift, plan/status sync, project safety-hook coverage, service docs, and cleanup candidates; asks the user for an
             explicit decision on every missing, unclear, stale, or cleanup item before writing;
             then applies only approved updates while preserving owner-authored content. Do NOT
             use for first-time setup or one feature plan; use icontext-init or icontext-feature.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

# icontext-audit

> Run `bash check-update.sh` first and surface its one-line result. It shows the local version and
> whether an update is available. The check is best-effort and never blocks.

Read **[PROCEDURE.md](./PROCEDURE.md)** and execute it. This skill is an audit-and-maintenance
pass for projects that already have an iContext backbone: compare the project against the latest
templates in `../icontext-init/templates/`, compare the written context against the current repo,
identify unnecessary or stale Markdown, ask the user about every issue, and apply only the approved
updates.

## Mappings
- **Update check** - run `bash check-update.sh`.
- **Inventory** - use shell/file reads to compare the target project with latest iContext
  templates and actual repo structure.
- **Audit report** - produce a gap table before editing, including missing, stale, unclear, and
  cleanup-candidate items.
- **Ask every item** - each missing, stale, unclear, or cleanup item must get an explicit user
  decision before any write, move, archive, or delete action. Chunk long lists, but keep every item
  individually addressable.
- **Update** - patch only approved gaps, preserve owner-authored text, and leave TODOs only when
  the user chooses to defer.
- **Merge-conflict routing** - flag a missing `resolving-merge-conflicts` row/route in
  `SKILLS.md` §10 or a missing `DEV.md` §5.1 workflow section as an additive gap for the owner to
  approve; resolving an actual conflict is outside audit scope.
- **Safety hook** - audit `.icontext/hooks`, L1/§11.7 rules, executable mode, and real active-host
  wiring. Apply only approved backfills/merges and verify with non-executing safe/restricted probes.
- **Cleanup** - never remove Markdown just because it is outside the template. Ask whether to keep,
  merge, archive, or delete each candidate, and only act on confirmed choices.
- **Restricted actions** - never commit, push, access/change a DB, migrate, or seed without the
  exact per-invocation confirmation required by CONTEXT.md §11.7.
- **Load-test offer (every run)** - ask whether the owner wants a page-specific load-test script.
  If yes, finish the audit first, then hand off to `/icontext-loadtest`; it asks for the target page
  and generates offline by default.

## Stop rule
Finish after the re-audit summary and final gap table. If the owner accepted the load-test offer,
hand off to `/icontext-loadtest` as a separate workflow. Do not create a feature plan or implement
app code.
