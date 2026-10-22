---
name: icontext-implement
description: Execute one feature plan (plans/NNN-name/ folder + its pending CR-*.md) through the
             CONTEXT.md §11.5 implementation loop, from `ready to implement` (or resuming
             `implement`) to `ready to test`. Starts by summarizing the plan via
             /icontext-feature-review, then slices the §10 tasks and runs each slice with
             confirmed implementer sub-agents on a cheap/low-effort model — the user confirms
             EVERY spawn (count · scope · model) as a hard rule. After coding — /unslop on the
             written artifacts, sync docs/openapi.yaml + styles/ + DEV.md §7, and before commit
             the quality chain — /impeccable re-check (if design work), /deslop on the diff,
             optional /thermo-nuclear-code-quality-review (asked every time), then the §11.7
             commit confirmation. Use whenever the owner says "implement plan NNN", "ลงมือ
             implement", "execute this plan", or a `ready to implement` plan is being resumed.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
---

# icontext-implement

> **Run `bash check-update.sh` first** (via `Bash`) and surface its one-line result — best-effort,
> never blocks. If an update is available, mention it, then continue.

> **Then pick the plan and summarize it before any code.** Resolve the target `plans/NNN-<slug>/`
> (ask when ambiguous), check its status is `ready to implement` (or `implement` to resume), then
> run **`/icontext-feature-review`** (audience `dev`, chat summary) so you, the user, and the
> implementer briefs share one picture. Surface its ❌/⚠️ findings and blocking open questions
> before slicing — a blocker stops the run before code exists.

> **Spawn gate — mandatory, every time.** Implementer sub-agents run on the cheapest capable
> model / lowest sensible effort, and **every spawn is confirmed by the user individually**:
> how many agents, each scope (non-overlapping file/service boundaries), model/effort, parallel
> vs sequential. Retries and re-spawns confirm too. Never spawn silently. The orchestrator (this
> skill) keeps the judgement: slicing, plan conformance, test verdicts, security, status.

The full, agent-neutral workflow lives in **[PROCEDURE.md](./PROCEDURE.md)**.
**Read PROCEDURE.md and execute its steps.**

Portable across agents - see [adapters/](./adapters/). SKILL.md is the Claude Code entry point.

## Claude-specific mappings
- **Step 1 plan pick + status route** - list `plans/` with `Bash`, resolve the plan
  (number/slug/title), `AskUserQuestion` when ambiguous. Status `plan` → stop (finish the §11.4
  chain via `icontext-feature`); `ready to test`/`done` → confirm a re-open first.
- **Step 2 plan summary** - invoke the `icontext-feature-review` skill; if it isn't installed,
  produce the same two-lens summary manually (requirement + technical view + cross-checks).
- **Step 3 slice list** - build slices from `po.md` §10 (+ CR tasks) with `Bash`/`Read`, show the
  ordered list, adjust on feedback before starting.
- **Step 4.2 spawn gate** - use `AskUserQuestion` per spawn (agents · scopes · model/effort ·
  order). Dispatch confirmed implementers with the `Task` tool on a **cheap/low-effort model**
  (haiku-class), passing the self-contained slice brief — goal, exact file scope, plan refs
  (`dev.md` §5–7, `qa.md` §9, CRs), conventions, definition of done, test commands. Multiple
  `Task` calls in one message only when scopes don't overlap and the user approved parallel.
  If sub-agents are unavailable or the user prefers, implement the brief directly.
- **Step 4.4–4.8 loop gates** - review each diff (`Bash` git diff + `Read`), run the exact test
  commands from `qa.md`, retest the relevant suite after every change, `AskUserQuestion` for the
  owner review, and run the `security-review` skill's implement-phase sub-skills
  (secret · code-review · auth · dependency · docker) over the touched files; log `ops.md` §8.
- **Step 5 writing cleanup** - invoke the `unslop` skill (pstack) over plan files/docs/ADRs
  written this run; manual pass if missing.
- **Step 6 artifact sync** - reconcile `docs/openapi.yaml` with `dev.md` §7, update `styles/`
  when UI was touched, sync `context/DEV.md` §7, then the 3-place status sync
  (plan README · `plans/README.md` · `PLAN.md`) to `ready to test` when gates pass.
- **Step 7 pre-commit chain** - (1) if design/UI work: invoke the `impeccable` skill
  (pbakaus/impeccable) for a re-check; fallback `design-review` or a documented manual pass.
  (2) Invoke `deslop` (pstack) on the branch diff. (3) `AskUserQuestion`: offer
  `thermo-nuclear-code-quality-review` (optional, every run; record chosen/skipped in `qa.md`).
  (4) §11.7: commit/push only on explicit per-invocation confirmation.

## Stop rule
Finish at `ready to test` with artifacts synced, or at a recorded blocker with status
`implement`. Commit/push only through the §11.7 confirmation. Do not run the final QA pass to
`done`.
