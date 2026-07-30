# NNN · QA (Testing) — <Feature Name>

> ref: [CONTEXT.md](../../CONTEXT.md) · index: [README.md](./README.md)
> Owns: test plan + acceptance. Coverage gate > 80%.

## 9. Test Plan (>80%) · `QA DEV OPS`
<!-- Unit (API) + Playwright (UI). Coverage > 80% before `done`. -->

### How to run (test method) · `QA DEV`
<!-- Be concrete so anyone can reproduce it:
- Commands: e.g. API `go test ./... -cover`, UI `npm run test:e2e`
- Expected result + how coverage is measured (target > 80%)
- Test data / fixtures / env needed
- Run the real app and observe (gstack `/qa` to test systematically, `/verify` to confirm a fix). -->

### Implementation loop & regression · `QA DEV`
<!-- Build in slices (CONTEXT.md §11.5): implement → test → RETEST the whole relevant suite after
     every change → review with the owner + ask feedback → repeat. Don't only run the new test;
     re-run the suite so a fix doesn't break something else. -->

### Acceptance criteria (per User Story → po.md §3 / bu.md)
<!-- Given / When / Then for each story. All must pass before `done`. -->

### Test Scenarios · `QA`
<!-- Naming: `[Type][Result] - ตรวจสอบ + Actor + Action + Object + Condition + Result`
     - [Type]: API / UI (Web) / UI (Mobile) / Other. If one feature works via both API and UI
       ⇒ write SEPARATE scenarios per interface (never mix in one scenario); Type must match
       how the case is actually tested.
     - [Result]: Success (happy path) / Alternative (negative + error handling).
     Cover 4 kinds: Success · Alternative · Boundary (min/max data) · Edge (concurrency, race,
       security/permissions).
     Pick a technique per case: EP (Equivalence Partitioning) · BVA (Boundary Value Analysis) ·
       State Transition.
     e.g.:
- TS-01 [API][Success] Login สำเร็จ: validates auth API with correct credentials
- TS-02 [UI][Alternative] Login ผิดบน Web: validates error message on wrong password -->

### Test Cases · `QA`
<!-- Every case needs: pre-conditions, steps WITH test data, measurable expected result.
     Priority: Critical (core flows, security, data integrity) · High (key features, error
       handling, integrations) · Medium (secondary features, alt flows, boundaries) · Low
       (UI details, rare edges).
     Effort: 0.5h (display/layout) · 1h (basic CRUD, form validation) · 2h (complex logic,
       multi-step) · 3h (e2e, performance, security) · >4h ⇒ split into smaller cases.
     Reusability: parameterize values (`กรอก {field} = {test_data}`) instead of hard-coding;
       share modular steps across cases (e.g. pre-condition "logged in"). -->
| ID | Scenario | Pre-conditions | Steps + Test Data | Expected | Type (unit/UI/e2e) | Priority | Effort | Status |
|----|----------|----------------|-------------------|----------|--------------------|----------|--------|--------|
| TC-01 | <!-- TS-01 --> | <!-- ... --> | <!-- ... --> | <!-- ... --> | <!-- unit --> | <!-- High --> | <!-- 1h --> | to do |

### Scenario checklist (before `ready to test`) · `QA`
<!-- - [ ] Success cases cover every Acceptance Criterion (po.md §3)
     - [ ] Key Alternative/Error cases covered
     - [ ] API and UI scenarios separated; Type consistent with the scenario title
     - [ ] Every case has pre-conditions, test data, measurable expected result, Priority, Effort -->

### Test Status · `QA`
<!-- Overall: not started / in progress / passing / failing / blocked.
     Per-case status lives in the table above (to do / pass / fail / blocked). -->

### Test Coverage · `QA DEV`
<!-- Current coverage % vs the > 80% gate; modules covered and remaining gaps. -->
