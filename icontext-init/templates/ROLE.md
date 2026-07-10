# {{PROJECT_NAME}} — ROLE.md (Multi-Agent Role Panel)

Use this panel during requirement discovery and plan review. The primary workflow is:
choose `/grill-with-docs` or `/wayfinder` for requirement discovery → this role panel reviews it
→ `/autoplan` prepares the plan for implementation. Each feature records the outcome in **§4
Requirement Discovery / Requirement Review / Persona Panel** (`stk.md`). Sections in a plan are
owned by these roles (see CONTEXT.md §11.1).

## Responsibility roles
| Tag | Role | Cares about |
|-----|------|-------------|
| **BU** | ธุรกิจ / Business | value, cost, market fit, pricing/booking rules |
| **PO** | เจ้าของงาน / Product Owner | scope, priority, acceptance, user stories |
| **DEV** | พัฒนา / Development | architecture fit, testability, tech debt, data model, API |
| **QA** | ทดสอบ / Testing | coverage >80%, edge cases, regressions, test plan |
| **OPS** | DevOps / Deploy | deploy, env, migrations, secrets, observability |
| **STK** | Stakeholder / end user | real-world usability, does it actually help |

## Concrete panel (starter team — edit to fit the org)
| Persona | Name | Plays |
|---------|------|-------|
| UX/UI Designer | "Mai" | DEV (design) · STK — flows, tokens, accessibility |
| Dev Lead | "Krit" | DEV · OPS — architecture, clean boundaries, deploy/migration risk |
| Product Owner A | "Ploy" | PO — value, scope, acceptance |
| Product Owner B | "Nat" | PO · BU — policy, pricing/booking rules, edge cases |
| End user (staff) | "Som" | STK — usability, missing shortcuts |

<!-- TODO: add a dedicated QA persona if needed; until then Dev Lead covers QA review. -->

## Requirement Review Protocol
Run this after the selected requirement discovery route (`/grill-with-docs` or `/wayfinder`) and
before locking the plan scope.

If the agent supports subagents, dispatch one reviewer per role/persona in parallel. If not,
simulate separate passes in one response. Each reviewer must stay in their lane and return:

| Field | Meaning |
|-------|---------|
| Works | What is clear, valuable, or ready |
| Concern | The biggest ambiguity, risk, missing requirement, or edge case |
| Suggestion | The concrete requirement/acceptance/test/design change they recommend |
| Plan impact | Which role file should change: `bu.md`, `po.md`, `dev.md`, `qa.md`, `ops.md`, or `stk.md` |

Fold accepted changes back into the plan before moving to `/autoplan`.

## Persona Panel Protocol
For a lighter stakeholder pass, each persona gives: what works · concern · suggestion. Keep it
short and specific. Collect into the plan's **§4 Requirement Discovery / Requirement Review /
Persona Panel** section.
