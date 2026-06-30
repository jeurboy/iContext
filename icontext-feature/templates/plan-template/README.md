# NNN — <Feature Name> (plan folder)

> A plan is a **folder** split by role. **ref:** [CONTEXT.md](../../CONTEXT.md)
> Plan section spec: CONTEXT.md §11.1. Roles: BU·PO·DEV·QA·OPS·STK.

**Task status:** `to do`  <!-- to do → plan → ready to implement → implement → ready to test → done -->
**Owner:** <!-- PO -->   **Created:** <!-- YYYY-MM-DD -->

> Task status lifecycle: **to do** (not started) → **plan** (plan being written) →
> **ready to implement** (review chain done) → **implement** (building) →
> **ready to test** (built, awaiting QA) → **done** (gates passed).

> ⚠️ On status change, update **3 places**: this README · `../README.md` (plans index) · `../../PLAN.md`.

## Role files (sections 0–11 split by owner)
| File | Role | Sections |
|------|------|----------|
| [bu.md](./bu.md) | BU · Business | 0 Decisions · 1 Goal · Use Cases · User Stories · Acceptance Criteria · Definition of Done |
| [po.md](./po.md) | PO · Product Owner | 2 Scope · 3 User Stories · 10 Tasks/Checklist · 11 Open Questions |
| [dev.md](./dev.md) | DEV · Development | 5 Tech & Architecture · 6 Data Model/Schema · Migration scripts · 7 API Contract · API changes · Pages/routes |
| [qa.md](./qa.md) | QA · Testing | 9 Test Plan (>80%) · How to run · Implementation loop & regression · Test Scenarios · Test Cases · Test Status · Test Coverage |
| [ops.md](./ops.md) | OPS · DevOps/Deploy | 8 Security & Privacy · Deploy/Migrations |
| [stk.md](./stk.md) | STK · Stakeholder | 4 Persona Panel |

### Review chain — run before `ready to implement`
Run via `/autoplan` (or one by one). Check off + capture outcomes before implementing:
- [ ] `/plan-ceo-review` — scope / ambition
- [ ] `/plan-eng-review` — architecture / edge cases
- [ ] `/plan-design-review` — if the feature has UI
- [ ] `/plan-devex-review` — if developer-facing (API, SDK, CLI)

### Gates before `done`
API spec synced (`docs/openapi.yaml`) · User Stories complete (po.md §3) · test coverage > 80% (qa.md §9).
