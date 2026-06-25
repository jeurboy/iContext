# iContext

**Version 1.3.0** · two portable agent-skills that bootstrap and maintain a **layered project
context** for web/mobile builds — so any AI agent (Claude, Gemini, Codex, Cursor, …) starts every
session already knowing your architecture, conventions, and plan status.

| Skill | Command | Does |
|-------|---------|------|
| **icontext-init** | `/icontext-init` | Scaffold the context backbone (L1 agent files · L2 `CONTEXT.md` · L3 `plans/`) + service skeletons. **Greenfield** (new), **brownfield** (read & summarize an existing codebase), or **update/sync** (fill only the missing pieces of an existing backbone). Confirms every `CONTEXT.md` section with you first; **idempotent & non-destructive** — re-running never deletes or overwrites your context. |
| **icontext-feature** | `/icontext-feature` | Add one feature plan — a **folder** `plans/NNN-name/` split into role files — with the standard §0–11 structure, role owners, task-status lifecycle, and optional persona-panel review. Pre-checks required scaffolding (style guide · `docs/openapi.yaml` · `.vscode/launch.json`) and offers to create what's missing. |

## The 3-layer context model

```
Layer 1  CLAUDE.md · AGENT.md · GEMINI.md   agent boilerplate (hard rules, vendor-neutral)
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
└── stk.md      4 Persona Panel
```

Task status flows `to do → plan → ready to implement → implement → ready to test → done`
(reach `ready to implement` only after the review chain). Before implementing any plan, run the
review chain via `/autoplan`: `/plan-ceo-review` (scope) · `/plan-eng-review` (architecture) ·
`/plan-design-review` (if UI) · `/plan-devex-review` (if developer-facing).

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
├── icontext-init/      SKILL.md · PROCEDURE.md · VERSION · check-update.sh · templates/ · adapters/ · reference/
└── icontext-feature/   SKILL.md · PROCEDURE.md · VERSION · check-update.sh · templates/ · adapters/
```

## Conventions baked in
- Never `git commit` / `git push` unless explicitly told.
- **Install `gstack`** (https://github.com/garrytan/gstack) — provides `/autoplan` + the plan-review chain.
- **Before implementing any plan, run the review chain** (`/autoplan`): ceo · eng · design (if UI) · devex (if dev-facing).
- **Confirm every `CONTEXT.md` section** with the owner before writing; **non-destructive** — never delete/overwrite existing context, only add what's missing.
- **On architecture-impacting change, update context · plan · doc · style · data model together** (no drift).
- Tests: unit (API) + Playwright (UI), coverage > 80% (gate before `done`).
- `styles/`: central design tokens only — no inline colors / look-and-feel.
- Each service is its own git repo, wired as a submodule under the root.
- Stack defaults (Next.js · Flutter · Go+GORM clean-arch · Postgres) are overridable per project.

## Changelog

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
