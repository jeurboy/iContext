# iContext

**Version 1.10.2** · five portable agent-skills that bootstrap, audit, visualize, and maintain a **layered project
context** for web/mobile builds — so any AI agent (Claude, Gemini, Codex, Cursor, …) starts every
session already knowing your architecture, conventions, and plan status.

| Skill | Command | Does |
|-------|---------|------|
| **icontext-init** | `/icontext-init` | Scaffold the context backbone (L1 agent files · L2 `CONTEXT.md` · L3 `plans/`) + service skeletons. **Greenfield** (new), **brownfield** (read & summarize an existing codebase), or **update/sync** (fill only the missing pieces of an existing backbone). Confirms every `CONTEXT.md` section with you first; **idempotent & non-destructive** — re-running never deletes or overwrites your context. |
| **icontext-update** | `/icontext-update` | Update an existing iContext project that already has `CONTEXT.md` to the latest template shape. Adds missing sections/artifacts such as `AGENTS.md`, `CONTEXT.md §11.0`, selectable requirement discovery, `ROLE.md` requirement-review protocol, refreshed plan templates, docs/styles/launch scaffolding, and service `STRUCTURE.md` files. Confirmation-first and additive only — reports every proposed change, waits for approval, and preserves owner-authored content. |
| **icontext-audit** | `/icontext-audit` | Audit an existing iContext project for latest-template completeness, context/repo drift, plan-status sync, stale placeholders, and unnecessary Markdown cleanup candidates. It asks for an explicit decision on every missing, stale, unclear, or cleanup item before updating, archiving, or deleting anything, then re-audits and reports the final gap table. |
| **icontext-visualize** | `/icontext-visualize` | Export an existing iContext project as an interactive static dependency graph: `context-graph.html` + `context-graph.js`. It reads `CONTEXT.md`, agent files, `ROLE.md`, `PLAN.md`, plans, docs, styles, service `STRUCTURE.md` files, manifests, and Markdown references, then adds readable lane layout, label-density controls, click focus with dependency fade, zoom/pan controls, start-node focus, animated node dragging, plan-status badges, and click-to-view Markdown without editing source context. |
| **icontext-feature** | `/icontext-feature` | Add one feature plan — a **folder** `plans/NNN-name/` split into role files — with the standard §0–11 structure, role owners, task-status lifecycle, selectable requirement discovery (`/grill-with-docs` or `/wayfinder`), `ROLE.md` multi-agent requirement review, and gstack `/autoplan` plan preparation. Pre-checks required scaffolding (style guide · `docs/openapi.yaml` · `.vscode/launch.json`) and offers to create what's missing. |

## The 3-layer context model

```
Layer 1  CLAUDE.md · AGENTS.md · AGENT.md · GEMINI.md
                                                agent boilerplate (hard rules, vendor-neutral)
Layer 2  CONTEXT.md                          architecture §1–13 — single source of truth
Layer 3  plans/NNN-name/                     one folder per feature, each refs CONTEXT.md
         PLAN.md · plans/README.md           status dashboards (kept in sync, 3 places)
```

Each plan is a **folder split by role** — sections **0–11** distributed across files by their
primary owner (BU/PO/DEV/QA/OPS/STK):

```
plans/NNN-name/
├── README.md   index + canonical Task status + review chain + done gates
├── bu.md       0 Decisions · 1 Goal · Use Cases · User Stories · Acceptance Criteria · Definition of Done
├── po.md       2 Scope · 3 User Stories · 10 Tasks · 11 Open Questions
├── dev.md      5 Tech & Architecture · 6 Data Model · Migration scripts · 7 API Contract · API changes · Pages/routes
├── qa.md       9 Test Plan (>80%) · Test Scenarios · Test Cases · Test Status · Test Coverage
├── ops.md      8 Security & Privacy · Deploy/Migrations
└── stk.md      4 Requirement Discovery / Requirement Review / Persona Panel
```

Main feature workflow:
choose `/grill-with-docs` or `/wayfinder` for requirement discovery → `ROLE.md` multi-agent
requirement review → write the role-split plan → gstack `/autoplan` plan preparation → iterative
implementation → QA gates.

Context maintenance workflow:
run `/icontext-update` when the template itself changed or a known artifact is missing; run
`/icontext-audit` when you want a full health check against the latest template, real repo state,
plan status, and Markdown cleanup candidates; run `/icontext-visualize` when you want an HTML/JS
dependency graph of the current context.

Task status flows `to do → plan → ready to implement → implement → ready to test → done`
(reach `ready to implement` only after `/autoplan` or the review chain). Before implementing any
plan, run the review chain via `/autoplan`: `/plan-ceo-review` (scope) · `/plan-eng-review`
(architecture) · `/plan-design-review` (if UI) · `/plan-devex-review` (if developer-facing).

## Self-update check
Each skill ships a `VERSION` + `check-update.sh`. On **every run** (Step 0) the skill compares
its local version to the published one on GitHub and prints a one-line result — best-effort and
non-blocking (offline/unpublished just prints "skipped"). When an update exists it tells you to
`git pull && ./install.sh`.

## Install

### One-liner (recommended) — pick your tool

```bash
# Claude Code (global)
curl -fsSL https://raw.githubusercontent.com/jeurboy/iContext/main/install.sh | bash -s -- claude

# Cursor (run in your project folder)
curl -fsSL https://raw.githubusercontent.com/jeurboy/iContext/main/install.sh | bash -s -- cursor

# Copilot / Gemini / Codex / Windsurf / Cline / Aider … — change the trailing word per the table
curl -fsSL https://raw.githubusercontent.com/jeurboy/iContext/main/install.sh | bash -s -- <tool>
```

| tool | target | scope |
|------|--------|-------|
| `claude` *(default)* | `~/.claude/skills/` | global slash-command skills |
| `claude-project` | `./.claude/skills/` | this project |
| `cursor` | `./.cursor/rules/icontext.mdc` | project rule |
| `copilot` | `./.github/instructions/icontext.instructions.md` | project |
| `windsurf` | `./.windsurf/rules/icontext.md` | project |
| `cline` | `./.clinerules/icontext.md` | project |
| `gemini` | `./.gemini/GEMINI.md` | project |
| `codex` | `./AGENTS.md` *(append)* | project |
| `aider` | `./CONVENTIONS.md` *(append)* | project |

Skill files are cached at `~/.icontext/` (override with `ICONTEXT_HOME`); non-Claude tools get a
small pointer file that references them. For Claude Code, the full skill folders are installed so
`/icontext-init` works as a slash command.

### From a clone

```bash
git clone https://github.com/jeurboy/iContext.git
cd iContext
./install.sh                 # Claude Code, copy (default)
./install.sh --link          # symlink instead — repo stays the single source of truth
./install.sh cursor          # …or target any tool from the table above
```

Restart Claude Code, then run `/icontext-init` in a project directory.

## Works with any agent

The workflow is defined once, agent-neutrally, in each skill's `PROCEDURE.md`. Thin entry
points adapt it per agent:

| Agent | Entry point |
|-------|-------------|
| Claude Code | `SKILL.md` (slash command) · `adapters/claude.md` (mapping reference) |
| Gemini CLI | `adapters/gemini.md` |
| OpenAI Codex CLI | `adapters/codex.md` |
| Cursor | `adapters/cursor.md` |
| Any other | point it at `PROCEDURE.md` |

## Repo layout

Skills live at the repo root (no wrapper folder):

```
iContext/
├── README.md
├── install.sh
├── scripts/            validation helpers
├── icontext-init/      SKILL.md · PROCEDURE.md · VERSION · check-update.sh · templates/ · adapters/ · reference/
├── icontext-update/    SKILL.md · PROCEDURE.md · VERSION · check-update.sh · adapters/
├── icontext-audit/     SKILL.md · PROCEDURE.md · VERSION · check-update.sh · adapters/
├── icontext-visualize/ SKILL.md · PROCEDURE.md · VERSION · check-update.sh · scripts/ · adapters/
└── icontext-feature/   SKILL.md · PROCEDURE.md · VERSION · check-update.sh · templates/ · adapters/
```

## Conventions baked in
- Never `git commit` / `git push` unless explicitly told.
- **Install `gstack`** (https://github.com/garrytan/gstack) — provides `/autoplan` + the plan-review chain.
- **Before writing any plan, run requirement discovery**: choose `/grill-with-docs` for clear-ish
  requirements or `/wayfinder` for large/foggy requirements without a clear solution path, then
  review the requirement with the multi-agent role panel in `ROLE.md`.
- **Before implementing any plan, run the review chain** (`/autoplan`): ceo · eng · design (if UI) · devex (if dev-facing).
- **Confirm every `CONTEXT.md` section** with the owner before writing; **non-destructive** — never delete/overwrite existing context, only add what's missing.
- **Audit before cleanup** — `/icontext-audit` must ask about every missing, stale, unclear, or extra Markdown item before updating, archiving, or deleting it.
- **Visualize read-only** — `/icontext-visualize` exports static HTML/JS graphs without changing context or app source files.
- **On architecture-impacting change, update context · plan · doc · style · data model together** (no drift).
- Tests: unit (API) + Playwright (UI), coverage > 80% (gate before `done`).
- `styles/`: central design tokens only — no inline colors / look-and-feel.
- Each service is its own git repo, wired as a submodule under the root.
- Stack defaults (Next.js · Flutter · Go+GORM clean-arch · Postgres) are overridable per project.

## Validate

```bash
./scripts/validate.sh
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-init
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-update
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-audit
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-visualize
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-feature
```

## Changelog

### 1.10.2
- **Readable graph focus** — `icontext-visualize` now lays dense context graphs out in lanes,
  keeps labels readable while zooming, adds label-density controls, and fades unrelated nodes when
  a node is clicked so the selected dependency neighborhood is easier to inspect.

### 1.10.1
- **Interactive graph controls** — `icontext-visualize` exports graphs with zoom in/out, mouse wheel
  zoom, canvas panning, a highlighted `START` node with focus control, animated node dragging,
  plan-status badges, and a `View MD` panel for selected Markdown nodes.

### 1.10.0
- **New `icontext-visualize` skill** — exports an existing iContext project to a static
  dependency graph (`context-graph.html` + `context-graph.js`) using a bundled dependency-free
  Node script. It links `CONTEXT.md` to agent files, role/status files, plans, services, manifests,
  docs, API contracts, styles, and referenced Markdown without editing source context.
- Installer, pointers, README, and validation now include all five skills:
  `icontext-init`, `icontext-update`, `icontext-audit`, `icontext-visualize`, and
  `icontext-feature`.

### 1.9.0
- **New `icontext-audit` skill** — audits an existing iContext project against latest templates,
  current repo evidence, plan-status sync, stale placeholders, and Markdown cleanup candidates.
  It asks for an explicit owner decision on every missing, stale, unclear, or cleanup item before
  applying updates, archiving, or deleting anything.
- Installer, pointers, README, and validation now include all four skills:
  `icontext-init`, `icontext-update`, `icontext-audit`, and `icontext-feature`.

### 1.8.0
- **Wayfinder discovery route** — feature planning now asks the user to choose `/grill-with-docs`
  for clear-ish requirements or `/wayfinder` for large/foggy requirements without a clear solution
  path. If Wayfinder creates unresolved planning-critical tickets, `icontext-feature` stops at the
  map and resumes plan creation once the way is clear.
- **Plan §4 expanded** — `stk.md` now records Requirement Discovery separately from Requirement
  Review / Persona Panel, including Wayfinder map/ticket links when used.

### 1.7.0
- **New `icontext-update` skill** — for projects that already have `CONTEXT.md`; backfills missing
  sections/artifacts from the latest templates without overwriting existing context. It reports and
  confirms every proposed change before writing.
- Installer, pointers, README, and validation now include all three skills:
  `icontext-init`, `icontext-update`, and `icontext-feature`.

### 1.6.0
- **Codex L1 template** — scaffold now includes `AGENTS.md` and update/sync detects it.
- **Main development workflow in CONTEXT.md** — `/grill-with-docs` for requirements, `ROLE.md`
  multi-agent requirement review, gstack `/autoplan` for plan preparation, then implementation and
  QA gates.
- **ROLE.md upgraded** — now defines a repeatable multi-agent requirement review protocol.
- **Codex validation cleanup** — removed unsupported `version` frontmatter from skill files; version
  stays in each `VERSION` file.
- **Companion skill naming** — corrected `ui-ux-pro-max` and added `grill-with-docs`.

### 1.4.0
- **Implementation loop (loop engineering)** — `CONTEXT.md` §11.5 + plan `qa.md` now spell out the
  `implement` phase as a tight iterate-and-retest loop: slice → implement → test (with the exact
  run commands + coverage method) → re-run the whole suite (regression) → review with the owner
  and ask for feedback → repeat, until User Stories pass and coverage > 80%.
- **Optimized `icontext-init` description** — restructured for sharper triggering (two clear
  situations + explicit "do NOT use" cases), from a skill-creator description pass.

### 1.3.0
- **Confirm the repo strategy before wiring submodules** — `icontext-init` asks the owner to pick
  git submodules (default), a monorepo, or separate un-wired repos, and records the choice.
- **Custom service directories** — services no longer assumed to be `api/ web/ app/`; the owner
  names the real dirs (e.g. `backend/ frontend/ admin/ worker/`), and brownfield detects them.
- **Review polish** — broadened skill descriptions for better triggering, and reframed caps-heavy
  directives as reasoning (per the skill-creator review).

### 1.2.0
- **Update/sync mode** — re-running `icontext-init` on an existing backbone fills only the missing
  pieces; **non-destructive** (never deletes/overwrites existing context).
- **Section-by-section confirmation** — every `CONTEXT.md` section is confirmed with the owner;
  first-time init is a deep per-section interview, and mandatory fields (e.g. project description)
  are always asked.
- **Version + update check runs first on every skill invocation.**
- **gstack + review chain** baked into context — run `/autoplan` (ceo · eng · design · devex)
  before implementing any plan.
- **Sync-on-architecture-change rule** — keep context · plan · doc · style · data model in step.
- **Richer plan templates** — bu (use cases · user stories · acceptance criteria · definition of
  done), qa (test scenarios · cases · status · coverage), dev (migration scripts · API changes ·
  pages/routes); expanded `CONTEXT.md` §7 Data Model.
- **6-state task status** — `to do → plan → ready to implement → implement → ready to test → done`.
- **icontext-feature scaffolding pre-check** — style guide · `docs/openapi.yaml` · `.vscode/launch.json`.
- Added `adapters/claude.md` for both skills.
- **Multi-tool one-liner installer** — `curl … | bash -s -- <tool>` for Claude Code, Cursor,
  Copilot, Gemini, Codex, Windsurf, Cline, Aider; self-clones and caches at `~/.icontext/`.

### 1.1.0
- Role-split plan folders + self-update check.

### 1.0.0
- Initial context-init toolkit for web/mobile projects.
