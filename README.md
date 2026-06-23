# iContext

Two portable agent-skills that bootstrap and maintain a **layered project context** for
web/mobile builds — so any AI agent (Claude, Gemini, Codex, Cursor, …) starts every session
already knowing your architecture, conventions, and plan status.

| Skill | Command | Does |
|-------|---------|------|
| **icontext-init** | `/icontext-init` | Scaffold the context backbone (L1 agent files · L2 `CONTEXT.md` · L3 `plans/`) + service skeletons. **Greenfield** (new) or **brownfield** (read & summarize an existing codebase). |
| **icontext-feature** | `/icontext-feature` | Add one feature plan — a **folder** `plans/NNN-name/` split into role files — with the standard §0–11 structure, role owners, status lifecycle, and optional persona-panel review. |

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
├── README.md   index + canonical Status
├── bu.md       0 Decisions · 1 Goal
├── po.md       2 Scope · 3 User Stories · 10 Tasks · 11 Open Questions
├── dev.md      5 Tech & Architecture · 6 Data Model · 7 API Contract
├── qa.md       9 Test Plan (>80%)
├── ops.md      8 Security & Privacy · Deploy/Migrations
└── stk.md      4 Persona Panel
```

Status flows `todo → implement → ready to test → done`.

## Self-update check
Each skill ships a `VERSION` + `check-update.sh`. On **every run** (Step 0) the skill compares
its local version to the published one on GitHub and prints a one-line result — best-effort and
non-blocking (offline/unpublished just prints "skipped"). When an update exists it tells you to
`git pull && ./install.sh`.

## Install

```bash
git clone <this-repo> iContext
cd iContext
./install.sh          # copies skills into ~/.claude/skills/
# or: ./install.sh --link   (symlink instead of copy — repo stays the single source of truth)
```

Restart Claude Code, then run `/icontext-init` in a project directory.

## Works with any agent

The workflow is defined once, agent-neutrally, in each skill's `PROCEDURE.md`. Thin entry
points adapt it per agent:

| Agent | Entry point |
|-------|-------------|
| Claude Code | `SKILL.md` (slash command) |
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
- Tests: unit (API) + Playwright (UI), coverage > 80% (gate before `done`).
- `styles/`: central design tokens only — no inline colors / look-and-feel.
- Each service is its own git repo, wired as a submodule under the root.
- Stack defaults (Next.js · Flutter · Go+GORM clean-arch · Postgres) are overridable per project.
