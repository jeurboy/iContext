# NNN — <Feature Name> (plan folder)

> A plan is a **folder** split by role. **ref:** [CONTEXT.md](../../CONTEXT.md)
> Plan section spec: CONTEXT.md §11.1. Roles: BU·PO·DEV·QA·OPS·STK.

**Status:** `todo`  <!-- todo → implement → ready to test → done -->
**Owner:** <!-- PO -->   **Created:** <!-- YYYY-MM-DD -->

> ⚠️ On status change, update **3 places**: this README · `../README.md` (plans index) · `../../PLAN.md`.

## Role files (sections 0–11 split by owner)
| File | Role | Sections |
|------|------|----------|
| [bu.md](./bu.md) | BU · Business | 0 Decisions · 1 Goal |
| [po.md](./po.md) | PO · Product Owner | 2 Scope · 3 User Stories · 10 Tasks/Checklist · 11 Open Questions |
| [dev.md](./dev.md) | DEV · Development | 5 Tech & Architecture · 6 Data Model/Schema · 7 API Contract |
| [qa.md](./qa.md) | QA · Testing | 9 Test Plan (>80%) |
| [ops.md](./ops.md) | OPS · DevOps/Deploy | 8 Security & Privacy · Deploy/Migrations |
| [stk.md](./stk.md) | STK · Stakeholder | 4 Persona Panel |

### Gates before `done`
API spec synced (`docs/openapi.yaml`) · User Stories complete (po.md §3) · test coverage > 80% (qa.md §9).
