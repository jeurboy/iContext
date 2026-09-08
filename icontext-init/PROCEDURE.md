# icontext-init — procedure (agent-neutral)

> Source of truth for the `icontext-init` workflow. Any agent (Claude, Gemini, Codex,
> Cursor, …) executes these steps. Tool names below are generic; see `adapters/` for how
> each agent maps them. Templates referenced here live in `templates/` next to this file.

Scaffold the **context backbone** for a project. Stop after context is created and reviewed —
feature plans are made later by the separate `icontext-feature` procedure.

## Operating rules (always)
- **Never run `git commit` / `git push` unless the user explicitly asks.** `git init` and
  staging are fine; committing is not.
- **Never touch a database or run a migration/seed/reset/import/restore without explicit
  confirmation for that exact command, target, and environment.** Editing DB-related source files
  is not execution. Every later restricted command needs a new confirmation (CONTEXT.md §11.7).
- **Wire the safety hook when the host supports interactive hooks.** Generate the portable guard
  artifacts in `.icontext/hooks/` in every project. Register the guard only through a documented
  host hook that can return `ask` (or equivalent); merge existing hook config and never overwrite it.
- **Section-by-section confirmation:** confirm every L2 section (§1–13, wherever it lives) with the
  project owner before writing it (Step 2D). Never silently auto-fill or leave a bare placeholder
  without surfacing the section for confirm / edit / skip.
- **L2 is the context map at the root plus a `context/` folder, split by concern.**
  `CONTEXT.md` at the repo root (context map · workflow §11) · `context/DEV.md` (§3–7) ·
  `context/PRODUCT.md` (§1 · §2 · §13) · `context/QA.md` (§9) · `context/SECURITY.md`
  (§8 · §11.6) · `context/DESIGN.md` (§12) · `context/SKILLS.md` (§10 skill dependencies +
  routing) · `context/ROLE.md` (persona panel). L1 agent files stay at the repo root (that is
  where agents discover them) and `CONTEXT.md` stays at the root as the L2 entry point.
  **Section numbers stay stable** wherever a section lives, so `§N` references
  in plans and docs keep resolving. A concern lives in exactly one file — never duplicate a section
  across files; `CONTEXT.md` keeps a pointer stub (`➜ Moved to …`) where a section moved out.
- **Non-destructive — only add what's missing.** Don't delete or rewrite existing context: the
  owner's wording is the source of truth, and silently overwriting it destroys intent that the
  files were meant to capture. Existing files and CONTEXT.md sections stay verbatim; the owner
  changes content only by explicitly editing it during the Step 2D confirm. When in doubt, leave
  it and report it rather than touch it.
- **Idempotent:** re-running on an existing backbone is safe — it enters UPDATE/SYNC (Step 2C)
  and fills only the gaps, following the non-destructive rule above.
- **Stop at context.** Do not generate feature plans here.
- **Accept L1 filename casing aliases.** Treat `AGENTS.md` and `agents.md` as one logical artifact,
  and `AGENT.md` and `agent.md` as one logical artifact. Preserve the casing already used by the
  project. For a new project, ask which casing its AI tool discovers and default to uppercase when
  unknown. Generate one file from each pair, never both. If both aliases exist, report a duplication
  conflict and ask which is canonical; never merge/delete one silently.
  Detect aliases from the exact basenames returned by a directory listing (`rg --files`, `find`, or
  `readdir`), not by testing both paths independently: case-insensitive filesystems make both path
  probes resolve to the same file.

## Step 0 — Update check + pre-flight
- **Update check, up front:** run `check-update.sh` (next to this file) before the real work and
  surface its output — it prints the local **version** and whether an update is available. Running
  it first means you and the user share the same picture of which version is acting before anything
  changes. It compares the local `VERSION` to the published one, is best-effort, and never blocks
  (offline/unpublished just prints "skipped"). If an update is available, mention it, then continue.
- **Required companion skills:** use `templates/context/SKILLS.md` §10 as the routing source of truth and
  check `gstack`, `security-review`, `ui-ux-pro-max`, `impeccable`,
  `grill-with-docs`, and `wayfinder` (see
  `reference/required-skills.md`). If your agent can't check installation, just remind the user
  of the links.
- **Hook capability:** detect whether the active host exposes a documented project-local
  pre-command/pre-tool hook with an interactive approval decision. Record `supported`,
  `unsupported`, or `unknown`; do not infer a config format from another agent.

## Step 1 — Choose mode
**First, detect an existing iContext backbone** at the target root: `CONTEXT.md` plus any of
`CLAUDE.md`/(`AGENTS.md` or `agents.md`)/(`AGENT.md` or `agent.md`)/`GEMINI.md`, `context/ROLE.md`,
`PLAN.md`, `plans/`.
- Backbone present → **UPDATE/SYNC** → Step 2C. *Do not re-scaffold.*
- Backbone present **but L2 is still one monolithic `CONTEXT.md`** (no `context/DEV.md` /
  `context/PRODUCT.md` / `context/QA.md` / `context/SECURITY.md` / `context/DESIGN.md`) → this is a
  **split candidate**. Offer the L2 split as part of Step 2C, or point the user at
  `icontext-update`, which owns the refactor. Never split without the owner's explicit approval.
- Backbone already has concern files **at the repo root** (legacy layout: `DEV.md`, `PRODUCT.md`,
  `QA.md`, `SECURITY.md`, `DESIGN.md`, `SKILLS.md`, or `ROLE.md` directly in the root instead of
  `context/`) → this is a **relocate candidate**. Offer the move into `context/` via
  `icontext-update` Step 5.7; never move files without the owner's explicit approval.
- Backbone already has concern files but `context/SKILLS.md` is missing and §10 still lives in
  `CONTEXT.md` → this is a **skill-registry split candidate**. Offer the `SKILLS.md` move through
  `icontext-update` Step 5.5 with the same confirmation-first, move-not-copy rules.

If no backbone, detect whether the target dir already has code (look for `package.json`, `go.mod`,
`pubspec.yaml`, `pom.xml`, `requirements.txt`, `Cargo.toml`, `composer.json`, `*.csproj`).
- No backbone, no code → **GREENFIELD** → Step 2A.
- No backbone, code present → ask the user: **BROWNFIELD** (analyze existing → Step 2B) or greenfield anyway.

In every mode, write each L2 section only after confirming it per **Step 2D**.

## Step 2A — Greenfield: interview in depth, then generate
This is a **first-time context init** — capture the real context, don't just fill defaults.
Start with the key params: project name + description, platforms (web/mobile/both), reference
site(s), stack (defaults below, overridable), ports (defaults: db `5415`, web `3900`, api `8180`),
and **the actual service directories**. `api/`, `web/`, `app/` are only the defaults — ask the
owner what the project's services really are and what each dir is called (e.g. `backend/`,
`frontend/`, `admin/`, `worker/`, `packages/<name>/`, or a single dir). There may be one service
or many; don't assume the three-way split. Record the confirmed list in DEV.md §6 (Services)
and use those exact names everywhere (tree, docker-compose, `.vscode/launch.json`, submodule
wiring). Then run the **detailed per-section interview in Step 2D** (first-time-init depth) to
flesh out every L2 section before writing.

**Stack catalog (default ⭐ + alternatives → recommended pieces):**
- Web: **Next.js (App Router)** ⭐ / Remix / Vite+React / Nuxt / SvelteKit → React Query + Tailwind + Playwright
- Mobile: **Flutter** ⭐ / React Native (Expo) / Native → Riverpod-or-Bloc + Dio + feature-first
- API: **Go + GORM** ⭐ / NestJS / FastAPI / Spring / Laravel → Clean Architecture, minimal raw SQL
- DB: **Postgres** ⭐ / MySQL / MongoDB / SQLite → docker-compose + migrations

Then generate the tree below, copying from `templates/` and substituting `{{VARS}}`; copy the
matching `templates/stacks/<layer>-<choice>/STRUCTURE.md` into each service dir.

```
<root>/
├── CLAUDE.md  (AGENTS.md|agents.md)  (AGENT.md|agent.md)  GEMINI.md
│                                          L1 — agent boilerplate at the root (all point to CONTEXT.md)
├── CONTEXT.md                           L2 — context map · workflow §11 (repo-root entry point)
├── context/                             L2 — concern files, one per concern
│   ├── DEV.md                           §3–7 architecture · stack · repo · services · data model
│   ├── PRODUCT.md                       §1 product overview · §2 key decisions · §13 open questions
│   ├── QA.md                            §9 testing standard + quality gates
│   ├── SECURITY.md                      §8 security model · §11.6 security-review wiring
│   ├── DESIGN.md                        §12 design tokens + design system
│   ├── SKILLS.md                        §10 skill dependencies + invocation routing
│   └── ROLE.md                          persona panel (BU/PO/DEV/QA/OPS/STK)
├── PLAN.md                              status dashboard of all plans
├── docker-compose.yml                   pg:{{DB_PORT}} web:{{WEB_PORT}} api:{{API_PORT}}
├── plans/_TEMPLATE/  plans/README.md   L3 — plan template folder (role-split §0–11) + index
├── styles/css/tokens.css                central tokens (NO inline colors)
├── styles/components/*.html             style guide, one file per component
├── docs/openapi.yaml                    API spec (a.k.a. openapi.yml)
├── .vscode/launch.json                  debug configs (api/web/app · ports from §6)
├── .icontext/hooks/                     portable AI mutation guard + policy (§11.7)
├── <service dirs>                       service skeletons — names per the owner (default api/ web/ app/)
```
Service dir names above are the **default example**, not a requirement — substitute the actual
dirs the owner confirmed (could be one dir, or `backend/ frontend/ admin/ …`). In **brownfield**
(Step 2B), detect the real service dirs from the repo instead of asking.

Embed the standing rules into the L1 files + the owning L2 files (`SKILLS.md` for dependency
routing, `CONTEXT.md` for workflow): summarize stack+arch before
implementing; ask the user to choose `/grill-with-docs` or `/wayfinder` during requirement
discovery (use `/wayfinder` for large/foggy requirements without a clear solution path); use
`ROLE.md` as a multi-agent requirement review panel before locking plan scope; use gstack
`/autoplan` to prepare the plan before implementation; tests unit(API)+Playwright(UI) coverage
>80%; styles use central tokens only; each service its own repo/submodule; plans are folders
`NNN-name/` (role-split §0–11), ref
CONTEXT.md, carry task status `to do → plan → ready to implement → implement → ready to test → done`; a plan reaches `done`
only when API spec synced + User Stories complete + tests >80%; on status change update the
3 places (plan file · plans/README.md · PLAN.md). The full plan-section spec (with role
owners) is CONTEXT.md §11.1. Use `context/ROLE.md` as the multi-agent requirement review panel.

Git wiring: `git init` at the root. **Before wiring each service as a git submodule, confirm the
repo strategy with the owner** (`AskUserQuestion`) — submodules are a strong opinion and not what
everyone wants. Offer: (a) **git submodules** — each service its own repo wired under the root
(the default iContext layout); (b) **monorepo** — services as plain folders, one repo at the root;
(c) **separate repos, not wired** — `git init` each service but don't add as submodules. Apply the
owner's choice and record it in DEV.md §5 (Repo Structure) + PRODUCT.md §2 (Key Decisions). **Do not commit.**

## Step 2B — Brownfield: read & summarize an existing codebase
Produce the same backbone, but with the L2 context **derived from real code** (read-only first;
never overwrite source).
1. Inventory: read manifests, detect stack/services/layout.
2. Map architecture: entry points, routing, data layer, module boundaries (fan-out reads for
   large repos).
3. Extract data model from schema/migrations/ORM models → DEV.md §7.
4. Extract API surface from routes/controllers → `docs/`.
5. Detect real conventions (naming, lint, tests, coverage). Record, don't impose.
6. Unknowns → `<!-- TODO: confirm ... -->`. Never invent facts.
7. Write the backbone AROUND the repo (CLAUDE, the selected AGENTS/agents and AGENT/agent aliases,
   GEMINI, CONTEXT filled, ROLE, plan
   template, docs). Don't duplicate existing `styles/` or compose files; reference them.
   Don't move source — document the actual layout; put suggestions under "Migration notes".

## Step 2C — Update/Sync: fill only what's missing (idempotent)
The project already has an iContext backbone, so treat it as the source of truth: leave any file
that exists and has real content untouched, and patch only the gaps. Audit first, then add.
1. **Inventory** every expected artifact and mark present/absent: L1 `CLAUDE.md`/one of
   `AGENTS.md` or `agents.md`/one of `AGENT.md` or `agent.md`/`GEMINI.md`; treat each alias pair as
   present when either casing exists, and flag both-present as a duplication conflict. Then inventory
   the L2 set `CONTEXT.md` + `context/DEV.md` + `context/PRODUCT.md` + `context/QA.md` +
   `context/SECURITY.md` + `context/DESIGN.md` + `context/SKILLS.md` + `context/ROLE.md` and
   §1–13 per-section (a section counts as present wherever it lives); `PLAN.md`; `plans/_TEMPLATE/` +
   `plans/README.md`; `docker-compose.yml`; `docs/openapi.yaml`; `styles/css/tokens.css`;
   `styles/components/*.html`; each service's `STRUCTURE.md`.
   Include `.icontext/hooks/guard-command.sh`, `.icontext/hooks/POLICY.md`, executable permission,
   and the active host's real project-local hook registration/status.
2. **Missing files** → create from `templates/`, substituting `{{VARS}}` read from the existing
   `CONTEXT.md` where possible.
3. **Existing files** → do not overwrite. For the L2 files, only **add** sections that are absent
   and append `<!-- TODO -->` to empty ones; keep all author content verbatim.
3b. **Monolithic `CONTEXT.md`** (all of §1–13 in one file, no L2 siblings in `context/`) → propose
   the split and run it only with explicit approval, per `icontext-update` PROCEDURE Step 5.5. **Move**
   sections, never copy: the section text lands in the new file verbatim and `CONTEXT.md` keeps a
   `➜ Moved to …` pointer stub. If the owner declines, leave the monolith alone and note it.
3c. **Legacy root-level siblings** (`DEV.md`, `PRODUCT.md`, `QA.md`, `SECURITY.md`, `DESIGN.md`,
   `SKILLS.md`, or `ROLE.md` sitting at the repo root instead of `context/`) → propose the
   relocation via `icontext-update` Step 5.7; never move files silently. Create missing `context/`
   files at their new path only after that approved move, not as a fresh template copy that would
   strand the owner's root-level text.
3d. **Missing `context/SKILLS.md` with §10 still in `CONTEXT.md`** → propose moving §10 verbatim into the
   `context/SKILLS.md` template and leaving its pointer stub, per `icontext-update` Step 5.5. Treat
   this as a restructure, not a normal missing-file backfill; never create a second copy of §10.
4. **Version / format drift** → report it and propose a patch; apply only with the owner's OK.
5. Confirm each added/changed section via **Step 2D**, then output a **gap table**
   (artifact · status · action) and go to Step 3.

## Step 2D — Section-by-section confirmation (every mode)
Walk §1–13 in order **across the L2 files** (`context/PRODUCT.md` §1–2, `context/DEV.md` §3–7,
`context/SECURITY.md` §8, `context/QA.md` §9, `context/SKILLS.md` §10, `CONTEXT.md` §11,
`context/SECURITY.md` §11.6, `context/DESIGN.md` §12, `context/PRODUCT.md` §13).
For each section, show the proposed/detected value (or
"empty") and ask the project owner via `AskUserQuestion` to **confirm as-is / edit / skip**
(skip → `<!-- TODO -->`). Write a section only after its confirmation, into its owning file.

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

## Step 2E — Install and verify the agent mutation guard
1. Copy `templates/.icontext/hooks/guard-command.sh` and `POLICY.md` into the target project and
   keep the guard executable. In UPDATE/SYNC mode, create/patch only after the owner approves the
   listed gap; never replace owner changes silently.
2. If Step 0 found a documented interactive project hook, show the exact host config file and merge
   required to run the guard before shell commands. Preserve unrelated hooks. For an existing config,
   get explicit approval before the merge.
3. If the host has no interactive approval hook, do not install a permanent allow/block-only hook.
   Keep the L1 + CONTEXT.md §11.7 rules and record `hook unavailable; policy enforced by instructions`.
4. Dry-run the guard: `git status` must allow; `git commit`, `git push`, a direct DB client, and a
   seed/migration command must ask. When wired, repeat these as non-executing probes through the real
   host hook path. Do not run the restricted actions themselves merely to test the guard.
5. Report one of: `hook active and verified`, `hook artifacts installed; host wiring pending`, or
   `hook unavailable; policy enforced by instructions`.

## Step 3 — Review & stop
Summarize CONTEXT.md (and, in UPDATE/SYNC, the gap table), report the Step 2E hook status, ask about remaining `<!-- TODO -->`
gaps worth filling now, then tell the user: context is ready — run `icontext-feature` for the
first plan. Do not implement.
