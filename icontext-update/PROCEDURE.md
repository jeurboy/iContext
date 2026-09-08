# icontext-update — procedure (agent-neutral)

> Source of truth for updating an existing iContext project to the latest template shape.
> It is intentionally narrower than `icontext-init`: no greenfield scaffold, no feature plan,
> no implementation.

## Operating rules
- **Requires an existing project context.** If the target root has no `CONTEXT.md`, stop and tell
  the user to run `icontext-init` first.
- **Never overwrite owner-authored content.** Existing text is the source of truth. Add only missing
  files, headings, sections, or clearly missing workflow bullets. The one structural change this
  skill may make is the **L2 split** (Step 5.5) — and only with explicit per-file approval, moving
  the owner's text verbatim and leaving a pointer stub behind.
- **Confirm every change before writing.** Inventory and planning can run without approval, but
  every file creation, section insertion, bullet append, or template patch must be shown to the user
  and explicitly confirmed before it is applied. Batch confirmations are allowed only when the user
  explicitly approves the listed batch.
- **Do not invent facts.** When a required value cannot be inferred, write `<!-- TODO: ... -->` or
  ask the owner if the field is mandatory for the backfill.
- **Keep the latest workflow visible.** Ensure the context mentions the selectable requirement
  discovery route (`/grill-with-docs` for clear-ish requirements, `/wayfinder` for large/foggy
  requirements), `ROLE.md` multi-agent requirement review, gstack `/autoplan` plan preparation,
  and the `resolving-merge-conflicts` route for in-progress merge/rebase conflicts (workflow
  documented in `DEV.md` §5.1).
- **Never commit / push or access/change a DB without per-invocation confirmation.** Migrations,
  seed/reset/import/restore, direct DB clients, and DB-changing startup flags are gated even when
  locally scoped. Hook installation never grants permission (CONTEXT.md §11.7).

## Step 0 — Update check
Run `check-update.sh` next to this file and surface its one-line result. Continue even if offline.

## Step 1 — Confirm update mode
At the target root, confirm `CONTEXT.md` exists. Then inventory the current iContext artifacts:
- L1 files: `CLAUDE.md`, one of `AGENTS.md` or `agents.md`, one of `AGENT.md` or `agent.md`,
  and `GEMINI.md`. Each casing pair is one logical artifact: preserve the existing casing and do not
  propose the other as missing. If both aliases exist, report a duplication conflict and ask which
  file is canonical before any merge/archive/delete action.
  Use exact basenames from a directory listing rather than probing both paths with `test -e`, because
  case-insensitive filesystems can resolve both aliases to one file.
- **L2 context (7 files, split by concern)**: `CONTEXT.md`, `DEV.md`, `PRODUCT.md`, `QA.md`, `SECURITY.md`,
  `DESIGN.md`, `SKILLS.md` — plus `ROLE.md`. A project still holding all of §1–13 in one
  `CONTEXT.md`, or a six-file project still holding §10 in `CONTEXT.md`, is a
  **split candidate** → Step 5.5
- L3/status: `PLAN.md`, `plans/README.md`, `plans/_TEMPLATE/`
- Shared scaffolding: `docs/openapi.yaml`, `styles/css/tokens.css`, `styles/components/`,
  `.vscode/launch.json`, `docker-compose.yml`
- Agent safety: `.icontext/hooks/guard-command.sh`, `.icontext/hooks/POLICY.md`, executable mode,
  L1/CONTEXT.md §11.7 rules, and active-host project hook registration/status
- Service guides: each service's `STRUCTURE.md` using the service names from `DEV.md §6`

Use the latest source templates from the sibling path `../icontext-init/templates/`.

## Step 1.5 — Offer page-specific load-test scaffolding every run

Ask the owner on every invocation:

> Do you want to create or refresh a load-test script for a page/screen/route after this iContext
> update finishes?

This is a separate opt-in, not a template gap and not permission to run load traffic. Record yes/no
in the final report. If yes, complete only the approved iContext changes first, then invoke
`/icontext-loadtest`. The load-test skill asks which page/screen/route to test on its own invocation,
traces the real API fan-out and side effects, generates from its bundled templates, and stops without
running by default.

## Step 2 — Build a gap table
Create a gap table before editing. Do not write anything yet:

| Artifact / section | Current state | Action |
|--------------------|---------------|--------|
| `AGENTS.md` / `agents.md` | missing | ask preferred casing, then create one from latest template |
| `CONTEXT.md §11.0` | missing | insert latest workflow subsection |

Track both file-level gaps and section-level gaps. Check for the latest section set §1–13 **across
the L2 files** (a section counts as present wherever it lives): §11.0 main workflow, §11.1 plan
structure, §11.2 plan rules, §11.3 sync rule + L2 sibling triggers, §11.4 `/autoplan` review chain,
§11.5 implementation loop, and §11.6 `security-review` phase wiring.
Also check §11.7 agent mutation safety: fresh confirmation for every commit, push, direct DB
access/mutation, migration, seed/reset/import/restore, and documented interactive hook wiring.
Within `SKILLS.md` §10, also check the direct dependency registry and invocation routes for the
current required entries, including gstack `/investigate` for errors, regressions, stack traces,
and unexpected behavior, `resolving-merge-conflicts` for in-progress merge/rebase conflicts (when
its row or route is missing, also backfill the `DEV.md` §5.1 workflow section in the same
approved change), the user-invoked `to-spec` route for publishing a discussion as a tracker
spec, the mattpocock `code-review` standards/spec pass (distinct from `security-review`'s
security-scoped `code-review` detector), and the user-invoked mattpocock `implement` executor
(the §11.5 loop keeps its original step order; when its row or route is missing, also backfill
the `DEV.md` §5.2 execution-flow section in the same approved change). A missing row or route
is a section-level additive gap, not a reason to replace the owner's registry.
Check the §10 source/install registry too: every external direct dependency needs a verified
upstream Git/source URL and install guidance. Treat a missing URL as an additive gap; never guess a
repository or replace an owner-pinned fork/ref without confirmation.

If `DEV.md` / `PRODUCT.md` / `QA.md` / `SECURITY.md` / `DESIGN.md` / `SKILLS.md` are missing, inspect
whether their owned sections still exist in `CONTEXT.md`. Use `split out of CONTEXT.md (Step 5.5)`
only when there is owner text to move; otherwise use `create from latest template (Step 4/5)`.
Treat either action as a proposal, not a decision.

## Step 3 — Confirm the change plan
Before editing, present the planned changes in a confirmation table:

| # | File | Change type | Why | Proposed action |
|---|------|-------------|-----|-----------------|
| 1 | `AGENTS.md` / `agents.md` | create | L1 agent file missing | ask preferred casing, then copy one canonical template |
| 2 | `CONTEXT.md` | patch | §11.0 missing | insert latest main workflow subsection |
| 3 | `.icontext/hooks/` | create/wire | mutation guard missing | add portable guard; wire only if host supports interactive hooks |

Ask the user to approve each change or approve the whole listed batch. If the user rejects an item,
skip it and mark it `skipped` in the final gap table. If new gaps are discovered later, pause and
confirm those new changes before writing them too.

## Step 4 — Backfill missing files
For missing files, copy from `../icontext-init/templates/` and substitute variables inferred from
the existing project:
- `{{PROJECT_NAME}}`, `{{PROJECT_SLUG}}`, `{{PROJECT_DESC}}`, `{{PLATFORMS}}`, `{{REFERENCE}}`
- `{{WEB_STACK}}`, `{{MOBILE_STACK}}`, `{{API_STACK}}`, `{{DB_STACK}}`
- `{{DB_PORT}}`, `{{WEB_PORT}}`, `{{API_PORT}}`, `{{DATE}}`

If a variable is unknown, use a TODO marker rather than guessing. Do not replace a file that exists
and has content. If a file exists but lacks the latest workflow bullets, append a short
"iContext latest workflow" addendum instead of rewriting it.
If `SKILLS.md` is missing but §10 exists in `CONTEXT.md`, do not create a second template copy here;
route it to the verbatim move in Step 5.5.
Only apply file backfills that the user confirmed in Step 3.

## Step 5 — Backfill missing sections
Patch only missing sections/headings:
- **L2 files** — insert missing §1–13 sections or missing §11 subsections from the latest
  templates, each into its owning file (`PRODUCT.md` §1/§2/§13 · `DEV.md` §3–7 · `SKILLS.md` §10 · `CONTEXT.md` §11 ·
  `SECURITY.md` §8/§11.6 · `QA.md` §9 · `DESIGN.md` §12). On a not-yet-split project, insert into
  `CONTEXT.md` and offer the split separately (Step 5.5) — don't force it. If the only legacy
  ownership is §10 in `CONTEXT.md`, offer the `SKILLS.md` move instead of duplicating §10.
  Preserve all existing text. If exact insertion is risky, append a clearly titled
  "Backfilled from latest iContext template" block near the relevant parent section.
  For `SKILLS.md`, add only the approved missing registry row or invocation route (for example,
  `/investigate`) or source/install entry; never rewrite or reorder the owner's existing tables.
- **`ROLE.md`** — ensure the Requirement Review Protocol exists. If absent, append it from the
  latest template so future plans can use multi-agent requirement review.
- **Plan templates** — ensure `plans/_TEMPLATE/README.md`, `bu.md`, `po.md`, `dev.md`, `qa.md`,
  `ops.md`, and `stk.md` exist and include the latest §4 Requirement Discovery / Requirement Review
  / Persona Panel shape, and that `ops.md` carries the latest §8.1 Security review table
  (`security-review` plan/implement phase wiring).
- **Indexes** — ensure `PLAN.md` and `plans/README.md` exist. Do not reorder existing plans.

When content is partially present, prefer the smallest additive patch: add the missing subsection,
bullet, or table row. Never normalize prose just to match the template.
Only apply section backfills that the user confirmed in Step 3. If a patch becomes materially
different from what was confirmed, stop and ask again before writing.

## Step 5.5 — Refactor legacy L2 ownership into the latest split
Latest iContext splits Layer 2 into **seven files at the repo root**, one per concern. Older projects
either have all of §1–13 inside a single `CONTEXT.md`, or use the six-file split while §10 still
lives in `CONTEXT.md`. This step offers either refactor. It is **opt-in and never automatic** —
only move a file's sections when the owner approves that row.

### 5.5.1 Target shape
| File | Sections it owns | Owners |
|------|------------------|--------|
| `CONTEXT.md` | context map · §11 Workflow (minus §11.6) | all |
| `DEV.md` | §3 Architecture · §4 Tech Stack · §5 Repo · §6 Services · §7 Data Model | `DEV OPS` |
| `PRODUCT.md` | §1 Product Overview · §2 Key Decisions · §13 Open Questions | `STK BU PO` |
| `QA.md` | §9 Testing & Quality Gates (coverage gate, AC traceability, scenario standard) | `QA DEV OPS` |
| `SECURITY.md` | §8 Security Model · §11.6 `security-review` wiring | `DEV QA OPS` |
| `DESIGN.md` | §12 Design Tokens & Design System | `DEV` + design |
| `SKILLS.md` | §10 direct skill dependencies · invocation routes · ordering · fallbacks | all |

**Section numbers do not change.** A section keeps its number wherever it lives, so every `§N`
reference in existing plans, docs, ADRs, and notes still resolves. This is what makes the refactor
safe on a project with dozens of plans — **never renumber.**

### 5.5.2 Detect
Split applies when `CONTEXT.md` exists **and** it still contains a section owned by a missing
`DEV.md` / `PRODUCT.md` / `QA.md` / `SECURITY.md` / `DESIGN.md` / `SKILLS.md`. Report the state per file:
- **missing** → candidate to create by moving sections out of `CONTEXT.md`
- **exists** → leave alone; only backfill missing sections inside it (Step 5)
- **partial** (file exists but the section is still duplicated in `CONTEXT.md`) → flag the
  duplication explicitly; ask which copy is authoritative. Never silently pick one.
- **dangling pointer** (`CONTEXT.md` says `Moved to SKILLS.md` but `SKILLS.md` is missing) → stop
  that row and ask whether to recover §10 from version history, another branch/copy, or owner input.
  Do not replace potentially lost project-specific routing with template defaults.

### 5.5.3 Propose, per file
Present one row per proposed file **before writing anything**, and get an explicit yes/no on each.
The owner may split some files and not others.

| # | New file | Sections moved out of `CONTEXT.md` | Lines moved | Approve? |
|---|----------|------------------------------------|-------------|----------|
| 1 | `DEV.md` | §3–7 | <!-- n --> | |
| 2 | `PRODUCT.md` | §1, §2, §13 | <!-- n --> | |
| 3 | `QA.md` | §9 | <!-- n --> | |
| 4 | `SECURITY.md` | §8, §11.6 | <!-- n --> | |
| 5 | `DESIGN.md` | §12 | <!-- n --> | |
| 6 | `SKILLS.md` | §10 | <!-- n --> | |

Also list, in the same confirmation, every reference that will be rewritten (5.5.5) so the owner
sees the full blast radius up front.

### 5.5.4 Apply — move, never copy
For each approved file:
1. **Create** it from `../icontext-init/templates/<FILE>` — this supplies the header, the sibling
   links, the owners line, and the "keeping this in sync" footer. For `SKILLS.md`, initially keep
   only that scaffolding; do not retain the template §10 body before placing the owner's §10.
2. **Move the owner's existing section text in verbatim.** The owner's wording is the source of
   truth. Template scaffolding (extra sub-headings, empty tables, TODO prompts) is **additive
   only** — append it under the owner's content, or drop it if it would bury real text. Never
   reword, reorder, or "improve" what the owner wrote.
3. **Replace the section in `CONTEXT.md` with a pointer stub**, keeping the original heading so
   anchors and the reading order survive:
   ```markdown
   ### 9. Testing & Quality Gates
   ➜ **Moved to [QA.md](./QA.md) §9** — <one-line summary of what's there now>.
   ```
   Keep 2–4 headline bullets in the stub only when a reader genuinely needs them without opening
   the other file (e.g. the coverage gate). Everything else goes to the new file.
4. **Insert the context map** at the top of `CONTEXT.md` (§ → file → owners table) if it isn't
   there yet — it is what makes the split navigable.
5. **Verify no content was lost**: every heading present before the split must exist either in
   `CONTEXT.md` or in exactly one new file. Report the before/after heading count.

For `SKILLS.md`, the same rule is strict: move the owner's complete §10 verbatim first, then add
missing registry fields, invocation routes, or fallback guidance from the latest template only as
an approved additive backfill. Never replace a project-specific skill list with the template list.

🛑 **Never delete a section without it landing somewhere.** If a move can't be made cleanly (odd
nesting, a section that mixes two concerns), stop and ask the owner rather than guessing.

### 5.5.5 Rewrite references
After moving, update pointers so nothing dangles — additive edits only:
- **L1 files** (`CLAUDE.md`, selected `AGENTS.md`/`agents.md`, selected `AGENT.md`/`agent.md`,
  `GEMINI.md`) — add the six concern files to
  "Read first", and add the "one concern, one file" hard rule.
- **`CONTEXT.md` §11.3** — add the L2 sibling trigger table (which file to update for which change).
- **Plan role files** (`plans/*/`, `plans/_TEMPLATE/`) — retarget the `> ref:` lines:
  `bu.md`/`po.md` → `PRODUCT.md` · `qa.md` → `QA.md` · `ops.md` → `SECURITY.md` ·
  `dev.md` → `DEV.md` (+ `DESIGN.md` when the plan has UI).
- **Plan folder `README.md` files** — add `SKILLS.md` to the context references so the plan's
  discovery, review, security, and implementation routes resolve to the registry.
- **Bare `§3–7` / `§8` / `§9` / `§10` / `§11.6` / `§12` mentions** in prose → qualify them with the file name
  (`SECURITY.md §11.6`), since the number alone no longer says which file.
- Leave existing plan **content** untouched. Only the ref lines change.

### 5.5.6 If the owner declines
Leave the declined file's sections in `CONTEXT.md` exactly as they are and mark that row `skipped`
in the final gap table. Other independently approved rows may proceed. Do not re-ask about a
declined row on the next run beyond a one-line mention.

## Step 5.6 — Backfill and verify the agent mutation guard
Treat each item as a separate confirmed gap from Step 3:
1. Add missing `.icontext/hooks/guard-command.sh` and `POLICY.md` from the latest templates; preserve
   existing owner content and restore executable mode only when approved.
2. Patch missing L1 safety bullets and `CONTEXT.md` §11.7 additively.
3. Detect the active host's documented project-local pre-command/pre-tool hook. If it supports an
   interactive `ask` decision, show and confirm the exact merge into the existing hook config; never
   replace unrelated hooks or copy another vendor's config shape.
4. If no usable interactive hook exists, keep instruction enforcement and record
   `hook unavailable; policy enforced by instructions` rather than installing a dead-end blocker.
5. Verify `git status` allows while `git commit`, `git push`, a direct DB client, and a seed/migration
   command ask, first against the guard and then through the real host hook path when wired. These are
   dry-run payloads only; do not execute the restricted actions.

## Step 6 — Mandatory owner checks
Ask the owner only when a missing mandatory field would make the context misleading:
- Product description / purpose in §1
- Real service names in §6 when service templates must be created
- Repo strategy if the current context conflicts with generated scaffolding

Otherwise leave TODOs and report them.

## Step 7 — Report and stop
Output the final gap table with statuses: `created`, `patched`, `already present`, `todo`, or
`skipped`. Include hook status (`active and verified`, `wiring pending`, or `unavailable`) and
tell the user which files changed. Stop here; do not create a
feature plan and do not implement app code. If the owner accepted Step 1.5, continue only by handing
off to `/icontext-loadtest` as a separate workflow with its own page question and safety gates.
