# Plans index — {{PROJECT_NAME}}

Each feature is a **folder** `NNN-<slug>/` containing role files (`bu/po/dev/qa/ops/stk.md`)
plus a `README.md` index. Template: [`_TEMPLATE/`](./_TEMPLATE/). Section→file map: CONTEXT.md §11.1.
Every plan refs [CONTEXT.md](../CONTEXT.md). Status mirror of [`../PLAN.md`](../PLAN.md).

A change to a feature that already has a plan is a **CR** (`CR-<M>.md` inside that plan's
folder, linking back to it) — not a new plan row. Show it as a sub-entry of the owning plan,
e.g. `| [001-booking — CR-1](./001-booking/CR-1.md) | Booking flow · CR: promo scope | ready to test |`.

> On any status change, update **3 places**: the plan's `README.md` · this index · `../PLAN.md`.

| Plan | Feature | Status |
|------|---------|--------|
| [_TEMPLATE](./_TEMPLATE/) | (template folder) | — |
<!-- e.g. | [001-booking](./001-booking/) | Booking flow | to do | -->

Task status: `to do → plan → ready to implement → implement → ready to test → done`
