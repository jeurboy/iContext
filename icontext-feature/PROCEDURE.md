# icontext-feature — procedure (agent-neutral)

> Source of truth for the `icontext-feature` workflow. Any agent executes these steps.
> Requires a project initialized by `icontext-init` (has `CONTEXT.md`, `plans/`, `PLAN.md`, `ROLE.md`).

Create one feature plan using the standard structure. **Stop at the plan — do not implement.**

## Operating rules
- Never `git commit` / `git push` unless explicitly told.
- Every plan **must ref `CONTEXT.md`** and carry a status: `todo → implement → ready to test → done`.
- The plan structure is defined in **CONTEXT.md §11.1** (sections 0–11 with role owners).

## Step 1 — Preconditions
Confirm `CONTEXT.md`, `plans/`, `PLAN.md` exist. If not, tell the user to run `icontext-init` first.

## Step 2 — Next plan number
List `plans/NNN-*.md`, take the highest `NNN`, +1 (zero-padded, 3 digits). `_TEMPLATE.md` and
`README.md` don't count.

## Step 3 — Gather the brief
Ask: feature name (→ slug), one-paragraph intent, services touched (api/web/app). Keep short.

## Step 4 — Persona panel (ask every time)
Ask: "Run a Persona Panel review with `ROLE.md` for this feature?"
- Yes → for each persona output ✅ works / ⚠️ concern / 💡 suggestion, specific to the feature;
  put it in the plan's **§4 Persona Panel**.
- No → leave §4 as `<!-- skipped -->`.

## Step 5 — Write the plan
Copy the project's `plans/_TEMPLATE.md` (or this skill's `templates/plan-template.md`) to
`plans/NNN-<slug>.md`. Fill what you know; leave unknowns as `<!-- TODO -->`. All sections
present (each shows its role owners from §11.1):
0 Decisions · 1 Goal · 2 Scope · 3 User Stories (mandatory) · 4 Persona Panel ·
5 Tech & Architecture · 6 Data Model/Schema · 7 API Contract · 8 Security & Privacy ·
9 Test Plan (>80%) · 10 Tasks/Checklist · 11 Open Questions.
Set `Status: todo` and the `ref` to `CONTEXT.md`.

## Step 6 — Register status in 3 places
Add the new plan (status `todo`) to **both** `plans/README.md` and root `PLAN.md`. The rule
"update status in 3 places" applies on every later status change too (plan file · README · PLAN.md).

## Step 7 — Stop
Report the new plan path + status. Do not implement. (Reminder of `done` gates: API spec synced,
User Stories complete, tests > 80%.)
