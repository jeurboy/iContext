# icontext-init — procedure (agent-neutral)

> Source of truth for the `icontext-init` workflow. Any agent (Claude, Gemini, Codex,
> Cursor, …) executes these steps. Tool names below are generic; see `adapters/` for how
> each agent maps them. Templates referenced here live in `templates/` next to this file.

Scaffold the **context backbone** for a project. Stop after context is created and reviewed —
feature plans are made later by the separate `icontext-feature` procedure.

## Operating rules (always)
- **Never run `git commit` / `git push` unless the user explicitly asks.** `git init` and
  staging are fine; committing is not.
- **Hybrid input:** ask only the key parameters; leave the rest as `<!-- TODO: ... -->`.
- **Stop at context.** Do not generate feature plans here.

## Step 0 — Pre-flight: required companion skills
Check `gstack`, `ux-ui-pro-max`, `impeccable` (see `reference/required-skills.md`). If a tool
to check installation isn't available in your agent, just remind the user of the links.

## Step 1 — Choose mode
Detect whether the target dir already has code (look for `package.json`, `go.mod`,
`pubspec.yaml`, `pom.xml`, `requirements.txt`, `Cargo.toml`, `composer.json`, `*.csproj`).
- No code → **GREENFIELD** → Step 2A.
- Code present → ask the user: **BROWNFIELD** (analyze existing → Step 2B) or greenfield anyway.

## Step 2A — Greenfield: ask key params, then generate
Ask (or read from the user's prompt): project name + description, platforms (web/mobile/both),
reference site(s), stack (defaults below, overridable), ports (defaults: db `5415`, web `3900`,
api `8180`).

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
├── plans/_TEMPLATE.md  plans/README.md  L3 — plan template (§0–11) + plans index
├── styles/css/tokens.css                central tokens (NO inline colors)
├── styles/components/*.html             style guide, one file per component
├── docs/openapi.yaml                    API spec
├── api/  web/  app/                     service skeletons (own git repos / submodules)
```

Embed the standing rules into the L1 files + CONTEXT.md: summarize stack+arch before
implementing; tests unit(API)+Playwright(UI) coverage >80%; styles use central tokens only;
each service its own repo/submodule; plans are `NNN-name.md` using the §0–11 structure, ref
CONTEXT.md, carry status `todo → implement → ready to test → done`; a plan reaches `done`
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

## Step 3 — Review & stop
Summarize CONTEXT.md, ask about `<!-- TODO -->` gaps worth filling now, then tell the user:
context is ready — run `icontext-feature` for the first plan. Do not implement.
