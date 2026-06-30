# {{PROJECT_NAME}} — GEMINI.md (Layer 1)

Agent boilerplate for Gemini. Single source of truth: **CONTEXT.md**.
(Mirror of `AGENT.md` / `CLAUDE.md`.)

## Read first
- `CONTEXT.md` — architecture §1–13 (read before anything)
- `PLAN.md` — status dashboard of all features
- `plans/` — one plan per feature; index in `plans/README.md`
- `ROLE.md` — persona panel for feature consultation

## กฎเหล็ก · Hard rules
- **Install `gstack` first:** https://github.com/garrytan/gstack — needed for `/autoplan` + the
  plan-review chain. Remind the user to install it if missing.
- **Before implementing any plan, run the review chain** — move it to `ready to implement` only
  after (via `/autoplan`, or one by one): `/plan-ceo-review` (scope) · `/plan-eng-review`
  (architecture/edge cases) · `/plan-design-review` (if UI) · `/plan-devex-review` (if
  developer-facing: API/SDK/CLI).
- **Implement as a loop, not one big pass** (CONTEXT.md §11.5): slice → implement → test → retest
  the whole relevant suite → review with the owner and ask for feedback → repeat, until User
  Stories pass and coverage > 80%.
- **Task status:** `to do → plan → ready to implement → implement → ready to test → done`.
- **Never `git commit` / `git push` unless explicitly told.**
- Summarize tech stack + architecture (CONTEXT.md §3–6) **before** implementing any service.
- Tests: unit (API) + Playwright (UI), **coverage > 80%**.
- `styles/`: no inline colors / look-and-feel — central tokens in `styles/css/tokens.css` only.
- New feature ⇒ add a plan via `/icontext-feature`, ref CONTEXT.md, set status.
- A plan reaches `done` only when: API spec synced · User Stories complete · tests > 80%.
- On status change, update **3 places**: plan file · `plans/README.md` · `PLAN.md`.
- **Any change that impacts the core architecture ⇒ update in sync, in the same change:**
  `CONTEXT.md` (incl. **§7 Data Model**) · the affected `plans/` plan · `docs/openapi.yaml` (API
  doc) · `styles/` tokens. Never let context, plan, doc, data model, and style drift apart.

## Services (each its own git repo / submodule)
- `api/` — {{API_STACK}} · `web/` — {{WEB_STACK}} · `app/` — {{MOBILE_STACK}}

## Local ports
- Postgres `{{DB_PORT}}` · web `{{WEB_PORT}}` · api `{{API_PORT}}`
