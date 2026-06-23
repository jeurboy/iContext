# {{PROJECT_NAME}} — CLAUDE.md (Layer 1)

Agent boilerplate for Claude. Single source of truth: **[CONTEXT.md](./CONTEXT.md)**.
(Mirror of `AGENT.md` / `GEMINI.md`.)

## Read first
- [CONTEXT.md](./CONTEXT.md) — architecture §1–13 (read before anything)
- [PLAN.md](./PLAN.md) — status dashboard of all features
- [plans/](./plans/) — one plan per feature; index in [plans/README.md](./plans/README.md)
- [ROLE.md](./ROLE.md) — persona panel for feature consultation

## กฎเหล็ก · Hard rules
- **Never `git commit` / `git push` unless explicitly told.**
- Summarize tech stack + architecture (CONTEXT.md §3–6) **before** implementing any service.
- Tests: unit (API) + Playwright (UI), **coverage > 80%**.
- `styles/`: no inline colors / look-and-feel — central tokens in `styles/css/tokens.css` only.
- New feature ⇒ add a plan via `/icontext-feature`, ref CONTEXT.md, set status.
- A plan reaches `done` only when: API spec synced · User Stories complete · tests > 80%.
- On status change, update **3 places**: plan file · `plans/README.md` · `PLAN.md`.
- Build context first; implement features one at a time, only when asked.

## Services (each its own git repo / submodule)
- `api/` — {{API_STACK}} · `web/` — {{WEB_STACK}} · `app/` — {{MOBILE_STACK}}

## Local ports
- Postgres `{{DB_PORT}}` · web `{{WEB_PORT}}` · api `{{API_PORT}}`
