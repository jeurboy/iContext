# icontext-update — procedure (agent-neutral)

> Source of truth for updating an existing iContext project to the latest template shape.
> It is intentionally narrower than `icontext-init`: no greenfield scaffold, no feature plan,
> no implementation.

## Operating rules
- **Requires an existing project context.** If the target root has no `CONTEXT.md`, stop and tell
  the user to run `icontext-init` first.
- **Never overwrite owner-authored content.** Existing text is the source of truth. Add only missing
  files, headings, sections, or clearly missing workflow bullets. The only structural changes this
  skill may make are the **L2 split** (Step 5.5) and the **L2 relocation into `context/`**
  (Step 5.7) — each only with explicit per-file approval, moving the owner's text verbatim and
  leaving a pointer stub / updated links behind.
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
- **L2 context (context map at the root + concern files in `context/`)**: `CONTEXT.md`,
  `context/DEV.md`, `context/PRODUCT.md`, `context/QA.md`, `context/SECURITY.md`,
  `context/DESIGN.md`, `context/SKILLS.md`, `context/ROLE.md`. A project still holding all of
  §1–13 in one `CONTEXT.md`, or a six-file project still holding §10 in `CONTEXT.md`, is a
  **split candidate** → Step 5.5. A project whose concern files or `ROLE.md` sit at the repo root
  instead of `context/` (the pre-1.17 layout) is a **relocate candidate** → Step 5.7.
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

Also propose, as ordinary additive template gaps, the `context/SKILLS.md` §10 rows and routes for
`icontext-feature-review` (plain-language plan review), `icontext-implement` (§11.5 execution to
`ready to test` with confirmed cheap-model implementer sub-agents), and `icontext-self-update`
(skill-package and dependency-skill updates) when the project's registry does not have them yet —
per-file approval as always. Updating the installed skill packages themselves is not this workflow's job; point the owner
to `/icontext-self-update`.

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
the `DEV.md` §5.2 execution-flow section in the same approved change), and the optional
user-invoked `poteto-mode` (pstack) workflow-stack row, invocation route, and §10.3 source/install
entry (an opt-in execution style that never replaces the required routes; when its row is missing,
backfill it together with its §10.3 upstream URL). A missing row or route
is a section-level additive gap, not a reason to replace the owner's registry.
Check the §10 source/install registry too: every external direct dependency needs a verified
upstream Git/source URL and install guidance. Treat a missing URL as an additive gap; never guess a
repository or replace an owner-pinned fork/ref without confirmation.

If `context/DEV.md` / `context/PRODUCT.md` / `context/QA.md` / `context/SECURITY.md` /
`context/DESIGN.md` / `context/SKILLS.md` are missing, inspect
whether their owned sections still exist in `CONTEXT.md` or in a **root-level legacy file**
(`DEV.md` at the repo root etc. — Step 5.7). Use `split out of CONTEXT.md (Step 5.5)`
only when there is owner text to move; use `relocate the root-level file into context/ (Step 5.7)`
when the file exists at the root; otherwise use `create from latest template (Step 4/5)`.
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
  templates, each into its owning file (`context/PRODUCT.md` §1/§2/§13 · `context/DEV.md` §3–7 ·
  `context/SKILLS.md` §10 · `CONTEXT.md` §11 · `context/SECURITY.md` §8/§11.6 · `context/QA.md` §9 ·
  `context/DESIGN.md` §12). On a not-yet-split project, insert into
  `CONTEXT.md` and offer the split separately (Step 5.5) — don't force it. If the only legacy
  ownership is §10 in `CONTEXT.md`, offer the `context/SKILLS.md` move instead of duplicating §10.
  Preserve all existing text. If exact insertion is risky, append a clearly titled
  "Backfilled from latest iContext template" block near the relevant parent section.
  For `SKILLS.md`, add only the approved missing registry row or invocation route (for example,
  `/investigate`) or source/install entry; never rewrite or reorder the owner's existing tables.
- **`context/ROLE.md`** — ensure the Requirement Review Protocol exists. If absent (or the file is
  still at the root, Step 5.7), append it from the
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
Latest iContext keeps Layer 2 as the **context map (`CONTEXT.md`) at the repo root plus six
concern files and `ROLE.md` in `context/`**, one per concern. Older projects either have all of
§1–13 inside a single `CONTEXT.md`, or use the six-file split while §10 still lives in
`CONTEXT.md`. This step offers either refactor. It is **opt-in and never automatic** — only move a
file's sections when the owner approves that row. New files are created **inside `context/`**; if
the concern files sit at the repo root today, pair this step with the relocation in Step 5.7 (or
run 5.7 first so the split lands directly in `context/`).

### 5.5.1 Target shape
| File | Sections it owns | Owners |
|------|------------------|--------|
| `CONTEXT.md` (repo root) | context map · §11 Workflow (minus §11.6) | all |
| `context/DEV.md` | §3 Architecture · §4 Tech Stack · §5 Repo · §6 Services · §7 Data Model | `DEV OPS` |
| `context/PRODUCT.md` | §1 Product Overview · §2 Key Decisions · §13 Open Questions | `STK BU PO` |
| `context/QA.md` | §9 Testing & Quality Gates (coverage gate, AC traceability, scenario standard) | `QA DEV OPS` |
| `context/SECURITY.md` | §8 Security Model · §11.6 `security-review` wiring | `DEV QA OPS` |
| `context/DESIGN.md` | §12 Design Tokens & Design System | `DEV` + design |
| `context/SKILLS.md` | §10 direct skill dependencies · invocation routes · ordering · fallbacks | all |

**Section numbers do not change.** A section keeps its number wherever it lives, so every `§N`
reference in existing plans, docs, ADRs, and notes still resolves. This is what makes the refactor
safe on a project with dozens of plans — **never renumber.**

### 5.5.2 Detect
Split applies when `CONTEXT.md` exists **and** it still contains a section owned by a missing
`context/DEV.md` / `context/PRODUCT.md` / `context/QA.md` / `context/SECURITY.md` /
`context/DESIGN.md` / `context/SKILLS.md`. Report the state per file:
- **missing** → candidate to create by moving sections out of `CONTEXT.md` (create it in `context/`)
- **exists** → leave alone; only backfill missing sections inside it (Step 5)
- **partial** (file exists but the section is still duplicated in `CONTEXT.md`) → flag the
  duplication explicitly; ask which copy is authoritative. Never silently pick one.
- **dangling pointer** (`CONTEXT.md` says `Moved to SKILLS.md` but `context/SKILLS.md` is missing) → stop
  that row and ask whether to recover §10 from version history, another branch/copy, or owner input.
  Do not replace potentially lost project-specific routing with template defaults.

### 5.5.3 Propose, per file
Present one row per proposed file **before writing anything**, and get an explicit yes/no on each.
The owner may split some files and not others.

| # | New file | Sections moved out of `CONTEXT.md` | Lines moved | Approve? |
|---|----------|------------------------------------|-------------|----------|
| 1 | `context/DEV.md` | §3–7 | <!-- n --> | |
| 2 | `context/PRODUCT.md` | §1, §2, §13 | <!-- n --> | |
| 3 | `context/QA.md` | §9 | <!-- n --> | |
| 4 | `context/SECURITY.md` | §8, §11.6 | <!-- n --> | |
| 5 | `context/DESIGN.md` | §12 | <!-- n --> | |
| 6 | `context/SKILLS.md` | §10 | <!-- n --> | |

Also list, in the same confirmation, every reference that will be rewritten (5.5.5) so the owner
sees the full blast radius up front.

### 5.5.4 Apply — move, never copy
For each approved file:
1. **Create** it from `../icontext-init/templates/context/<FILE>` — this supplies the header, the sibling
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
   ➜ **Moved to [QA.md](./context/QA.md) §9** — <one-line summary of what's there now>.
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
  `GEMINI.md`) — point the "Read first" entries at the `context/` concern files and add the
  "one concern, one file" hard rule.
- **`CONTEXT.md` §11.3** — add the L2 sibling trigger table (which file to update for which change),
  with links into `context/`.
- **Plan role files** (`plans/*/`, `plans/_TEMPLATE/`) — retarget the `> ref:` lines:
  `bu.md`/`po.md` → `context/PRODUCT.md` · `qa.md` → `context/QA.md` · `ops.md` →
  `context/SECURITY.md` · `dev.md` → `context/DEV.md` (+ `context/DESIGN.md` when the plan has UI).
- **Plan folder `README.md` files** — add `context/SKILLS.md` to the context references so the plan's
  discovery, review, security, and implementation routes resolve to the registry.
- **Bare `§3–7` / `§8` / `§9` / `§10` / `§11.6` / `§12` mentions** in prose → qualify them with the file name
  (`context/SECURITY.md` §11.6), since the number alone no longer says which file.
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

## Step 5.7 — Relocate legacy root-level L2 siblings into `context/`
Projects created before v1.17 keep the concern files (`DEV.md`, `PRODUCT.md`, `QA.md`,
`SECURITY.md`, `DESIGN.md`, `SKILLS.md`) and `ROLE.md` directly at the repo root. The latest
layout keeps `CONTEXT.md` at the root as the L2 entry point and holds everything else in
`context/`. This step offers that move. Like Step 5.5 it is **opt-in and never automatic**, and
it is a pure relocation: file contents stay verbatim apart from the link fixes below — never
reword, reorder, or "improve" owner text while moving. On a still-monolithic project, don't run
5.5 and then 5.7 as a double move — Step 5.5 now creates the new files directly in `context/`.

### 5.7.1 Detect
Relocation applies when any of `DEV.md`, `PRODUCT.md`, `QA.md`, `SECURITY.md`, `DESIGN.md`,
`SKILLS.md`, or `ROLE.md` exists **at the repo root**. Report per file:
- **at root** → candidate to move to `context/<FILE>`
- **already in `context/`** → leave alone
- **both** (e.g. `DEV.md` at the root and `context/DEV.md`) → stop that row and ask which copy is
  authoritative; never merge or delete one silently.

### 5.7.2 Propose, per file
Present one row per root-level file **before writing anything**, and get an explicit yes/no on
each. The owner may move some files and not others. Also list the inbound references that will be
rewritten (5.7.3) so the owner sees the blast radius up front.

| # | Move | Approve? |
|---|------|----------|
| 1 | `DEV.md` → `context/DEV.md` | |
| 2 | `PRODUCT.md` → `context/PRODUCT.md` | |
| 3 | `QA.md` → `context/QA.md` | |
| 4 | `SECURITY.md` → `context/SECURITY.md` | |
| 5 | `DESIGN.md` → `context/DESIGN.md` | |
| 6 | `SKILLS.md` → `context/SKILLS.md` | |
| 7 | `ROLE.md` → `context/ROLE.md` | |

### 5.7.3 Apply — move files, fix links
For each approved file:
1. Create `context/` if needed, then **move** the file into it (a rename-aware move such as
   `git mv` keeps history; a plain move is fine too). Staging is allowed; never commit (§11.7).
2. Fix relative links **inside** the moved file: sibling links (`./DEV.md`, `./QA.md`, …) stay
   valid because the siblings move together; links to `CONTEXT.md`, `PLAN.md`, `.icontext/`,
   `docs/`, `styles/` gain a `../` prefix (`./CONTEXT.md` → `../CONTEXT.md`).
3. Rewrite inbound references — link-only, additive edits; never rewrite prose:
   - `CONTEXT.md` — context-map table, `➜ Moved to …` stubs, §11.0 read list, §11.3 trigger
     table: `./DEV.md` → `./context/DEV.md` etc.
   - L1 files — "Read first" entries and hard-rule path mentions → `context/<FILE>`.
   - Plan role files and plan folder `README.md` — `../../DEV.md` → `../../context/DEV.md` etc.
   - Any other doc that links to the moved files — find them with a repo-wide search before
     declaring the move done.
4. **Verify nothing dangles:** re-run a repo-wide search for the old paths
   (`](./DEV.md)`, `](../../DEV.md)`, `](DEV.md)`) and confirm no both-copies conflict remains.
5. Report each moved file and the rewritten references in the final gap table.

If the owner declines, leave the files at the root, mark the row `skipped`, and keep reading the
concern files wherever they live — a root-level sibling is a legacy layout, not a defect.

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
