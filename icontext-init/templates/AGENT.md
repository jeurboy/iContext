# {{PROJECT_NAME}} — AGENT.md (Layer 1, vendor-neutral boilerplate)

Generic agent boilerplate (any AI). The single source of truth is **CONTEXT.md**.

## Read first
- `CONTEXT.md` — architecture §1–13 (read before anything)
- `PLAN.md` — status dashboard of all features
- `plans/` — one plan per feature (`NNN-name.md`); index in `plans/README.md`
- `ROLE.md` — persona panel for feature consultation

## กฎเหล็ก · Hard rules
- **Never `git commit` / `git push` unless explicitly told.**
- Summarize tech stack + architecture (CONTEXT.md §3–6) **before** implementing any service.
- Tests: unit (API) + Playwright (UI), **coverage > 80%**.
- `styles/`: no inline colors / look-and-feel — central tokens in `styles/css/tokens.css` only.
- New feature ⇒ add a plan (`/icontext-feature`), ref CONTEXT.md, set status.
- A plan reaches `done` only when: API spec synced · User Stories complete · tests > 80%.
- On status change, update **3 places**: plan file · `plans/README.md` · `PLAN.md`.

## Services (each its own git repo / submodule)
- `api/` — {{API_STACK}} · `web/` — {{WEB_STACK}} · `app/` — {{MOBILE_STACK}}

## Local ports
- Postgres `{{DB_PORT}}` · web `{{WEB_PORT}}` · api `{{API_PORT}}`
