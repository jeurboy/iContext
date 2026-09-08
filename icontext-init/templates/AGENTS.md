# {{PROJECT_NAME}} — AGENTS.md / agents.md (Layer 1, agent instructions)

Agent boilerplate for OpenAI Codex and other tools that discover project instructions. Single source
of truth: **CONTEXT.md**. Generate this canonical template as either `AGENTS.md` or `agents.md`
according to the target tool; do not create both.

## Read first
- `CONTEXT.md` — L2 context map + workflow (read before anything)
- `context/DEV.md` — L2 §3–7 architecture, stack, repo, services, and data model
- `context/PRODUCT.md` — L2 §1 product overview · §2 key decisions · §13 open questions
- `context/QA.md` — L2 §9 testing standard + quality gates (read before writing any test)
- `context/SECURITY.md` — L2 §8 security model · §11.6 `security-review` wiring
- `context/DESIGN.md` — L2 §12 design tokens + design system (read before any UI work)
- `context/SKILLS.md` — L2 §10 direct skill dependencies, triggers, ordering, and fallbacks
- `PLAN.md` — status dashboard of all features
- `plans/` — one folder per feature (`NNN-name/`, role-split); index in `plans/README.md`
- `context/ROLE.md` — multi-agent role panel for requirement review and feature consultation

## กฎเหล็ก · Hard rules
- **Follow the skill registry:** read `context/SKILLS.md` §10 before selecting or composing skills. Honor
  its required/alternative classes, invocation routes, ordering, exclusions, and fallbacks. Never
  claim an unavailable skill or detector ran.
- **Security review remains a hard gate:** follow `context/SECURITY.md` §11.6 and the route in `context/SKILLS.md`
  §10; never substitute an LLM opinion for required detector output.
- **Implement as a loop, not one big pass** (CONTEXT.md §11.5): slice → implement → test → retest
  the whole relevant suite → review with the owner and ask for feedback → repeat, until User
  Stories pass and coverage > 80%.
- **Task status:** `to do → plan → ready to implement → implement → ready to test → done`.
- **Never `git commit` or `git push` unless the user explicitly confirms that exact action.** A
  later commit/push needs a new confirmation. If this host supports interactive pre-tool hooks,
  keep the project guard in `.icontext/hooks/` wired and active (CONTEXT.md §11.7).
- **Never access or change a database, run migrations, seed/reset/import/restore data, or enable a
  DB-changing startup flag without explicit confirmation for that exact command, target, and
  environment.** Editing migration/seed source is allowed inside an authorized code change;
  executing it is separately gated (CONTEXT.md §11.7).
- Summarize tech stack + architecture (`context/DEV.md` §3–6) **before** implementing any service.
- Tests: unit (API) + Playwright (UI), **coverage > 80%** — full standard in `context/QA.md` §9
  (AC traceability, scenario naming, the 4 required scenario kinds, priority, effort).
- `styles/`: no inline colors / look-and-feel — central tokens in `styles/css/tokens.css` only;
  the design system (tokens, components, breakpoints, a11y) is `context/DESIGN.md` §12.
- New feature ⇒ add a plan (`/icontext-feature`), ref CONTEXT.md, set status.
- A plan reaches `done` only when: API spec synced · User Stories complete · tests > 80% ·
  security review clean (no unresolved high/critical finding from `context/SECURITY.md` §11.6).
- On status change, update **3 places**: plan file · `plans/README.md` · `PLAN.md`.
- **Second brain:** treat every `.md` file — the L2 set (`CONTEXT.md` at the root plus `context/`: `DEV.md`, `PRODUCT.md`,
  `QA.md`, `SECURITY.md`, `DESIGN.md`, `SKILLS.md`, `ROLE.md`), `PLAN.md`, `plans/`, `docs/` — as the
  project's persistent memory. Whenever a plan or approach changes, update the affected plan with
  what was done AND the reasoning/thought process behind the change, so anyone (human or agent)
  can reconstruct the thinking later. Never change direction silently.
- **One concern, one file (L2 split).** Development + architecture → `context/DEV.md` · product → `context/PRODUCT.md` ·
  testing → `context/QA.md` · security → `context/SECURITY.md` · design → `context/DESIGN.md` ·
  skills → `context/SKILLS.md` · workflow → `CONTEXT.md` (repo root). Section numbers
  §1–13 are stable across the split. Extend the owning file and link to it — **never copy a section
  into another file or into a plan.** `CONTEXT.md` opens with the context map.
- **Any change that impacts the core architecture ⇒ update in sync, in the same change:**
  `context/DEV.md` (incl. **§7 Data Model**) · `CONTEXT.md` workflow · the L2 concern file it
  touches (`context/PRODUCT.md` / `context/QA.md` / `context/SECURITY.md` / `context/DESIGN.md` /
  `context/SKILLS.md`) · the affected `plans/` plan · `docs/openapi.yaml` (API
  doc) · `styles/` tokens. Never let context, plan, doc, data model, and style drift apart.

## Services (each its own git repo / submodule)
- `api/` — {{API_STACK}} · `web/` — {{WEB_STACK}} · `app/` — {{MOBILE_STACK}}

## Local ports
- Postgres `{{DB_PORT}}` · web `{{WEB_PORT}}` · api `{{API_PORT}}`
