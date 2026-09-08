---
name: icontext-update
description: Update an existing iContext backbone to the latest template shape. Use when a project
             already has CONTEXT.md and needs missing L1/L2/L3 artifacts (including
             AGENTS.md/agents.md and AGENT.md/agent.md casing aliases), workflow/security/skill
             routing (including gstack /investigate and resolving-merge-conflicts), project safety hooks, plan templates, docs, styles, launch config,
             or service STRUCTURE files; or when restructuring legacy context by splitting a
             monolithic CONTEXT.md into the context/ concern files (DEV.md, PRODUCT.md, QA.md,
             SECURITY.md, DESIGN.md, SKILLS.md), moving legacy §10 into context/SKILLS.md, or
             relocating pre-1.17 root-level concern files (and ROLE.md) into the context/ folder.
             It is confirmation-first and
             additive, preserves owner-authored content, leaves TODOs for unknown facts, and stops
             after backfill. Do NOT use for greenfield setup or one feature plan; use icontext-init
             or icontext-feature instead.
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
- **L2 split (Step 5.5)** — if the project still has one monolithic `CONTEXT.md`, propose splitting
  §3–7 → `context/DEV.md`, §1/§2/§13 → `context/PRODUCT.md`, §9 → `context/QA.md`, §8/§11.6 →
  `context/SECURITY.md`, §12 → `context/DESIGN.md`, §10 → `context/SKILLS.md`. Also propose the §10
  move when the project already has the older six-file L2
  split but no `SKILLS.md`. Get
  per-file approval with `AskUserQuestion`, **move** the owner's text verbatim (never copy or
  reword), leave a `➜ Moved to …` stub in `CONTEXT.md`, and rewrite the refs listed in 5.5.5.
  Section numbers never change.
- **L2 relocation (Step 5.7)** — pre-1.17 projects keep `DEV.md`, `PRODUCT.md`, `QA.md`,
  `SECURITY.md`, `DESIGN.md`, `SKILLS.md`, and `ROLE.md` at the repo root. Offer the per-file move
  into `context/` (contents verbatim; only links change), then rewrite the inbound references
  (`CONTEXT.md` map/stubs, L1 read-first lists, plan `ref:` lines) and verify nothing dangles.
- **Inventory** — use shell/file reads to compare the project against `icontext-init/templates/`.
- **Confirm changes** — before every file creation or patch, tell the user the file, reason, and
  exact action; write only after confirmation.
- **Backfill** — create missing files from templates and insert missing sections/headings only after
  confirmation.
- **Merge-conflict route** — backfill the `resolving-merge-conflicts` registry row, invocation
  route (`SKILLS.md` §10), and `DEV.md` §5.1 workflow section only as approved additive gaps. The
  skill stays an external upstream dependency, and finishing a merge/rebase keeps the §11.7
  confirmation gate.
- **Safety hook (Step 5.6)** — detect/backfill `.icontext/hooks`, L1/§11.7 rules, and documented
  interactive host wiring after approval. Merge existing hook config, verify dry-run payloads, and
  report instruction-only enforcement when the host has no usable hook.
- **Questions** — ask only when a value is mandatory and cannot be inferred; otherwise use TODOs.
- **Restricted actions** — never commit, push, access/change a DB, migrate, or seed without the
  exact per-invocation confirmation required by CONTEXT.md §11.7.
- **Load-test offer (every run)** — ask whether the owner wants a page-specific load-test script.
  If yes, finish the approved update first, then hand off to `/icontext-loadtest`; that skill asks
  which page/screen/route to test and generates offline by default.

## Stop rule
Finish after the gap table and summary. If the owner accepted the load-test offer, hand off to
`/icontext-loadtest` as a separate workflow. Do not create a feature plan or implement app code.
