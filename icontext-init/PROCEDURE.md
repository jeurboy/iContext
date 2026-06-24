# icontext-init — procedure (agent-neutral)

> Source of truth for the `icontext-init` workflow. Any agent (Claude, Gemini, Codex,
> Cursor, …) executes these steps. Tool names below are generic; see `adapters/` for how
> each agent maps them. Templates referenced here live in `templates/` next to this file.

Scaffold the **context backbone** for a project. Stop after context is created and reviewed —
feature plans are made later by the separate `icontext-feature` procedure.

## Operating rules (always)
- **Never run `git commit` / `git push` unless the user explicitly asks.** `git init` and
  staging are fine; committing is not.
- **Section-by-section confirmation:** confirm every CONTEXT.md section (§1–13) with the project
  owner before writing it (Step 2D). Never silently auto-fill or leave a bare placeholder
  without surfacing the section for confirm / edit / skip.
- **Non-destructive (hard rule):** NEVER delete, overwrite, or rewrite existing context. The
  skill only **adds the missing pieces**. Existing files and existing CONTEXT.md sections are
  preserved verbatim; the owner may change content only by explicitly editing it during the
  Step 2D confirm. When in doubt, leave it and report it — do not touch it.
- **Idempotent:** if an iContext backbone already exists, run UPDATE/SYNC (Step 2C) — fill only
  what's missing, following the non-destructive rule above.
- **Stop at context.** Do not generate feature plans here.

## Step 0 — Update check + pre-flight
- **Update check (FIRST, every run, before anything else):** run `check-update.sh` (next to this
  file) and surface its output — it prints the local **version** and whether an update is
  available. It compares the local `VERSION` to the published one and is best-effort — it never
  blocks (offline/unpublished just prints "skipped"). If an update is available, mention it,
  then continue.
- **Required companion skills:** check `gstack`, `ux-ui-pro-max`, `impeccable` (see
  `reference/required-skills.md`). If your agent can't check installation, just remind the user
  of the links.

## Step 1 — Choose mode
**First, detect an existing iContext backbone** at the target root: `CONTEXT.md` plus any of
`CLAUDE.md`/`AGENT.md`/`GEMINI.md`, `ROLE.md`, `PLAN.md`, `plans/`.
- Backbone present → **UPDATE/SYNC** → Step 2C. *Do not re-scaffold.*

If no backbone, detect whether the target dir already has code (look for `package.json`, `go.mod`,
`pubspec.yaml`, `pom.xml`, `requirements.txt`, `Cargo.toml`, `composer.json`, `*.csproj`).
- No backbone, no code → **GREENFIELD** → Step 2A.
- No backbone, code present → ask the user: **BROWNFIELD** (analyze existing → Step 2B) or greenfield anyway.

In every mode, write each CONTEXT.md section only after confirming it per **Step 2D**.

## Step 2A — Greenfield: interview in depth, then generate
This is a **first-time context init** — capture the real context, don't just fill defaults.
Start with the key params: project name + description, platforms (web/mobile/both), reference
site(s), stack (defaults below, overridable), ports (defaults: db `5415`, web `3900`, api `8180`).
Then run the **detailed per-section interview in Step 2D** (first-time-init depth) to flesh out
every CONTEXT.md section before writing.

**Stack catalog (default ⭐ + alternatives → recommended pieces):**
- Web: **Next.js (App Router)** ⭐ / Remix / Vite+React / Nuxt / SvelteKit → React Query + Tailwind + Playwright
- Mobile: **Flutter** ⭐ / React Native (Expo) / Native → Riverpod-or-Bloc + Dio + feature-first
- API: **Go + GORM** ⭐ / NestJS / FastAPI / Spring / Laravel → Clean Architecture, minimal raw SQL
- DB: **Postgres** ⭐ / MySQL / MongoDB / SQLite → docker-compose + migrations

Then generate the tree below, copying from `templates/` and substituting `{{VARS}}`; copy the
matching `templates/stacks/<layer>-<choice>/STRUCTURE.md` into each service dir.

```
<root>/
├── CLAUDE.md  AGENT.md  GEMINI.md       L1 — agent boilerplate (all point to CONTEXT.md)
├── CONTEXT.md                           L2 — architecture §1–13 (single source of truth)
├── ROLE.md                              persona panel (BU/PO/DEV/QA/OPS/STK)
├── PLAN.md                              status dashboard of all plans
├── docker-compose.yml                   pg:{{DB_PORT}} web:{{WEB_PORT}} api:{{API_PORT}}
├── plans/_TEMPLATE/  plans/README.md   L3 — plan template folder (role-split §0–11) + index
├── styles/css/tokens.css                central tokens (NO inline colors)
├── styles/components/*.html             style guide, one file per component
├── docs/openapi.yaml                    API spec (a.k.a. openapi.yml)
├── .vscode/launch.json                  debug configs (api/web/app · ports from §6)
├── api/  web/  app/                     service skeletons (own git repos / submodules)
```

Embed the standing rules into the L1 files + CONTEXT.md: summarize stack+arch before
implementing; tests unit(API)+Playwright(UI) coverage >80%; styles use central tokens only;
each service its own repo/submodule; plans are folders `NNN-name/` (role-split §0–11), ref
CONTEXT.md, carry task status `to do → plan → ready to implement → implement → ready to test → done`; a plan reaches `done`
only when API spec synced + User Stories complete + tests >80%; on status change update the
3 places (plan file · plans/README.md · PLAN.md). The full plan-section spec (with role
owners) is CONTEXT.md §11.1.

Git wiring: `git init` at root and in each service dir. **Do not commit.**

## Step 2B — Brownfield: read & summarize an existing codebase
Produce the same backbone, but with CONTEXT.md **derived from real code** (read-only first;
never overwrite source).
1. Inventory: read manifests, detect stack/services/layout.
2. Map architecture: entry points, routing, data layer, module boundaries (fan-out reads for
   large repos).
3. Extract data model from schema/migrations/ORM models → CONTEXT.md §5.
4. Extract API surface from routes/controllers → `docs/`.
5. Detect real conventions (naming, lint, tests, coverage). Record, don't impose.
6. Unknowns → `<!-- TODO: confirm ... -->`. Never invent facts.
7. Write the backbone AROUND the repo (CLAUDE/AGENTS/GEMINI, CONTEXT filled, ROLE, plan
   template, docs). Don't duplicate existing `styles/` or compose files; reference them.
   Don't move source — document the actual layout; put suggestions under "Migration notes".

## Step 2C — Update/Sync: fill only what's missing (idempotent)
The project already has an iContext backbone. **Never overwrite a file that exists and has real
content.** Audit, then patch only the gaps.
1. **Inventory** every expected artifact and mark present/absent: L1 `CLAUDE.md`/`AGENT.md`/
   `GEMINI.md`; `CONTEXT.md` §1–13 (per-section); `ROLE.md`; `PLAN.md`; `plans/_TEMPLATE/` +
   `plans/README.md`; `docker-compose.yml`; `docs/openapi.yaml`; `styles/css/tokens.css`;
   `styles/components/*.html`; each service's `STRUCTURE.md`.
2. **Missing files** → create from `templates/`, substituting `{{VARS}}` read from the existing
   `CONTEXT.md` where possible.
3. **Existing files** → do not overwrite. For `CONTEXT.md`, only **add** sections that are absent
   and append `<!-- TODO -->` to empty ones; keep all author content verbatim.
4. **Version / format drift** → report it and propose a patch; apply only with the owner's OK.
5. Confirm each added/changed section via **Step 2D**, then output a **gap table**
   (artifact · status · action) and go to Step 3.

## Step 2D — Section-by-section confirmation (every mode)
Walk `CONTEXT.md` §1–13 in order. For each section, show the proposed/detected value (or
"empty") and ask the project owner via `AskUserQuestion` to **confirm as-is / edit / skip**
(skip → `<!-- TODO -->`). Write a section only after its confirmation.

**Depth depends on the mode:**
- **First-time init (GREENFIELD, no existing context)** → go DEEP. Treat this as a structured
  interview: for every section ask detailed, specific questions and draw out real answers rather
  than accepting defaults — e.g. §1 target users + value prop + success metric; §2 the actual
  decisions + why + alternatives rejected; §3–6 concrete architecture, services, ports, data
  entities + relationships; §7 each entity's fields; §8 auth model + roles + secrets; §9 coverage
  targets + test types; §11 workflow specifics; §12 token sources; §13 known unknowns. Only fall
  back to `<!-- TODO -->` when the owner genuinely doesn't know yet. Do not rush — this is the one
  chance to capture the real context.
- **BROWNFIELD** → present what was derived from the code and ask the owner to confirm/correct
  each section; probe for intent the code can't reveal (users, decisions, security model).
- **UPDATE/SYNC** → light touch. Only ask about absent/empty sections; show sections that already
  have author content for a quick confirm but **do not overwrite** them unless the owner edits.

Batch closely related sections into one prompt to keep it manageable (e.g. §3–6 architecture,
§8–9 quality), but in first-time init prefer thoroughness over brevity.

**Mandatory fields — always ask, every mode (incl. UPDATE/SYNC's light touch):** some fields must
not be left blank. If they are missing, empty, an unsubstituted `{{VAR}}`, or a bare
`<!-- TODO -->`, **ask the user** rather than skip — do not write the context with them unfilled.
- **§1 Product Overview — project description** (the `{{PROJECT_DESC}}` / "What:" line): if the
  context has no project description, always ask the user for it. (Also treat platforms and the
  one-line product purpose as mandatory.)

## Step 3 — Review & stop
Summarize CONTEXT.md (and, in UPDATE/SYNC, the gap table), ask about remaining `<!-- TODO -->`
gaps worth filling now, then tell the user: context is ready — run `icontext-feature` for the
first plan. Do not implement.
