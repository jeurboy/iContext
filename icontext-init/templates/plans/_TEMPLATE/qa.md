# NNN · QA (Testing) — <Feature Name>

> ref: [CONTEXT.md](../../CONTEXT.md) · **standard:** [QA.md](../../context/QA.md) §9 · index: [README.md](./README.md)
> Owns: test plan + acceptance for THIS feature. Coverage gate > 80%.
> The authoring standard (naming, types, priority, effort, reusability, export) lives in
> [QA.md](../../context/QA.md) §9 — **don't restate it here**, just follow it.

## 9. Test Plan (>80%) · `QA DEV OPS`

### How to run (test method) · `QA DEV`
<!-- Be concrete so anyone can reproduce it:
- Commands per service (QA.md §9.1), e.g. API `go test ./... -cover`, UI `npm run test:e2e`
- Expected result + how coverage is measured (target > 80%)
- Test data / fixtures / env needed
- Run the real app and observe (gstack `/qa` to test systematically, `/verify` to confirm a fix). -->

### Implementation loop & regression · `QA DEV`
<!-- Build in slices (CONTEXT.md §11.5): implement → test → RETEST the whole relevant suite after
     every change → review with the owner + ask feedback → repeat. Don't only run the new test;
     re-run the suite so a fix doesn't break something else. -->

### Acceptance criteria (per User Story → po.md §3 / bu.md) · `QA PO`
<!-- Given / When / Then for each story. All must pass before `done`.
     🛑 QA.md §9.2: every test case below MUST trace back to one of these AC ids — never write a
        test from a dev's own assumption. If this plan has no PO acceptance criteria, the plan is
        NOT accepted: go back to the PO before implementing or testing. -->

| AC ID | User Story (po.md §3) | Given / When / Then | Covered by |
|-------|-----------------------|---------------------|------------|
| AC-01 | <!-- US-01 --> | <!-- ... --> | <!-- TC-01, TC-02 --> |

### Test Scenarios · `QA`
<!-- Naming per QA.md §9.3 (Title 1 short + Title 2 full), types per §9.4, and all four kinds
     per §9.5 (Success · Alternative · Boundary · Edge incl. permission-denied). One interface per
     scenario — never mix API and UI. Note the technique used (EP / BVA / State Transition). e.g.:
- TS-01 [API][Success] Login สำเร็จ — ตรวจสอบการ Login ด้วย email + password ที่ถูกต้องผ่าน Authentication API ได้สำเร็จ
- TS-02 [Web UI][Alternative] Login ผิดบน Web — ตรวจสอบการจัดการเมื่อผู้ใช้กรอก password ไม่ถูกต้องและระบบแสดง error -->

### Test Cases · `QA`
<!-- Field rules live in QA.md: Test_type §9.4 · Priority §9.6 · Effort §9.7 (max 4h; split beyond
     that) · Reusability/parameterization §9.8. Every case needs an AC ref, pre-conditions, steps
     WITH test data, and a measurable expected result. -->
| ID | AC Ref | Scenario | Pre-conditions | Steps + Test Data | Expected | Test_type | Priority | Effort | Automation | Status |
|----|--------|----------|----------------|-------------------|----------|-----------|----------|--------|------------|--------|
| TC-01 | <!-- AC-01 --> | <!-- TS-01 --> | <!-- ... --> | <!-- ... --> | <!-- ... --> | <!-- API --> | <!-- High --> | <!-- 1h --> | <!-- Automatable --> | to do |

### Scenario checklist (before `ready to test`) · `QA`
<!-- - [ ] Every Acceptance Criterion (po.md §3) is covered by ≥1 Success case, and every case
           traces back to an AC id (QA.md §9.2 — no dev-invented tests)
     - [ ] All four kinds present: Success · Alternative · Boundary · Edge (QA.md §9.5)
     - [ ] Edge includes permission-denied / deny-by-default per role (SECURITY.md §8.2)
     - [ ] API and UI scenarios separated; Test_type consistent with Title 2
     - [ ] Every case has pre-conditions, test data, measurable expected result, Priority, Effort
     - [ ] Effort ≤ 4h per case; anything larger split (QA.md §9.7)
     - [ ] Reusable values parameterized instead of hard-coded (QA.md §9.8)
     - [ ] No duplicate/redundant cases; reviewed with the team before finalizing
     - [ ] If this project exports to a tracker, the export follows QA.md §9.10 -->

### Test Status · `QA`
<!-- Overall: not started / in progress / passing / failing / blocked.
     Per-case status lives in the table above (to do / pass / fail / blocked).
     Summarize each run: total cases, pass/fail/blocked counts, open issues. -->

### Test Coverage · `QA DEV`
<!-- Current coverage % vs the > 80% gate; modules covered and remaining gaps.
     Link each automated case to the test file/command that runs it, so the scenario table and the
     coverage number describe the same thing. -->
