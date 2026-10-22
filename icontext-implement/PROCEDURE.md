# icontext-implement — procedure (agent-neutral)

> Source of truth for the `icontext-implement` workflow. Any agent executes these steps.
> Requires a project initialized by `icontext-init` and a plan folder `plans/NNN-<slug>/`
> (plus any `CR-*.md`) that is already `ready to implement`.
>
> This skill **orchestrates** the CONTEXT.md §11.5 implementation loop — it does not hand-write
> every slice itself. Implementer **sub-agents on a low-effort/cheap model** write the code; this
> orchestrator slices, reviews, tests, and runs the security/quality gates.

Take one plan from `ready to implement` (or resume `implement`) through the §11.5 loop to
`ready to test`. Keep §11.3 in sync as you go (context · plan · doc · style · data model).

## Operating rules
- **Spawn gate (mandatory):** never launch an implementer sub-agent without an explicit user
  confirmation **for that spawn** — count, scope per agent, and model/effort level are shown and
  confirmed every time. This includes retries, fixes, and re-spawns. No silent spawns, no
  "same as last time" defaults. More than one agent per slice is allowed (split by file/service
  boundary so scopes don't overlap); each one is confirmed individually.
- **Cheap implementers, strong orchestrator:** implementer sub-agents run on the cheapest capable
  model / lowest sensible effort. Judgement stays here: slicing, plan conformance, test verdicts,
  security findings, and status transitions are never delegated to the cheap model.
- **The §11.5 loop order is canonical** (slice → implement → test → retest → owner review →
  security review → fold feedback). External executor skills (e.g. mattpocock `implement`) only
  execute the "implement the slice" step inside that order — DEV.md §5.2.
- **§11.7 mutation gates override everything:** no commit, push, or direct DB/migration/seed
  action without a per-invocation confirmation, even when an external skill's defaults say
  otherwise.
- Status lifecycle: `ready to implement` → **`implement`** (set on first change) →
  **`ready to test`** when every slice is green. Every status change updates all three places:
  plan folder `README.md` · `plans/README.md` · `PLAN.md`.
- Run to completion when nothing blocks: keep looping slices until the plan reaches
  `ready to test`. Stop honestly at a blocker (failed gate, unanswered open question, missing
  dependency, owner unavailable) — record it in the plan (`po.md` §11 / task notes) and report.

## Step 0 — Update check (every run)
Run `check-update.sh` (next to this file) and surface its one line. Best-effort; never blocks.
If an update is available, mention it, then continue.

## Step 1 — Preconditions + pick the plan
1. Confirm `CONTEXT.md`, `plans/`, `PLAN.md` exist; otherwise point to `icontext-init`.
2. List `plans/` and resolve the target plan from the user's words (number, slug, or title);
   ambiguous → ask. Read the plan folder `README.md` (status + CR table) and every pending
   `CR-*.md` — their tasks and ACs are part of the scope.
3. Route by status:
   - `ready to implement` or `implement` → continue.
   - `plan` → stop: the §11.4 review chain (`/autoplan` + plan-phase security review) has not
     finished; finish it via `icontext-feature` Step 7 first.
   - `to do` → no plan content exists yet; point to `icontext-feature`.
   - `ready to test` / `done` → only resume if the user explicitly asks (e.g. a re-open or a new
     CR made it active again); confirm with the user first.
4. Read the L2 context the plan touches (PRODUCT.md · SKILLS.md §10 always; DEV.md §3–7 for
   technical work; DESIGN.md §12 if UI; SECURITY.md §8 before the first slice; QA.md §9 before
   writing/running tests).

## Step 2 — Summarize the plan first via `/icontext-feature-review`
Before any code: run `/icontext-feature-review` on the chosen plan (chat summary, audience `dev`
unless the user says otherwise) so the orchestrator, the user, and later the implementer briefs
all share one picture: goal · decisions · scope · story→AC→test trace · technical view ·
cross-check verdict.
- If `icontext-feature-review` is not installed, produce the same summary manually from the plan
  folder following its template shape (requirement view + technical view + cross-checks).
- Treat the review's ❌/⚠️ cross-check findings and blocking open questions as pre-flight input:
  surface them to the user and record any accepted risk in the plan before slicing. A blocker
  here stops the run before code exists.

## Step 3 — Slice the plan into verifiable units
From `po.md` §10 tasks (+ pending CR task lists) and `bu.md`/`qa.md` ACs, build the slice list.
Each slice is the smallest increment that moves one User Story forward (§11.5):
- tasks covered (ids from §10 / CR), files/services touched, ACs advanced,
- test commands from `qa.md` §9 + coverage check,
- dependencies on earlier slices.
Show the slice list and order to the user before starting; adjust on feedback. Mark slices done
in `po.md` §10 as they complete.

## Step 4 — The implementation loop (per slice, §11.5 order)
For each slice:

1. **Slice brief.** Write the self-contained brief an implementer needs: goal, exact file scope,
   plan references (`dev.md` §5–7 · `qa.md` §9 · relevant CR), repo conventions
   (`context/DEV.md` §5 · style guide), the "definition of done" for the slice, and the test
   commands. Implementer sub-agents see the brief, not the whole conversation.
2. **Spawn gate (mandatory confirm).** Propose the implementer sub-agent(s) for THIS slice:
   how many (1+ allowed — split by file/service boundary), each agent's scope, the model/effort
   (prefer the cheapest capable), and whether agents run in parallel (non-overlapping scopes
   only) or sequence. **Wait for explicit user confirmation per spawn.** On decline or edits,
   re-propose; the user may also elect to have the orchestrator implement directly — that choice
   is theirs, recorded in the plan task notes.
3. **Implement.** Dispatch the confirmed agent(s) with the slice brief. If the agent runtime has
   no sub-agent support, or the user chose direct implementation, implement the slice in this
   session following the same brief.
4. **Orchestrator review.** Review each agent's diff against the brief and §11.3: plan
   conformance, no scope creep, context/doc/style/data-model sync. Do not silently rewrite an
   implementer's code — defects go back as a follow-up brief through another confirmed spawn, or
   the orchestrator fixes directly only when the user approves that in the review gate.
5. **Test concretely** per `qa.md` §9: unit-test API logic, Playwright the UI flow, run the exact
   commands, record what ran + observed + coverage. Prefer the real app over assumptions.
6. **Retest after every change** — the whole relevant suite, not just the new test. Fix until
   green; mark each `qa.md` Test Case `pass`.
7. **Owner review.** Show the diff (+ screenshots / running app where sensible), explain how it
   was tested, and ask for feedback explicitly. Silence is not approval.
8. **Implement-phase security review** (§11.6): `security-review` sub-skills over what the slice
   touched — `secret` · `code-review` · plus conditional `auth` · `dependency` · `docker`. Fix or
   explicitly accept every high/critical finding before the slice leaves the loop; log in
   `ops.md` §8. If `security-review` isn't installed, say so and record that honestly.
9. **Fold feedback** into the plan files (task checkboxes, `qa.md` statuses, `ops.md` §8,
   open questions) → next slice.

## Step 5 — Writing cleanup with `/unslop` (when coding for the plan is done)
After the last slice is green, run `/unslop` (pstack) over the **writing artifacts this run
produced or edited** — plan role files, REVIEW.md if written, ADRs, docs, READMEs — to cut AI
tells while preserving meaning. Not for code: code slop is Step 7's `/deslop`. If `/unslop`
isn't installed, do a manual pass over the same artifacts (vague attribution, filler phrases,
forced triads, AI vocabulary) and record that in the task notes.

## Step 6 — Sync artifacts + advance status
1. **API spec** — reconcile `docs/openapi.yaml` with `dev.md` §7 as-built (new/changed endpoints,
   error codes); drift found in either direction gets fixed on both sides.
2. **Style guide** — if UI was touched, update `styles/` (tokens · components) to match what was
   actually built, and DESIGN.md §12 references if the visual system changed.
3. **Data model** — `context/DEV.md` §7 updated for every entity/column change (§11.3).
4. **Status 3-place sync** — if every slice is green, User Stories pass, ACs met, coverage
   > 80%, and no unresolved high/critical security finding: set `ready to test` in all three
   places. Otherwise the plan stays `implement` with the remaining items listed in the plan.

## Step 7 — Pre-commit quality chain (only when heading to commit)
Run in this order, then §11.7:
1. **Design re-check (if design work happened)** — if the plan/CRs included UI/visual work,
   re-run `/impeccable` (pbakaus/impeccable, `required-skills.md`) for an audit/polish pass over
   the changed UI — "re-run" because design was already checked at plan time. If not installed,
   fall back to `/design-review` or the documented manual design review (SKILLS.md §10 row).
2. **`/deslop`** (pstack) over the branch diff vs main — remove AI code slop (noise comments,
   defensive clutter, `any` casts, deep nesting) with behavior unchanged. Missing → note it and
   do a focused manual pass; record in `qa.md`.
3. **`/thermo-nuclear-code-quality-review` (optional — ask every time).** Offer the strict
   maintainability/structure review; the user decides per run. If declined, record the skip (and
   why, when given) in `qa.md` alongside the deslop note; if accepted, fix or explicitly accept
   each finding before commit.
4. **§11.7 gate** — commit (and push) only after an explicit per-invocation confirmation; show
   what would be committed first. Never automatic.

## Stop rule
Finish at `ready to test` (artifacts synced: openapi.yaml · styles · DEV.md §7 · plan files) or
at an honestly recorded blocker with status `implement`. Commit/push only through Step 7.4's
§11.7 confirmations. Do not run the final QA pass to `done` — that is the next stage after
`ready to test`.
