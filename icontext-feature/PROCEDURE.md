# icontext-feature — procedure (agent-neutral)

> Source of truth for the `icontext-feature` workflow. Any agent executes these steps.
> Requires a project initialized by `icontext-init` (has `CONTEXT.md`, `plans/`, `PLAN.md`,
> `context/ROLE.md`).

Create one feature plan using the standard structure. If the request extends or changes a
feature that **already has a plan**, the output is a **CR** (`CR-<M>.md`) inside that plan's
folder instead of a new plan (Step 2). **Stop at the plan/CR — do not implement.**

## Operating rules
- Never `git commit` / `git push` unless explicitly told.
- Every plan **must ref `CONTEXT.md`** and carry a task status:
  `to do → plan → ready to implement → implement → ready to test → done`.
- A change to a feature that **already has a plan** (any status, including `done`) is a
  **CR** — a single `CR-<M>.md` file inside that plan's folder, linking back to the original
  plan — **not** a new plan folder/number (routing in Step 2).
- The plan structure is defined in **CONTEXT.md §11.1** (sections 0–11 with role owners).
- Requirement workflow is part of the plan, not optional polish: gather a brief, ask the user to
  choose a discovery route (`/grill-with-docs` or `/wayfinder`), run the selected route, then review
  the requirement through `context/ROLE.md` before locking scope or writing final plan content.

## Step 0 — Update check (every run)
Run `check-update.sh` (next to this file) and surface its one line. Best-effort: compares local
`VERSION` to the published one; never blocks (offline/unpublished prints "skipped"). If an
update is available, mention it, then continue.

## Step 1 — Preconditions + required scaffolding
1. Confirm `CONTEXT.md`, `plans/`, `PLAN.md` exist. If not, tell the user to run `icontext-init` first.
1b. **Read the L2 context the feature touches**, not just `CONTEXT.md`. The concern files live in
   `context/`: `context/PRODUCT.md` (§1–2) always;
   `context/SKILLS.md` (§10) always before selecting requirement, review, security, or implementation skills;
   `context/DEV.md` (§3–7) for architecture, services, API, or data-model work;
   `context/QA.md` (§9) before writing the test plan; `context/SECURITY.md` (§8) if the feature adds a route, page,
   role, or dependency; `context/DESIGN.md` (§12) if it has UI. On an older project these sections
   may all still be inside `CONTEXT.md` or the concern files may sit at the repo root — that's
   fine, read them where they are and mention that `icontext-update`
   can split/relocate them (Steps 5.5/5.7). A six-file project may have only §10 left in `CONTEXT.md`; read it there and
   mention `icontext-update` can move it into `context/SKILLS.md`.
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

## Step 2 — Route: new plan or CR on an existing plan
List the `plans/NNN-*/` folders (`_TEMPLATE/` and `README.md` don't count), then route:

- **New capability, no owning plan** → new plan: take the highest `NNN`, +1 (zero-padded,
  3 digits). Continue as written below.
- **Extends or changes a feature that already has a plan** (any status — including a closed
  `done` plan) → **CR mode**: do **not** open a new plan folder or number. Write a single
  **CR file inside the existing plan folder** instead:
  1. Find the owning plan from the brief + `plans/README.md`. If several plans look like the
     owner — or none obviously is — ask the user; don't guess.
  2. Next CR number = highest existing `CR-*.md` in that folder + 1 (`CR-1`, `CR-2`, …).
  3. Write `plans/NNN-<slug>/CR-<M>.md` from this skill's `templates/cr-template.md` (a
     project's `plans/_TEMPLATE/` predating CR support won't carry it — always use the
     skill's template). The CR **must declare the link back to the original plan**: plan
     number + name, its current status, and what it reuses from the original — it extends
     the original plan; it is not a new plan.
  4. CR carries only the **delta**: decisions (`D-CR<M>-#`), design changes per layer, ACs,
     tasks, and its own status line (same lifecycle as a plan). Leave the original plan
     files untouched — the only additions to the folder are the CR file and the CR table
     in its `README.md`.

Routing is confirmed from the Step 3 brief: if the brief reveals the feature already has a
plan, switch to CR mode before writing anything. When in doubt (the request could be read
as either a new feature or an extension), ask the user.

## Step 3 — Gather the minimal brief
Ask: feature name (→ slug), one-paragraph intent, services touched (use the real service names from
`context/DEV.md §6`, not hard-coded api/web/app), known constraints, and the user-visible outcome.
Keep this short; the selected discovery route expands it.

## Step 3.5 — Choose + run requirement discovery (required, every run)
Before writing plan content, ask the user to choose the discovery route. Make a recommendation, but
let the user decide:

- **`/grill-with-docs`** — recommended when the feature direction is mostly visible and can fit in
  one planning session, but scope, edge cases, terminology, or ADR/context decisions need sharpening.
- **`/wayfinder`** — recommended when the effort is larger than one agent session can hold, the
  destination is visible but the route/solution is foggy, or the work likely needs multiple
  decision, research, prototype, or task tickets before a useful plan can exist.

Then run the selected route:

- **If `/grill-with-docs` is selected:** interview the user until the decision tree is resolved, and
  sharpen domain terminology + record decisions into `CONTEXT.md` + ADRs (`docs/adr/`) as you go.
  Proceed only once the key decisions settle.
- **If `/wayfinder` is selected:** chart or continue the Wayfinder map. Record the map name/link,
  destination, decisions so far, and any planning-critical frontier tickets in the future plan's
  §4.0 (`stk.md`). If Wayfinder reports no fog, ask whether to continue with `/grill-with-docs` and
  proceed in the same run. If the map has unresolved planning-critical tickets, stop before Step 4/5;
  do not create the iContext plan until those decisions are resolved enough to write a useful plan.
- **If companion skills are unavailable:** run the equivalent manually. For grill, ask one question
  at a time with a recommended answer and capture decisions into `CONTEXT.md` + ADRs. For wayfinding,
  create a local markdown map with Destination, Notes, Decisions so far, Not yet specified, Out of
  scope, and ticket-like questions sized to one agent session.

## Step 4 — ROLE.md requirement review (required)
Read `context/ROLE.md` (root-level `ROLE.md` on a pre-1.17 project) and review the discovered
requirement before locking scope.
- If the agent supports subagents, dispatch one reviewer per role/persona (BU/PO/DEV/QA/OPS/STK or
  the concrete personas in `context/ROLE.md`) and merge the results.
- If subagents are unavailable, emulate separate role passes in one response.
- Each reviewer returns: Works · Concern · Suggestion · Plan impact.
- Put the selected discovery route and outcome in the plan's **§4.0 Requirement Discovery** (`stk.md`),
  put the review output in **§4.1 Requirement Review**, and fold accepted changes into the relevant
  role files before Step 6. **CR mode:** same two steps apply — the discovery decisions and the
  panel output go into the CR file's **Requirement discovery** and **Persona panel** sections
  instead of `stk.md`.

Optional: ask whether to run an additional lightweight persona panel. If yes, put it in **§4.2
Persona Panel**; if no, mark §4.2 as skipped.

## Step 5 — Write the plan (a folder split by role)
*(New plans only — in CR mode the CR file was created in Step 2 and this step is skipped.)*
A plan is a **folder** `plans/NNN-<slug>/`, not a single file. Copy the project's
`plans/_TEMPLATE/` (or this skill's `templates/plan-template/`) to `plans/NNN-<slug>/`. It
contains role files; each of sections 0–11 lives in exactly one (map = CONTEXT.md §11.1):
- `bu.md` — 0 Decisions · 1 Goal · Use Cases · User Stories · Acceptance Criteria · Definition of Done
- `po.md` — 2 Scope · 3 User Stories (mandatory) · 10 Tasks/Checklist · 11 Open Questions
- `dev.md` — 5 Tech & Architecture · 6 Data Model/Schema · Migration scripts · 7 API Contract · API changes · Pages/routes
- `qa.md` — 9 Test Plan (>80%) · acceptance criteria (every case traces to an AC id) · Test Scenarios · Test Cases · Scenario checklist · Test Status · Test Coverage (standard: `context/QA.md` §9)
- `ops.md` — 8 Security & Privacy · Deploy/Migrations (model + review wiring: `context/SECURITY.md` §8, §11.6)
- `stk.md` — 4 Requirement Discovery / Requirement Review / Persona Panel
- `README.md` — folder index + **canonical Task status** + owner/created

Fill what you know; leave unknowns as `<!-- TODO -->`. In `README.md` set `Task status: plan`
(the plan now exists; → `ready to implement` after the review chain); every file refs
`../../CONTEXT.md` plus the L2 concern file for its role (`bu.md`/`po.md` → `context/PRODUCT.md` ·
`qa.md` → `context/QA.md` · `ops.md` → `context/SECURITY.md` · `dev.md` → `context/DEV.md` and, when there's UI,
`context/DESIGN.md`); the
template ref lines already carry these. **Never copy an L2 section into the plan — link to it.**
Put the §4 discovery route + requirement review / persona output (Steps 3.5–4)
into `stk.md`, and apply accepted changes from the role review into `bu.md`, `po.md`, `dev.md`,
`qa.md`, and `ops.md`.

## Step 6 — Register status in 3 places
Add the new plan (task status `plan`) to **both** `plans/README.md` (the index) and root `PLAN.md`.
The rule "update status in 3 places" applies on every later status change too:
the plan folder's `README.md` · `plans/README.md` · `PLAN.md`.

**CR mode:** the CR file's own status line is canonical. Register it by adding a **CR table**
(row: `CR-<M>` · title · status) to the original plan folder's `README.md`, then mirror the CR
in `plans/README.md` and `PLAN.md` as a sub-entry of the owning plan (e.g.
`032-promotion-engine — CR-1 (plan)`). Every later CR status change updates those same places.

## Step 7 — Prepare the plan with `/autoplan` + plan-phase security review
Run gstack `/autoplan` to review scope, architecture, design (if UI), and developer experience (if
developer-facing). If `/autoplan` is unavailable, run the individual plan review skills listed in
`CONTEXT.md §11.4`. Apply accepted review changes before implementation.

Then run the **plan-phase security review** (`context/SECURITY.md` §11.6): the `security-review` skill's
**supply-chain** sub-skill, against the dependencies / build / release surface this plan proposes.
Record the real detector output in `ops.md` §8.1 — findings, and for each high/critical one either
the fix or an explicit accepted-risk decision with its reason. If `security-review` isn't installed
(https://github.com/ice-limited/security-skill), say so and note that in `ops.md` §8.1 rather than
reviewing the supply chain by eye and calling it done.

The plan remains
`Task status: plan` until those changes are applied; then move it to `ready to implement` only when
the user asks to proceed toward implementation or confirms the review outcomes. On any status
change, update all three status locations from Step 6.

**CR mode:** run the same preparation when the CR adds new surface (dependencies, routes, data
model); for a small delta the user may skip `/autoplan` — if so, record the skip and why in the
CR file. The CR's status line follows the same rule: `plan` until review changes are applied.

## Step 8 — Stop
Report the new plan path + status and whether `/autoplan` has already been applied. **CR mode:**
report the CR path instead (`plans/NNN-<slug>/CR-<M>.md`) + the owning plan it links back to.
If the run stopped at an unresolved `/wayfinder` map, report the map path/link, next frontier
ticket, and that no iContext plan was created yet. Do not implement.
(Reminder of `done` gates: API spec synced,
User Stories complete, tests > 80%, security review clean — no unresolved high/critical finding.)
