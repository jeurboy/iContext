# {{PROJECT_NAME}} — CONTEXT.md (Layer 2 · single source of truth)

> Architecture §1–13. **Read this before anything.** Every plan in `plans/` must `ref` this file.
> Companion indexes: `PLAN.md` (status dashboard) · `plans/README.md` (plan index) · `ROLE.md` (multi-agent role panel).

---
## ผลิตภัณฑ์ & ทิศทาง · Product & Direction

### 1. ภาพรวมผลิตภัณฑ์ · Product Overview
- **What:** {{PROJECT_DESC}}
- **Platforms:** {{PLATFORMS}}
- **Reference:** {{REFERENCE}}
- **Status:** scaffolded — features not yet implemented
<!-- TODO: target users, value proposition -->

### 2. Key Decisions
<!-- Log decisions: date · decision · why · alternatives rejected. -->
- {{DATE}} — Stack chosen: web {{WEB_STACK}}, mobile {{MOBILE_STACK}}, api {{API_STACK}}, db {{DB_STACK}}.

---
## สถาปัตยกรรม · Architecture

### 3. สถาปัตยกรรมระบบ · System Architecture
<!-- TODO: diagram / data flow -->
- `web/` ({{WEB_STACK}}) → `api/` ({{API_STACK}}) → `db` ({{DB_STACK}})
- `app/` ({{MOBILE_STACK}}) → `api/`

### 4. Tech Stack
| Layer | Choice | Notes |
|-------|--------|-------|
| Web | {{WEB_STACK}} | React Query · Tailwind · Playwright |
| Mobile | {{MOBILE_STACK}} | state + Dio + feature-first (app/STRUCTURE.md) |
| API | {{API_STACK}} | Clean Architecture · ORM-first, minimal raw SQL |
| DB | {{DB_STACK}} | docker-compose · migrations |

### 5. โครงสร้าง Repo · Repo Structure
- Mono-root with each service as its **own git repo wired as a submodule**: `api/`, `web/`, `app/`.
- Context backbone (this file, `CLAUDE.md`/`AGENTS.md`/`AGENT.md`/`GEMINI.md`, `ROLE.md`, `plans/`, `styles/`,
  `docs/`, `PLAN.md`) lives at the root.

### 6. รายการ Service · Services
| Service | Stack | Port | STRUCTURE |
|---------|-------|------|-----------|
| api | {{API_STACK}} | {{API_PORT}} | api/STRUCTURE.md |
| web | {{WEB_STACK}} | {{WEB_PORT}} | web/STRUCTURE.md |
| app | {{MOBILE_STACK}} | — | app/STRUCTURE.md |
| db | {{DB_STACK}} | {{DB_PORT}} | docker-compose.yml |

### 7. Data Model
> Single source of truth for entities. Keep in sync with the plan's schema section + DB migrations
> (§11.3). Update this whenever the data model changes.

**Entities**
| Entity | Key fields | Description |
|--------|-----------|-------------|
| <!-- e.g. User --> | id, ... | <!-- TODO --> |

**Relationships**
<!-- TODO: e.g. User 1—N Order; Order N—N Product (via OrderItem). One model can have many physical units. -->

**ERD / notes**
<!-- TODO: link or embed a diagram; note enums, indexes, soft-delete, audit fields -->

---
## คุณภาพ & ความปลอดภัย · Quality & Security

### 8. Security Model
<!-- TODO: authn/authz, roles (e.g. admin vs customer), data protection, secrets handling -->

### 9. Testing & Quality Gates
- Unit tests on API + Playwright UI tests. **Coverage > 80%** (hard gate).
- A plan reaches `done` only when: API spec synced · User Stories complete · tests > 80%.

### 10. Skills ที่ใช้ · Skills Used
- **Install first (every project):** `gstack` — https://github.com/garrytan/gstack — provides the
  `/gstack-*` commands incl. **`/autoplan`** and the plan-review chain (`/plan-ceo-review`,
  `/plan-eng-review`, `/plan-design-review`, `/plan-devex-review`) used before implementing.
- `gstack` · `ui-ux-pro-max` · `impeccable` (design/QA companions)
- `grill-with-docs` (or equivalent grilling workflow) for requirement discovery + ADR/domain updates
- `icontext-init` (scaffold) · `icontext-feature` (plans)

---
## กระบวนการ & ดีไซน์ · Process & Design

### 11. Workflow + Plan Standard
- Build context first → then features one at a time via `/icontext-feature`. Never commit/push unless told.

#### 11.0 Main development workflow
Use this workflow for every non-trivial feature so requirements, plan, context, and tests stay in
sync:

1. **Context check** — read `CONTEXT.md`, `PLAN.md`, `plans/README.md`, and the relevant existing
   plan(s). Confirm the feature belongs in this project and note affected services from §6.
2. **Requirement discovery with `/grill-with-docs`** — before writing the plan, interview the owner
   until the requirement, edge cases, decisions, and domain terms are clear. Capture durable
   decisions in `docs/adr/` and update `CONTEXT.md` (especially §2, §7, §8, §13) when the feature
   changes project knowledge. If `/grill-with-docs` is unavailable, run the same grilling process
   manually and document the outcome.
3. **Requirement review with `ROLE.md` multi-agent panel** — use the roles/personas in `ROLE.md`
   to review the requirement before locking scope. If the agent supports subagents, run one reviewer
   per role/persona; otherwise emulate separate BU/PO/DEV/QA/OPS/STK passes. Capture works /
   concerns / suggestions / requirement changes in the plan's §4 (`stk.md`) and fold accepted
   changes back into `bu.md`, `po.md`, `dev.md`, `qa.md`, and `ops.md`.
4. **Plan creation** — create `plans/NNN-<name>/` via `/icontext-feature`, fill the role-split
   files, set `Task status: plan`, and register the plan in `plans/README.md` + `PLAN.md`.
5. **Plan preparation with gstack `/autoplan`** — run `/autoplan` (or the review chain in §11.4)
   to challenge scope, architecture, design, and developer experience. Apply accepted changes, then
   move the plan to `ready to implement`.
6. **Implementation loop** — implement in small slices following §11.5. Keep `CONTEXT.md`, the plan,
   `docs/openapi.yaml`, styles, and data model in sync when architecture changes.
7. **Final QA + done gates** — move to `ready to test`, run the test plan, confirm User Stories are
   complete, sync the API spec, keep coverage > 80%, then mark `done` in all three status locations.

#### 11.1 Plan structure (every plan is a **folder** `plans/NNN-<name>/` split by role; sections 0–11)
Roles: **BU** ธุรกิจ · **PO** เจ้าของงาน · **DEV** พัฒนา · **QA** ทดสอบ · **OPS** DevOps/Deploy · **STK** Stakeholder.
Each section lives in exactly one role file:

| # | Section | Owner | File |
|---|---------|-------|------|
| 0 | Decisions | STK BU PO | bu.md |
| 1 | Goal | STK BU PO | bu.md |
| 2 | Scope (in/out) | PO DEV | po.md |
| 3 | User Stories (mandatory) | PO QA | po.md |
| 4 | Requirement Review / Persona Panel | STK BU PO DEV QA OPS | stk.md |
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

#### 11.3 Keep everything in sync on architecture-impacting change
Whenever a change affects the **core architecture** (§3–6) — services, data model, API contract,
or shared conventions — update all of these **together, in the same change**, so nothing drifts:
- **Context** — this `CONTEXT.md` (architecture §3–6 and **§7 Data Model** especially).
- **Plan** — the affected `plans/NNN-*/` (Tech & Architecture · Data Model/Schema · API Contract).
- **Doc** — `docs/openapi.yaml` (API spec) and any other docs the change touches.
- **Style** — `styles/css/tokens.css` + `styles/components/` when UI / look-and-feel is affected.
- **Data model** — keep §7 here, the plan's schema section, and DB migrations consistent.

#### 11.4 Plan review chain — run `/autoplan` before implementing any plan
Before moving a plan to **`ready to implement`** (i.e. before any implementation), run gstack
**`/autoplan`** to prepare the plan. It runs the review chain sequentially and applies decisions,
or run the individual reviews when `/autoplan` is unavailable:
- **`/plan-ceo-review`** — scope / ambition
- **`/plan-eng-review`** — architecture / edge cases
- **`/plan-design-review`** — if the feature has UI
- **`/plan-devex-review`** — if developer-facing (API, SDK, CLI)

These come from the `gstack` skill (§10). Capture outcomes in the plan before implementation.

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
6. **Fold in feedback** → back to step 1 for the next slice.

Repeat until every User Story passes, acceptance criteria (bu.md / qa.md) are met, and coverage
is > 80% — then move the plan to **`ready to test`** for a final QA pass before `done`.

### 12. Design Tokens
- Central tokens in `styles/css/tokens.css`. **Never inline colors / look-and-feel.** Web (Tailwind)
  and mobile (theme) mirror these tokens.

### 13. Open Questions
<!-- TODO: collect unknowns here -->
