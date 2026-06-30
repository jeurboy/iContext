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
<!-- High-level scenarios to cover: happy path, edge cases, error handling, security/permissions. e.g.:
- TS-01 <scenario>: <what it validates> -->

### Test Cases · `QA`
| ID | Scenario | Steps | Expected | Type (unit/UI/e2e) | Status |
|----|----------|-------|----------|--------------------|--------|
| TC-01 | <!-- TS-01 --> | <!-- ... --> | <!-- ... --> | <!-- unit --> | to do |

### Test Status · `QA`
<!-- Overall: not started / in progress / passing / failing / blocked.
     Per-case status lives in the table above (to do / pass / fail / blocked). -->

### Test Coverage · `QA DEV`
<!-- Current coverage % vs the > 80% gate; modules covered and remaining gaps. -->
