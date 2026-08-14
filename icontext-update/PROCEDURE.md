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
  requirements), `ROLE.md` multi-agent requirement review, and gstack `/autoplan` plan preparation.
- **Never commit / push** unless explicitly told.

## Step 0 — Update check
Run `check-update.sh` next to this file and surface its one-line result. Continue even if offline.

## Step 1 — Confirm update mode
At the target root, confirm `CONTEXT.md` exists. Then inventory the current iContext artifacts:
- L1 files: `CLAUDE.md`, `AGENTS.md`, `AGENT.md`, `GEMINI.md`
- **L2 context (6 files, split by concern)**: `CONTEXT.md`, `DEV.md`, `PRODUCT.md`, `QA.md`, `SECURITY.md`,
  `DESIGN.md` — plus `ROLE.md`. A project still holding all of §1–13 in one `CONTEXT.md` is a
  **split candidate** → Step 5.5
- L3/status: `PLAN.md`, `plans/README.md`, `plans/_TEMPLATE/`
- Shared scaffolding: `docs/openapi.yaml`, `styles/css/tokens.css`, `styles/components/`,
  `.vscode/launch.json`, `docker-compose.yml`
- Service guides: each service's `STRUCTURE.md` using the service names from `DEV.md §6`

Use the latest source templates from the sibling path `../icontext-init/templates/`.

## Step 2 — Build a gap table
Create a gap table before editing. Do not write anything yet:

| Artifact / section | Current state | Action |
|--------------------|---------------|--------|
| `AGENTS.md` | missing | create from latest template |
| `CONTEXT.md §11.0` | missing | insert latest workflow subsection |

Track both file-level gaps and section-level gaps. Check for the latest section set §1–13 **across
the L2 files** (a section counts as present wherever it lives): §11.0 main workflow, §11.1 plan
structure, §11.2 plan rules, §11.3 sync rule + L2 sibling triggers, §11.4 `/autoplan` review chain,
§11.5 implementation loop, and §11.6 `security-review` phase wiring.

If `DEV.md` / `PRODUCT.md` / `QA.md` / `SECURITY.md` / `DESIGN.md` are missing, add a row per file with the
action `split out of CONTEXT.md (Step 5.5)` — and treat it as a proposal, not a decision.

## Step 3 — Confirm the change plan
Before editing, present the planned changes in a confirmation table:

| # | File | Change type | Why | Proposed action |
|---|------|-------------|-----|-----------------|
| 1 | `AGENTS.md` | create | Codex L1 file missing | copy latest template with inferred vars |
| 2 | `CONTEXT.md` | patch | §11.0 missing | insert latest main workflow subsection |

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
Only apply file backfills that the user confirmed in Step 3.

## Step 5 — Backfill missing sections
Patch only missing sections/headings:
- **L2 files** — insert missing §1–13 sections or missing §11 subsections from the latest
  templates, each into its owning file (`PRODUCT.md` §1/§2/§13 · `DEV.md` §3–7 · `CONTEXT.md` §10/§11 ·
  `SECURITY.md` §8/§11.6 · `QA.md` §9 · `DESIGN.md` §12). On a not-yet-split project, insert into
  `CONTEXT.md` and offer the split separately (Step 5.5) — don't force it.
  Preserve all existing text. If exact insertion is risky, append a clearly titled
  "Backfilled from latest iContext template" block near the relevant parent section.
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

## Step 5.5 — Refactor a monolithic `CONTEXT.md` into the L2 split
Latest iContext splits Layer 2 into **six files at the repo root**, one per concern. Older projects
have all of §1–13 inside a single `CONTEXT.md`. This step offers that refactor. It is **opt-in and
never automatic** — a monolithic context is still valid; only split when the owner says so.

### 5.5.1 Target shape
| File | Sections it owns | Owners |
|------|------------------|--------|
| `CONTEXT.md` | context map · §10 Skills · §11 Workflow (minus §11.6) | all |
| `DEV.md` | §3 Architecture · §4 Tech Stack · §5 Repo · §6 Services · §7 Data Model | `DEV OPS` |
| `PRODUCT.md` | §1 Product Overview · §2 Key Decisions · §13 Open Questions | `STK BU PO` |
| `QA.md` | §9 Testing & Quality Gates (coverage gate, AC traceability, scenario standard) | `QA DEV OPS` |
| `SECURITY.md` | §8 Security Model · §11.6 `security-review` wiring | `DEV QA OPS` |
| `DESIGN.md` | §12 Design Tokens & Design System | `DEV` + design |

**Section numbers do not change.** A section keeps its number wherever it lives, so every `§N`
reference in existing plans, docs, ADRs, and notes still resolves. This is what makes the refactor
safe on a project with dozens of plans — **never renumber.**

### 5.5.2 Detect
Split applies when `CONTEXT.md` exists **and** any of `DEV.md` / `PRODUCT.md` / `QA.md` / `SECURITY.md` /
`DESIGN.md` is missing. Report the state per file:
- **missing** → candidate to create by moving sections out of `CONTEXT.md`
- **exists** → leave alone; only backfill missing sections inside it (Step 5)
- **partial** (file exists but the section is still duplicated in `CONTEXT.md`) → flag the
  duplication explicitly; ask which copy is authoritative. Never silently pick one.

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

Also list, in the same confirmation, every reference that will be rewritten (5.5.5) so the owner
sees the full blast radius up front.

### 5.5.4 Apply — move, never copy
For each approved file:
1. **Create** it from `../icontext-init/templates/<FILE>` — this supplies the header, the sibling
   links, the owners line, and the "keeping this in sync" footer.
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

🛑 **Never delete a section without it landing somewhere.** If a move can't be made cleanly (odd
nesting, a section that mixes two concerns), stop and ask the owner rather than guessing.

### 5.5.5 Rewrite references
After moving, update pointers so nothing dangles — additive edits only:
- **L1 files** (`CLAUDE.md`, `AGENTS.md`, `AGENT.md`, `GEMINI.md`) — add the five concern files to
  "Read first", and add the "one concern, one file" hard rule.
- **`CONTEXT.md` §11.3** — add the L2 sibling trigger table (which file to update for which change).
- **Plan role files** (`plans/*/`, `plans/_TEMPLATE/`) — retarget the `> ref:` lines:
  `bu.md`/`po.md` → `PRODUCT.md` · `qa.md` → `QA.md` · `ops.md` → `SECURITY.md` ·
  `dev.md` → `DEV.md` (+ `DESIGN.md` when the plan has UI).
- **Bare `§3–7` / `§8` / `§9` / `§11.6` / `§12` mentions** in prose → qualify them with the file name
  (`SECURITY.md §11.6`), since the number alone no longer says which file.
- Leave existing plan **content** untouched. Only the ref lines change.

### 5.5.6 If the owner declines
Leave the monolithic `CONTEXT.md` exactly as it is and mark the row `skipped` in the final gap
table. Do not partially split, and do not re-ask on the next run beyond a one-line mention.

## Step 6 — Mandatory owner checks
Ask the owner only when a missing mandatory field would make the context misleading:
- Product description / purpose in §1
- Real service names in §6 when service templates must be created
- Repo strategy if the current context conflicts with generated scaffolding

Otherwise leave TODOs and report them.

## Step 7 — Report and stop
Output the final gap table with statuses: `created`, `patched`, `already present`, `todo`, or
`skipped`. Summarize TODOs and tell the user which files changed. Stop here; do not create a
feature plan and do not implement app code.
