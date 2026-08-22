# {{PROJECT_NAME}} — CONTEXT.md (Layer 2 · single source of truth)

> **Read this before anything.** Every plan in `plans/` must `ref` this file.
> Companion indexes: `PLAN.md` (status dashboard) · `plans/README.md` (plan index) · `ROLE.md` (multi-agent role panel).

## Context map — where each section lives
Layer 2 is **seven files at the repo root**, split by concern. Section numbers §1–13 are global and
**stable**: a section keeps its number wherever it lives, so every `§N` reference in plans, docs,
and older notes still resolves. Read CONTEXT.md first; follow the link when you need that concern.

| § | Section | File | Owners |
|---|---------|------|--------|
| 1 | Product Overview | [PRODUCT.md](./PRODUCT.md) | `STK BU PO` |
| 2 | Key Decisions | [PRODUCT.md](./PRODUCT.md) | `STK BU PO` |
| 3–6 | Architecture · Tech Stack · Repo · Services | [DEV.md](./DEV.md) | `DEV OPS` |
| 7 | Data Model | [DEV.md](./DEV.md) | `DEV OPS` |
| 8 | Security Model | [SECURITY.md](./SECURITY.md) | `DEV QA OPS` |
| 9 | Testing & Quality Gates | [QA.md](./QA.md) | `QA DEV OPS` |
| 10 | Skill Dependencies & Invocation | [SKILLS.md](./SKILLS.md) | all |
| 11 | Workflow + Plan Standard | **CONTEXT.md** (here) | all |
| 11.6 | Security review wiring | [SECURITY.md](./SECURITY.md) | `DEV QA OPS` |
| 11.7 | Agent mutation safety + hooks | **CONTEXT.md** (here) | all |
| 12 | Design Tokens & Design System | [DESIGN.md](./DESIGN.md) | `DEV` + design |
| 13 | Open Questions | [PRODUCT.md](./PRODUCT.md) | `PO BU STK` |

> **Rule:** a concern lives in exactly one file. Never copy a section into another file — link to
> it. If a change touches more than one of these files, update them **in the same change** (§11.3).

---
## ผลิตภัณฑ์ & ทิศทาง · Product & Direction

### 1. ภาพรวมผลิตภัณฑ์ · Product Overview
➜ **Moved to [PRODUCT.md](./PRODUCT.md) §1** — what the product is, platforms, target users,
value proposition, success metrics, non-goals.

### 2. Key Decisions
➜ **Moved to [PRODUCT.md](./PRODUCT.md) §2** — decision log (date · decision · why · alternatives
rejected). Deep technical ADRs live in `docs/adr/` and are linked from that table.

---
## สถาปัตยกรรม · Architecture

### 3. สถาปัตยกรรมระบบ · System Architecture
➜ **Moved to [DEV.md](./DEV.md) §3** — system diagram, boundaries, and data flow.

### 4. Tech Stack
➜ **Moved to [DEV.md](./DEV.md) §4** — stack choices and implementation notes by layer.

### 5. โครงสร้าง Repo · Repo Structure
➜ **Moved to [DEV.md](./DEV.md) §5** — repository strategy, service layout, and context backbone.

### 6. รายการ Service · Services
➜ **Moved to [DEV.md](./DEV.md) §6** — service names, stacks, ports, and structure guides.

### 7. Data Model
➜ **Moved to [DEV.md](./DEV.md) §7** — entities, relationships, indexes, and migration notes.

---
## คุณภาพ & ความปลอดภัย · Quality & Security

### 8. Security Model
➜ **Moved to [SECURITY.md](./SECURITY.md) §8** — authn, authz/roles (deny-by-default + permissions
matrix rule), data protection & PII, secrets handling, threats & accepted risks.
Automated enforcement: the `security-review` dependency skill runs in the plan and implement
phases — see **[SECURITY.md](./SECURITY.md) §11.6** for which sub-skill runs when.

### 9. Testing & Quality Gates
➜ **Moved to [QA.md](./QA.md) §9** — coverage gate per service, the 🛑 AC-traceability rule,
scenario naming (Title 1 / Title 2), test types, the four required scenario kinds
(Success · Alternative · Boundary · Edge incl. permission-denied), priority, effort, reusability,
and optional tracker export.

Headline gates (detail in QA.md):
- Unit tests on API + Playwright UI tests. **Coverage > 80%** (hard gate).
- 🛑 Every test case traces back to a PO acceptance criterion; a plan with no acceptance criteria
  is not accepted.
- A plan reaches `done` only when: API spec synced · User Stories complete · tests > 80% ·
  security review clean (no unresolved high/critical finding from SECURITY.md §11.6).

### 10. Skill Dependencies & Invocation
➜ **Moved to [SKILLS.md](./SKILLS.md) §10** — direct dependencies, invocation triggers,
composition order, exclusions, and fallbacks. Read it before selecting or invoking a skill.

---
## กระบวนการ & ดีไซน์ · Process & Design

### 11. Workflow + Plan Standard
- Build context first → then features one at a time via `/icontext-feature`. Commit, push, and every
  direct DB/migration/seed action require an explicit per-invocation confirmation (§11.7).
- **Second brain principle:** every `.md` file — this `CONTEXT.md`, its L2 siblings (`DEV.md`,
  `PRODUCT.md`, `QA.md`, `SECURITY.md`, `DESIGN.md`, `SKILLS.md`), `PLAN.md`, everything under
  `plans/` and `docs/` — is the project's persistent memory, not throwaway paperwork. Whenever a
  plan or approach is adjusted, follow up in the affected plan: record the work done **and the
  reasoning / thought process** behind the change (what changed, why, what was rejected), so any
  human or agent can reconstruct the thinking later. Never change direction silently.

#### 11.0 Main development workflow
Use this workflow for every non-trivial feature so requirements, plan, context, and tests stay in
sync:

1. **Context check** — read `CONTEXT.md` + the L2 files the feature touches
   ([PRODUCT.md](./PRODUCT.md) and [SKILLS.md](./SKILLS.md) always; [DEV.md](./DEV.md) for technical work;
   [DESIGN.md](./DESIGN.md) if it has UI;
   [SECURITY.md](./SECURITY.md) if it adds a route/page/dependency; [QA.md](./QA.md) before writing
   any test), then `PLAN.md`, `plans/README.md`, and the relevant existing
   plan(s). Confirm the feature belongs in this project and note affected services from `DEV.md` §6.
2. **Requirement discovery route** — before writing the plan, ask the owner to choose:
   `/grill-with-docs` for requirements that mostly fit in one planning session, or `/wayfinder` for
   large/foggy requirements where the solution path is not clear yet. With `/grill-with-docs`,
   interview the owner until the requirement, edge cases, decisions, and domain terms are clear.
   With `/wayfinder`, chart/continue the map and do not write the iContext plan until
   planning-critical tickets are resolved enough to produce a useful plan. Capture durable decisions
   in `docs/adr/` and update the L2 context when the feature changes project knowledge — especially
   `PRODUCT.md` §2 (decisions) + §13 (open questions), `DEV.md` §7 (data model), and
   `SECURITY.md` §8 (security model). If companion skills are unavailable, run the same discovery process manually
   and document the outcome.
3. **Requirement review with `ROLE.md` multi-agent panel** — use the roles/personas in `ROLE.md`
   to review the requirement before locking scope. If the agent supports subagents, run one reviewer
   per role/persona; otherwise emulate separate BU/PO/DEV/QA/OPS/STK passes. Capture works /
   concerns / suggestions / requirement changes in the plan's §4 (`stk.md`) and fold accepted
   changes back into `bu.md`, `po.md`, `dev.md`, `qa.md`, and `ops.md`.
4. **Plan creation** — create `plans/NNN-<name>/` via `/icontext-feature`, fill the role-split
   files, set `Task status: plan`, and register the plan in `plans/README.md` + `PLAN.md`.
5. **Plan preparation with gstack `/autoplan`** — run `/autoplan` (or the review chain in §11.4)
   to challenge scope, architecture, design, and developer experience. Apply accepted changes, then
   run the **plan-phase security review** (`security-review` → **supply-chain**, SECURITY.md §11.6) and record
   its findings in the plan's `ops.md` §8. Only then move the plan to `ready to implement`.
6. **Implementation loop** — implement in small slices following §11.5. Each slice ends with the
   **implement-phase security review** (`security-review` → secret · code-review · auth ·
   dependency · docker, SECURITY.md §11.6). Keep `DEV.md`, the plan, `docs/openapi.yaml`, styles, and data
   model in sync when architecture changes.
7. **Final QA + done gates** — move to `ready to test`, run the test plan, confirm User Stories are
   complete, sync the API spec, keep coverage > 80%, confirm no unresolved high/critical
   `security-review` finding (SECURITY.md §11.6), then mark `done` in all three status locations.

#### 11.1 Plan structure (every plan is a **folder** `plans/NNN-<name>/` split by role; sections 0–11)
Roles: **BU** ธุรกิจ · **PO** เจ้าของงาน · **DEV** พัฒนา · **QA** ทดสอบ · **OPS** DevOps/Deploy · **STK** Stakeholder.
Each section lives in exactly one role file:

| # | Section | Owner | File |
|---|---------|-------|------|
| 0 | Decisions | STK BU PO | bu.md |
| 1 | Goal | STK BU PO | bu.md |
| 2 | Scope (in/out) | PO DEV | po.md |
| 3 | User Stories (mandatory) | PO QA | po.md |
| 4 | Requirement Discovery / Requirement Review / Persona Panel | STK BU PO DEV QA OPS | stk.md |
| 5 | Tech & Architecture | DEV OPS | dev.md |
| 6 | Data Model / Schema | DEV OPS | dev.md |
| 7 | API Contract | DEV QA | dev.md |
| 8 | Security & Privacy | DEV QA OPS | ops.md |
| 9 | Test Plan (>80%) | QA DEV OPS | qa.md |
| 10 | Tasks / Checklist | DEV PO OPS | po.md |
| 11 | Open Questions | PO BU STK | po.md |

The folder also has `README.md` (index + canonical Status). Template: `plans/_TEMPLATE/`.
Task status lifecycle: `to do → plan → ready to implement → implement → ready to test → done`
(ready to implement = review chain §11.4 done).

#### 11.2 Rules for every plan
- **ref CONTEXT.md** always.
- **Update status in 3 places in one go:** the plan's `README.md` · `plans/README.md` · `PLAN.md`.
- **sync API spec** (`docs/openapi.yaml`) before `done`.
- **User Stories complete** before `done`.
- **test > 80%** before `done`.
- **security review clean** before `done` — no unresolved high/critical finding from §11.6;
  accepted risks written down in `ops.md` §8.

#### 11.3 Keep everything in sync on architecture-impacting change
Whenever a change affects the **core architecture** (§3–6) — services, data model, API contract,
or shared conventions — update all of these **together, in the same change**, so nothing drifts:
- **Development context** — [DEV.md](./DEV.md) (architecture §3–6 and **§7 Data Model** especially).
- **Plan** — the affected `plans/NNN-*/` (Tech & Architecture · Data Model/Schema · API Contract).
- **Doc** — `docs/openapi.yaml` (API spec) and any other docs the change touches.
- **Style** — `styles/css/tokens.css` + `styles/components/` when UI / look-and-feel is affected.
- **Data model** — keep `DEV.md` §7, the plan's schema section, and DB migrations consistent.

**L2 sibling triggers** — the same change must also update the concern file it touches:

| If the change touches… | Update | In the same change |
|------------------------|--------|--------------------|
| architecture, stack, repo, services, or data model | [DEV.md](./DEV.md) §3–7 | ✔ |
| product direction, scope, a decision, a new unknown | [PRODUCT.md](./PRODUCT.md) §1 / §2 / §13 | ✔ |
| authn/authz, a new route or page, roles, secrets, PII | [SECURITY.md](./SECURITY.md) §8 | ✔ |
| a quality gate, test type, scenario/priority/effort standard | [QA.md](./QA.md) §9 | ✔ |
| a token, component, breakpoint, or any look-and-feel rule | [DESIGN.md](./DESIGN.md) §12 | ✔ |
| a direct skill dependency, trigger, order, exclusion, or fallback | [SKILLS.md](./SKILLS.md) §10 | ✔ |

A concern lives in exactly one file — extend it there and link, never copy the section into a plan
or into another L2 file.

#### 11.4 Plan review chain — run `/autoplan` before implementing any plan
Before moving a plan to **`ready to implement`** (i.e. before any implementation), run gstack
**`/autoplan`** to prepare the plan. It runs the review chain sequentially and applies decisions,
or run the individual reviews when `/autoplan` is unavailable:
- **`/plan-ceo-review`** — scope / ambition
- **`/plan-eng-review`** — architecture / edge cases
- **`/plan-design-review`** — if the feature has UI
- **`/plan-devex-review`** — if developer-facing (API, SDK, CLI)

These come from the `gstack` skill ([SKILLS.md](./SKILLS.md) §10). Capture outcomes in the plan
before implementation.

After the chain, run the **plan-phase security review** — `security-review` → **supply-chain**
(SECURITY.md §11.6). A plan does not reach `ready to implement` with an unresolved high/critical supply-chain
finding; either fix it, or record an explicit accepted-risk decision in `ops.md` §8.

#### 11.5 Implementation loop (loop engineering) — status `implement`
Once a plan is `ready to implement`, build it as a **tight iterative loop**, not one big pass.
The reason: small slices are easier to test, regressions surface immediately, and the owner stays
in the loop instead of reviewing a giant diff at the end. Each cycle:

1. **Slice** — take the smallest increment that moves one User Story (po.md §3) forward.
2. **Implement** the slice, keeping §11.3 in sync (context · plan · doc · style · data model).
3. **Test it — concretely.** Follow the plan's `qa.md` §9:
   - Unit-test the API logic; **Playwright** the UI flow. Cover happy path + the edge/error cases
     listed in qa.md Test Scenarios.
   - State the test method in the plan: the exact command to run (e.g. `go test ./...`,
     `npm run test:e2e`), the expected result, and how coverage is measured. Aim for **> 80%**.
   - Prefer running the real app and observing behaviour (gstack `/qa` to test systematically,
     `/verify` to confirm a change actually works) over assuming.
4. **Retest / regression** — after every change, re-run the **whole relevant suite**, not just the
   new test, so a fix doesn't quietly break something else. Fix until green; mark each `qa.md`
   Test Case `pass`.
5. **Review with the owner** — show what was built (diff · screenshots · the running app),
   **explain how you tested it** (what ran, what you observed, current coverage), and **ask for
   feedback explicitly**. Don't assume silence = approval.
5.5. **Security review the slice** — run `security-review` over what the slice actually touched:
   **secret · code-review · auth · dependency · docker** (SECURITY.md §11.6). Fix or explicitly accept every
   high/critical finding before the slice leaves the loop; log the outcome in `ops.md` §8.
6. **Fold in feedback** → back to step 1 for the next slice.

Repeat until every User Story passes, acceptance criteria (bu.md / qa.md) are met, and coverage
is > 80% — then move the plan to **`ready to test`** for a final QA pass before `done`.

#### 11.6 Security review — `security-review` wired into the lifecycle
➜ **Moved to [SECURITY.md](./SECURITY.md) §11.6** — which sub-skill runs in which phase
(plan: supply-chain · implement: secret · code-review · auth · dependency · docker), the per-slice
scope rules, and the `done` gate. Findings are always recorded in the plan's `ops.md` §8.

#### 11.7 Agent mutation safety & hook wiring
- **Confirmation gate:** before each `git commit`, `git push`, direct DB access, migration, seed,
  reset, import, restore, DB push, or known DB-changing startup command, state the exact action,
  target, environment, and impact, then get explicit user confirmation. Approval is not reusable
  for a later invocation. Generic approval such as “continue” or “finish” is insufficient unless
  it explicitly names the restricted action.
- **Source edits vs execution:** editing migration, schema, or seed files inside an authorized code
  change does not itself touch the DB. Running them against any local/staging/production database
  is separately confirmation-gated.
- **Hook when supported:** when the active AI host provides an interactive pre-command/pre-tool
  hook, wire `.icontext/hooks/guard-command.sh` through the host's documented project-local hook
  configuration. Merge with existing hooks; never overwrite them.
- **Verify the real host path:** `git status` must pass; `git commit`, `git push`, a direct DB client,
  and a seed/migration command must return an interactive `ask` decision. A direct script dry-run
  alone is not enough.
- **No usable hook:** if the host has no hook, or only supports a permanent block with no approval
  path, keep these L1/§11.7 rules and report `hook unavailable; policy enforced by instructions`.
- A missing, disabled, failed, or bypassed hook never grants permission. Full hook contract:
  [.icontext/hooks/POLICY.md](./.icontext/hooks/POLICY.md).

### 12. Design Tokens & Design System
➜ **Moved to [DESIGN.md](./DESIGN.md) §12** — token map, theming, component inventory, layout &
responsive rules, accessibility baseline, design workflow, voice & content.
Headline rule: central tokens in `styles/css/tokens.css` only — **never inline colors /
look-and-feel**; web (Tailwind) and mobile (theme) mirror those tokens.

### 13. Open Questions
➜ **Moved to [PRODUCT.md](./PRODUCT.md) §13** — open questions with owner + what unblocks them.
