# iContext

Two portable agent-skills that bootstrap and maintain a **layered project context** for
web/mobile builds — so any AI agent (Claude, Gemini, Codex, Cursor, …) starts every session
already knowing your architecture, conventions, and plan status.

| Skill | Command | Does |
|-------|---------|------|
| **icontext-init** | `/icontext-init` | Scaffold the context backbone (L1 agent files · L2 `CONTEXT.md` · L3 `plans/`) + service skeletons. **Greenfield** (new) or **brownfield** (read & summarize an existing codebase). |
| **icontext-feature** | `/icontext-feature` | Add one feature plan (`plans/NNN-name.md`) with the standard §0–11 structure, role owners, status lifecycle, and optional persona-panel review. |

## The 3-layer context model

```
Layer 1  CLAUDE.md · AGENT.md · GEMINI.md   agent boilerplate (hard rules, vendor-neutral)
Layer 2  CONTEXT.md                          architecture §1–13 — single source of truth
Layer 3  plans/NNN-name.md                   one plan per feature, each refs CONTEXT.md
         PLAN.md · plans/README.md           status dashboards (kept in sync, 3 places)
```

Each generated plan uses sections **0–11** (Decisions · Goal · Scope · User Stories ·
Persona Panel · Tech & Architecture · Data Model · API Contract · Security & Privacy ·
Test Plan · Tasks · Open Questions), each with a primary responsibility role
(BU/PO/DEV/QA/OPS/STK). Status flows `todo → implement → ready to test → done`.

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
├── icontext-init/      SKILL.md · PROCEDURE.md · templates/ · adapters/ · reference/
└── icontext-feature/   SKILL.md · PROCEDURE.md · templates/ · adapters/
```

## Conventions baked in
- Never `git commit` / `git push` unless explicitly told.
- Tests: unit (API) + Playwright (UI), coverage > 80% (gate before `done`).
- `styles/`: central design tokens only — no inline colors / look-and-feel.
- Each service is its own git repo, wired as a submodule under the root.
- Stack defaults (Next.js · Flutter · Go+GORM clean-arch · Postgres) are overridable per project.
