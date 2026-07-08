# icontext-update — procedure (agent-neutral)

> Source of truth for updating an existing iContext project to the latest template shape.
> It is intentionally narrower than `icontext-init`: no greenfield scaffold, no feature plan,
> no implementation.

## Operating rules
- **Requires an existing project context.** If the target root has no `CONTEXT.md`, stop and tell
  the user to run `icontext-init` first.
- **Never overwrite owner-authored content.** Existing text is the source of truth. Add only missing
  files, headings, sections, or clearly missing workflow bullets.
- **Confirm every change before writing.** Inventory and planning can run without approval, but
  every file creation, section insertion, bullet append, or template patch must be shown to the user
  and explicitly confirmed before it is applied. Batch confirmations are allowed only when the user
  explicitly approves the listed batch.
- **Do not invent facts.** When a required value cannot be inferred, write `<!-- TODO: ... -->` or
  ask the owner if the field is mandatory for the backfill.
- **Keep the latest workflow visible.** Ensure the context mentions `/grill-with-docs` requirement
  discovery, `ROLE.md` multi-agent requirement review, and gstack `/autoplan` plan preparation.
- **Never commit / push** unless explicitly told.

## Step 0 — Update check
Run `check-update.sh` next to this file and surface its one-line result. Continue even if offline.

## Step 1 — Confirm update mode
At the target root, confirm `CONTEXT.md` exists. Then inventory the current iContext artifacts:
- L1 files: `CLAUDE.md`, `AGENTS.md`, `AGENT.md`, `GEMINI.md`
- L2: `CONTEXT.md`, `ROLE.md`
- L3/status: `PLAN.md`, `plans/README.md`, `plans/_TEMPLATE/`
- Shared scaffolding: `docs/openapi.yaml`, `styles/css/tokens.css`, `styles/components/`,
  `.vscode/launch.json`, `docker-compose.yml`
- Service guides: each service's `STRUCTURE.md` using the service names from `CONTEXT.md §6`

Use the latest source templates from the sibling path `../icontext-init/templates/`.

## Step 2 — Build a gap table
Create a gap table before editing. Do not write anything yet:

| Artifact / section | Current state | Action |
|--------------------|---------------|--------|
| `AGENTS.md` | missing | create from latest template |
| `CONTEXT.md §11.0` | missing | insert latest workflow subsection |

Track both file-level gaps and section-level gaps. For `CONTEXT.md`, check for the latest section
set: §1–13, §11.0 main workflow, §11.1 plan structure, §11.2 plan rules, §11.3 sync rule, §11.4
`/autoplan` review chain, and §11.5 implementation loop.

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
- **`CONTEXT.md`** — insert missing §1–13 sections or missing §11 subsections from the latest
  template. Preserve all existing text. If exact insertion is risky, append a clearly titled
  "Backfilled from latest iContext template" block near the relevant parent section.
- **`ROLE.md`** — ensure the Requirement Review Protocol exists. If absent, append it from the
  latest template so future plans can use multi-agent requirement review.
- **Plan templates** — ensure `plans/_TEMPLATE/README.md`, `bu.md`, `po.md`, `dev.md`, `qa.md`,
  `ops.md`, and `stk.md` exist and include the latest §4 Requirement Review / Persona Panel shape.
- **Indexes** — ensure `PLAN.md` and `plans/README.md` exist. Do not reorder existing plans.

When content is partially present, prefer the smallest additive patch: add the missing subsection,
bullet, or table row. Never normalize prose just to match the template.
Only apply section backfills that the user confirmed in Step 3. If a patch becomes materially
different from what was confirmed, stop and ask again before writing.

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
