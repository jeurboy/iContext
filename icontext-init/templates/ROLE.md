# {{PROJECT_NAME}} — ROLE.md (Persona Panel)

The persona panel consulted in each plan's **§4 Persona Panel**. `/icontext-feature` asks every
time whether to run it. Sections in a plan are owned by these roles (see CONTEXT.md §11.1).

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

## How a Persona Review runs
For the feature, each persona gives: ✅ what works · ⚠️ concern · 💡 suggestion. Keep it short
and specific. Collect into the plan's **§4 Persona Panel** section.
