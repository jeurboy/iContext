# icontext-feature — procedure (agent-neutral)

> Source of truth for the `icontext-feature` workflow. Any agent executes these steps.
> Requires a project initialized by `icontext-init` (has `CONTEXT.md`, `plans/`, `PLAN.md`, `ROLE.md`).

Create one feature plan using the standard structure. **Stop at the plan — do not implement.**

## Operating rules
- Never `git commit` / `git push` unless explicitly told.
- Every plan **must ref `CONTEXT.md`** and carry a task status:
  `to do → plan → ready to implement → implement → ready to test → done`.
- The plan structure is defined in **CONTEXT.md §11.1** (sections 0–11 with role owners).
- Requirement workflow is part of the plan, not optional polish: gather a brief, run
  `/grill-with-docs` (or equivalent), then review the requirement through `ROLE.md` before locking
  scope or writing final plan content.

## Step 0 — Update check (every run)
Run `check-update.sh` (next to this file) and surface its one line. Best-effort: compares local
`VERSION` to the published one; never blocks (offline/unpublished prints "skipped"). If an
update is available, mention it, then continue.

## Step 1 — Preconditions + required scaffolding
1. Confirm `CONTEXT.md`, `plans/`, `PLAN.md` exist. If not, tell the user to run `icontext-init` first.
2. **Check the required scaffolding before planning.** For each artifact below, if it is missing,
   **ASK the user whether to create it now** (one prompt, multi-select is fine). Do not create
   silently and do not block — if the user declines, note it and continue.
   - **Style guide** — `styles/css/tokens.css` + `styles/components/`. Create from
     `icontext-init`'s `templates/styles/`.
   - **API spec** — `docs/openapi.yaml` (a.k.a. `openapi.yml`). Create from `icontext-init`'s
     `templates/docs/openapi.yaml`.
   - **VS Code launch config** — `.vscode/launch.json`. Create from `icontext-init`'s
     `templates/.vscode/launch.json` (substitute `{{VARS}}`).
   Create only the artifacts the user approves, then proceed to Step 2.

## Step 2 — Next plan number
List the `plans/NNN-*/` folders, take the highest `NNN`, +1 (zero-padded, 3 digits).
`_TEMPLATE/` and `README.md` don't count.

## Step 3 — Gather the minimal brief
Ask: feature name (→ slug), one-paragraph intent, services touched (use the real service names from
`CONTEXT.md §6`, not hard-coded api/web/app), known constraints, and the user-visible outcome.
Keep this short; the grill expands it.

## Step 3.5 — Grill requirements (required, every run)
Before writing plan content, run a **grilling / stress-test pass**: interview the user about this
feature until the decision tree is resolved, and sharpen domain terminology + record decisions into
`CONTEXT.md` + ADRs (`docs/adr/`) as you go. Proceed only once the key decisions settle.
- **Claude Code**: run the `/grill-with-docs` skill (falls back to `/grill-me` or `/grilling` if not installed).
- **Other agents**: do the equivalent — relentless Q&A on scope, edge cases, and trade-offs (give a
  recommended answer per question), then capture the resolved terms/decisions into `CONTEXT.md` + `docs/adr/`.

## Step 4 — ROLE.md requirement review (required)
Read `ROLE.md` and review the grilled requirement before locking scope.
- If the agent supports subagents, dispatch one reviewer per role/persona (BU/PO/DEV/QA/OPS/STK or
  the concrete personas in `ROLE.md`) and merge the results.
- If subagents are unavailable, emulate separate role passes in one response.
- Each reviewer returns: Works · Concern · Suggestion · Plan impact.
- Put the output in the plan's **§4.1 Requirement Review** (`stk.md`) and fold accepted changes into
  the relevant role files before Step 6.

Optional: ask whether to run an additional lightweight persona panel. If yes, put it in **§4.2
Persona Panel**; if no, mark §4.2 as skipped.

## Step 5 — Write the plan (a folder split by role)
A plan is a **folder** `plans/NNN-<slug>/`, not a single file. Copy the project's
`plans/_TEMPLATE/` (or this skill's `templates/plan-template/`) to `plans/NNN-<slug>/`. It
contains role files; each of sections 0–11 lives in exactly one (map = CONTEXT.md §11.1):
- `bu.md` — 0 Decisions · 1 Goal · Use Cases · User Stories · Acceptance Criteria · Definition of Done
- `po.md` — 2 Scope · 3 User Stories (mandatory) · 10 Tasks/Checklist · 11 Open Questions
- `dev.md` — 5 Tech & Architecture · 6 Data Model/Schema · Migration scripts · 7 API Contract · API changes · Pages/routes
- `qa.md` — 9 Test Plan (>80%) · acceptance criteria · Test Scenarios · Test Cases · Test Status · Test Coverage
- `ops.md` — 8 Security & Privacy · Deploy/Migrations
- `stk.md` — 4 Requirement Review / Persona Panel
- `README.md` — folder index + **canonical Task status** + owner/created

Fill what you know; leave unknowns as `<!-- TODO -->`. In `README.md` set `Task status: plan`
(the plan now exists; → `ready to implement` after the review chain); every file refs
`../../CONTEXT.md`. Put the §4 requirement review / persona output (Step 4) into `stk.md`, and
apply accepted changes from the role review into `bu.md`, `po.md`, `dev.md`, `qa.md`, and `ops.md`.

## Step 6 — Register status in 3 places
Add the new plan (task status `plan`) to **both** `plans/README.md` (the index) and root `PLAN.md`.
The rule "update status in 3 places" applies on every later status change too:
the plan folder's `README.md` · `plans/README.md` · `PLAN.md`.

## Step 7 — Prepare the plan with `/autoplan`
Run gstack `/autoplan` to review scope, architecture, design (if UI), and developer experience (if
developer-facing). If `/autoplan` is unavailable, run the individual plan review skills listed in
`CONTEXT.md §11.4`. Apply accepted review changes before implementation. The plan remains
`Task status: plan` until those changes are applied; then move it to `ready to implement` only when
the user asks to proceed toward implementation or confirms the review outcomes. On any status
change, update all three status locations from Step 6.

## Step 8 — Stop
Report the new plan path + status and whether `/autoplan` has already been applied. Do not implement.
(Reminder of `done` gates: API spec synced,
User Stories complete, tests > 80%.)
