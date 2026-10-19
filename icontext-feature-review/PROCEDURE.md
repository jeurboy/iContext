# icontext-feature-review - procedure (agent-neutral)

> Source of truth for turning a feature plan into a single reviewable summary: requirement view +
> technical view (architecture · DB · API) + readiness verdict. Template:
> [templates/review-template.md](./templates/review-template.md).

## Operating rules
- **Requires an existing plan.** If `plans/` or the named plan folder is missing, stop and point to
  `icontext-feature`. If the project has no `CONTEXT.md`, point to `icontext-init`.
- **Read-only; writes no file unless the user explicitly asks for one.** Never edit plan files, indexes, docs, or code.
- **Source of truth stays in the plan.** The review is a derived snapshot; it must not restate
  decisions differently from the plan. If the plan is ambiguous, say so under Gaps instead of choosing.
- **No invention.** Missing section → "ไม่ระบุในแผน". Detector/test results never claimed unless the plan
  records real output.
- **Never commit / push** unless explicitly told.

## Step 0 - Update check
Run `check-update.sh` next to this file; surface the one line; continue even if offline.

## Step 1 - Pick the plan and options
List `plans/` (Bash). Resolve the target plan from the user's words (number, slug, or title);
ambiguous → `AskUserQuestion`. Then ask (one multi-question call, skip what the user already stated):
1. **Audience:** plain (default) · dev · both.
2. **Output:** chat only (default — do not create any file) · write `plans/NNN-<slug>/REVIEW.md` or a custom path only if the user asks.
Include all `CR-*.md` in the folder by default; each CR is summarized as a delta block.

## Step 2 - Read the sources
Read, in this order, whatever exists:
1. Plan folder: `README.md` (status, depends-on, review checklist), `bu.md`, `po.md`, `stk.md`,
   `dev.md`, `qa.md`, `ops.md`, every `CR-*.md`.
2. Context cross-check targets: `CONTEXT.md`, `context/DEV.md` (§3–7, esp. §7 Data Model),
   `context/SECURITY.md`, `context/QA.md` (standard), `docs/openapi.yaml`, `plans/README.md`, `PLAN.md`,
   plans named in `Depends on`.
3. Read-only code probe (optional, only to verify "already implemented" claims): `Grep` for the
   migration file / controller route names the plan promises. Report found/not found; do not judge code quality.

## Step 3 - Build the review (fill the template)
Fill each section from the plan only. Rules per section:
- **TL;DR** - ≤5 lines, no jargon: what changes for whom, and the current status/verdict.
- **Requirement view** - goal, decisions (keep the plan's `D#` ids and the *why*), scope in/out, a
  user-story → AC → TC trace table, open questions. Translate rules into everyday sentences
  ("ถ้าเจ้าของถูกปิดบัญชี ชั้นจะถูกแช่แข็ง") before the formal ids.
- **Technical view**
  - *Architecture:* services touched, new/changed components, request flow (a small `mermaid`
    sequence/flow when the plan has a non-trivial flow), authz boundary, transactions/consistency.
  - *Database:* table of entity/column changes with purpose, constraints/indexes, backfill,
    migration up/down, rollback stance, data-lifecycle states, privacy of stored data.
  - *API:* endpoint table (method · URL · who may call · success · error codes), breaking-change flag,
    consumers affected, OpenAPI sync state.
  - *UI/routes:* page table and key states (empty/frozen/denied).
  - *Security & privacy* and *Deploy/ops* - copy the plan's matrix in one table + the risk
    acceptance/detector state exactly as recorded (real / not run / accepted by whom and when).
- **Quality** - list TS/TC counts by type & priority, AC with no TC, TC statuses, coverage target.
- **Cross-checks (Step 4)** - results table.
- **Readiness & gaps** - risks, open questions, accepted risks, blockers per next status, verdict.
- **Change requests** - one short block per `CR-*.md`: what it changes, status, which sections above it affects.
- Audience `dev`/`both`: add the Technical appendix (full schema/endpoint detail, SQL-level notes).

## Step 4 - Cross-checks (evidence table)
Run and record each as ✅ match · ⚠️ drift · ❌ missing · ➖ n/a, with file:section evidence:
1. Every AC maps to ≥1 TC; every US maps to ≥1 AC.
2. Every endpoint in `dev.md §7` exists in `docs/openapi.yaml` (and vice-versa for this plan's tag).
3. Every entity/column in `dev.md §6` appears in `context/DEV.md §7` (or is marked "planned").
4. Status in plan README == `plans/README.md` == `PLAN.md` (the 3-place sync rule).
5. Security matrix (`ops.md §8`) covers every new route; detector state is stated honestly.
6. `Depends on` plans exist and are not in a status that blocks this one.
7. Older plans that the new contract touches are listed as "to sync" (or marked synced).
8. Open Questions section: count, and whether any blocks the next status.

## Step 5 - Write and verify
Deliver the review in chat by default, following the template's section order. Only if a file was requested, write it (e.g. `plans/NNN-<slug>/REVIEW.md`) with a header line:
`Generated <date> from plan status <status> — snapshot; the plan files remain the source of truth.`
Do **not** register it in `plans/README.md`/`PLAN.md` (it is not a plan). Re-open the file and check
that no template placeholder (`<…>`, `TODO`) remains. Report: path, verdict, counts of ❌/⚠️, top 3 gaps.

## Stop rule
Finish at the review. Do not fix gaps, advance status, implement, commit, or push.
