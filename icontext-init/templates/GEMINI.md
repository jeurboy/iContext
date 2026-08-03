# {{PROJECT_NAME}} — GEMINI.md (Layer 1)

Agent boilerplate for Gemini. Single source of truth: **CONTEXT.md**.
(Mirror of `AGENTS.md` / `AGENT.md` / `CLAUDE.md`.)

## Read first
- `CONTEXT.md` — L2 architecture + workflow (read before anything); it opens with a **context map**
- `PRODUCT.md` — L2 §1 product overview · §2 key decisions · §13 open questions
- `QA.md` — L2 §9 testing standard + quality gates (read before writing any test)
- `SECURITY.md` — L2 §8 security model · §11.6 `security-review` wiring
- `DESIGN.md` — L2 §12 design tokens + design system (read before any UI work)
- `PLAN.md` — status dashboard of all features
- `plans/` — one plan per feature; index in `plans/README.md`
- `ROLE.md` — multi-agent role panel for requirement review and feature consultation

## กฎเหล็ก · Hard rules
- **Install `gstack` first:** https://github.com/garrytan/gstack — needed for `/autoplan` + the
  plan-review chain. Remind the user to install it if missing.
- **Requirement workflow before every feature plan:** ask the user to choose `/grill-with-docs` or
  `/wayfinder`. Use `/grill-with-docs` for clear-ish requirements that need sharper scope, terms,
  edge cases, and ADRs; use `/wayfinder` for large/foggy requirements without a clear solution path.
  Then use `ROLE.md` as a multi-agent panel to review the requirements before locking scope.
- **Before implementing any plan, run the review chain** — move it to `ready to implement` only
  after (via `/autoplan`, or one by one): `/plan-ceo-review` (scope) · `/plan-eng-review`
  (architecture/edge cases) · `/plan-design-review` (if UI) · `/plan-devex-review` (if
  developer-facing: API/SDK/CLI).
- **Security review skill is a dependency** — `security-review` from
  https://github.com/ice-limited/security-skill. It runs real detectors; never substitute your own
  judgment for a detector's output. Wired into two phases (SECURITY.md §11.6):
  - **Plan phase** — run the **supply-chain** detector before a plan reaches `ready to implement`.
  - **Implement phase** — run **secret · code-review · auth · dependency · docker** on each slice
    before it leaves the loop. Record findings in the plan's `ops.md` §8.
- **Implement as a loop, not one big pass** (CONTEXT.md §11.5): slice → implement → test → retest
  the whole relevant suite → review with the owner and ask for feedback → repeat, until User
  Stories pass and coverage > 80%.
- **Task status:** `to do → plan → ready to implement → implement → ready to test → done`.
- **Never `git commit` / `git push` unless explicitly told.**
- Summarize tech stack + architecture (CONTEXT.md §3–6) **before** implementing any service.
- Tests: unit (API) + Playwright (UI), **coverage > 80%** — full standard in `QA.md` §9
  (AC traceability, scenario naming, the 4 required scenario kinds, priority, effort).
- `styles/`: no inline colors / look-and-feel — central tokens in `styles/css/tokens.css` only;
  the design system (tokens, components, breakpoints, a11y) is `DESIGN.md` §12.
- New feature ⇒ add a plan via `/icontext-feature`, ref CONTEXT.md, set status.
- A plan reaches `done` only when: API spec synced · User Stories complete · tests > 80% ·
  security review clean (no unresolved high/critical finding from `SECURITY.md` §11.6).
- On status change, update **3 places**: plan file · `plans/README.md` · `PLAN.md`.
- **Second brain:** treat every `.md` file — the L2 set (`CONTEXT.md`, `PRODUCT.md`, `QA.md`,
  `SECURITY.md`, `DESIGN.md`), `PLAN.md`, `plans/`, `docs/` — as the
  project's persistent memory. Whenever a plan or approach changes, update the affected plan with
  what was done AND the reasoning/thought process behind the change, so anyone (human or agent)
  can reconstruct the thinking later. Never change direction silently.
- **One concern, one file (L2 split).** Product → `PRODUCT.md` · testing → `QA.md` · security →
  `SECURITY.md` · design → `DESIGN.md` · architecture + workflow → `CONTEXT.md`. Section numbers
  §1–13 are stable across the split. Extend the owning file and link to it — **never copy a section
  into another file or into a plan.** `CONTEXT.md` opens with the context map.
- **Any change that impacts the core architecture ⇒ update in sync, in the same change:**
  `CONTEXT.md` (incl. **§7 Data Model**) · the L2 concern file it touches (`PRODUCT.md` /
  `QA.md` / `SECURITY.md` / `DESIGN.md`) · the affected `plans/` plan · `docs/openapi.yaml` (API
  doc) · `styles/` tokens. Never let context, plan, doc, data model, and style drift apart.

## Services (each its own git repo / submodule)
- `api/` — {{API_STACK}} · `web/` — {{WEB_STACK}} · `app/` — {{MOBILE_STACK}}

## Local ports
- Postgres `{{DB_PORT}}` · web `{{WEB_PORT}}` · api `{{API_PORT}}`
