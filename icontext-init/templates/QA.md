# {{PROJECT_NAME}} — QA.md (Layer 2 · testing standard & quality gates)

> **Split out of `CONTEXT.md`.** Holds §9. Section numbers are unchanged, so every existing `§9`
> reference in plans and docs still resolves — only the file moved.
> Siblings: [CONTEXT.md](./CONTEXT.md) (context map + workflow) · [DEV.md](./DEV.md) (development) · [PRODUCT.md](./PRODUCT.md) ·
> [DESIGN.md](./DESIGN.md) · [SECURITY.md](./SECURITY.md)

**Owners:** `QA DEV OPS` · **Read by:** QA before writing scenarios, DEV before claiming `done`.
**This file is the authoring standard.** Each plan's `plans/NNN-*/qa.md` is an *instance* of it —
per-feature AC trace, scenarios, cases, status, coverage. Never copy these rules into a plan.

---

## 9. Testing & Quality Gates

### 9.1 Coverage gate
| Service | Test types | Tools | Gate |
|---------|-----------|-------|------|
| {{API_STACK}} (api) | Unit + Integration | <!-- e.g. testify, mockery, testcontainers --> | **coverage > 80%** |
| {{WEB_STACK}} (web) | E2E / UI | **Playwright** | **coverage > 80%** |
| {{MOBILE_STACK}} (app) | Unit + Widget + Integration | <!-- e.g. flutter_test, mocktail --> | <!-- > 80% recommended --> |

- Every feature must have tests before its plan moves to `done`.
- State the **exact command** per service (e.g. `go test ./... -cover`, `npm run test:e2e`) in the
  plan's `qa.md`, plus how coverage is measured.

### 9.2 Traceability — the hard rule
- 🛑 **Every test case must come from a PO acceptance criterion.** Never write a test from a dev's
  own understanding or assumption. Each case must trace back to an AC id via the AC table in the
  plan's `qa.md`.
- 🛑 **A plan with no PO acceptance criteria is not accepted** — go back to the PO and get the
  acceptance criteria before implementing or testing.

### 9.3 Scenario naming
Two levels, both required:

| Level | Format | Example |
|-------|--------|---------|
| **Title 1** (short) | `[Type][Result] <short headline>` | `[API][Success] Login สำเร็จ` |
| **Title 2** (full) | `[Type][Result] - ตรวจสอบ + Actor + Action + Object + Condition + Result` | `[API][Success] - ตรวจสอบการ Login ด้วย email และ password ที่ถูกต้องผ่าน Authentication API ได้สำเร็จ` |

- **[Result]** — `Success` (happy path) · `Alternative` (negative + error handling).
- **Verbs** — UI: แสดง / เปิด / กรอก / เลือก / ใช้งาน · API: ส่ง / รับ / ตรวจสอบ · Error: จัดการ.
- Title 2 must always be consistent with the case's Type.

### 9.4 Test type
| Type | Use when | Typical tools |
|------|----------|---------------|
| `API` | REST / GraphQL / RPC endpoints | <!-- Postman, REST Assured, go test --> |
| `Web UI` | web app through a browser | <!-- Playwright, Cypress --> |
| `Mobile UI` | iOS / Android app | <!-- Appium, integration_test, Maestro --> |
| `Other` | non-UI, non-API (log validation, DB checks, jobs) | <!-- ... --> |
<!-- TODO: trim to the types this project actually has; add e.g. `Desktop UI` only if it exists. -->

🚨 **One feature reachable via both API and UI ⇒ TWO separate scenarios**, one per interface.
Never mix interfaces in one scenario. Type must match how the case is actually executed.

### 9.5 Required coverage per feature
Every feature covers all four kinds — a plan missing any of these is not `ready to test`:

| Kind | What it covers |
|------|----------------|
| **Success** | the happy path, one per acceptance criterion |
| **Alternative** | negative input, error handling, failure responses |
| **Boundary** | min / max / limit values, empty, longest allowed |
| **Edge** | concurrency, race conditions, and **security: permission-denied + deny-by-default per role** ([SECURITY.md](./SECURITY.md) §8.2) |

Pick a technique per case: **EP** (Equivalence Partitioning) · **BVA** (Boundary Value Analysis) ·
**State Transition**.

### 9.6 Priority
| Level | Applies to |
|-------|-----------|
| **Critical** | core flows, authentication/authorization, data integrity (create/update/delete) |
| **High** | key features (search, filter, report), important error handling, integration points |
| **Medium** | secondary features, alternative flows, boundary conditions |
| **Low** | UI/UX details (layout, styling), rare edge cases, nice-to-haves |

### 9.7 Effort
| Effort | Typical case |
|--------|--------------|
| **0.5h** | element display, layout/responsive, text/label check |
| **1h** | basic CRUD, common form validation, search/filter |
| **2h** | complex business logic, multi-step process, data integration |
| **3h** | end-to-end automation, performance, security |
| **4h** | complex automation, cross-service / multi-role integration flow (**maximum**) |
| **>4h** | ❌ not allowed — split into smaller cases |

### 9.8 Reusability
- **Parameterize** instead of hard-coding: `กรอก {login_field} = {test_credential}`.
- **Modular steps** — factor shared setup into a pre-condition (e.g. "user is logged in").
- **Conditional steps** for multi-platform: `หากเป็น Mobile: แตะ… / หากเป็น Web: คลิก…`.
- Build a small template library for recurring shapes (auth, CRUD, form validation) rather than
  re-inventing wording per feature.

### 9.9 Definition of done for a plan
A plan reaches `done` only when:
- API spec synced (`docs/openapi.yaml`) · User Stories complete (`po.md` §3)
- Coverage > 80% (9.1) · every AC traced to ≥1 passing case (9.2)
- All four scenario kinds covered (9.5)
- Security review clean — no unresolved high/critical finding ([SECURITY.md](./SECURITY.md) §11.6)

### 9.10 Export to an external tracker (optional)
<!-- Only if this project pushes cases to Azure DevOps / TestRail / Jira / etc.
     Fill this in once; the plan's qa.md just points here. Delete the section if unused. -->
- **Tracker:** <!-- TODO -->
- **Column mapping** (plan `qa.md` column → tracker field) + exact column count:
  <!-- TODO: table. State the column count and comma count per row explicitly, and keep them
       consistent everywhere in this file — mismatched counts are the #1 source of broken imports. -->
- **File format rules:** <!-- TODO: encoding (e.g. UTF-8 with BOM), line-break token, quoting rules
  for fields containing commas/brackets/backslashes, escaping inside JSON test data -->
- **File naming / location:** <!-- TODO: e.g. `Test Cases/<project>/<phase>/<Project>-<NNN>-<Feature>.csv` -->
- **Validate before handing over:** open the exported file and confirm it parses with the expected
  field count on every row, including any parent/PBI row.

---

## Keeping this in sync
- Change a gate here ⇒ it applies to every plan from that point; note it in
  [PRODUCT.md](./PRODUCT.md) §2 (Key Decisions) if it changes what "done" means.
- Per-feature specifics (AC table, scenario list, case table, status, coverage number) live in
  `plans/NNN-*/qa.md`, never here.
