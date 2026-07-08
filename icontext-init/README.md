# icontext-init (portable skill)

Scaffold a layered context backbone (L1 agent files including Codex `AGENTS.md` / L2
`CONTEXT.md` / L3 `plans/`) plus service skeletons for a web/mobile project. Works
**greenfield** (new project), **brownfield** (read & summarize an existing codebase), or
**update/sync** (fill missing context artifacts only). Pairs with the `icontext-feature` skill.

## One procedure, many agents
The workflow is defined once, agent-neutrally, in **[PROCEDURE.md](./PROCEDURE.md)**. Each agent
has a thin entry point:

| Agent | Entry point |
|-------|-------------|
| Claude Code | [SKILL.md](./SKILL.md) — invoke `/icontext-init` |
| Gemini CLI | [adapters/gemini.md](./adapters/gemini.md) |
| OpenAI Codex CLI | [adapters/codex.md](./adapters/codex.md) |
| Cursor | [adapters/cursor.md](./adapters/cursor.md) |
| Any other agent | point it at `PROCEDURE.md` |

All entry points do the same thing: read `PROCEDURE.md`, execute the steps, copy from
`templates/`. The only differences are how each agent asks questions and runs shell/file ops.

## Layout
```
icontext-init/
├── SKILL.md            Claude Code entry
├── PROCEDURE.md        agent-neutral source of truth
├── README.md           this file
├── adapters/           per-agent entry points (gemini, codex, cursor)
├── templates/          files copied into the new project (with {{VARS}}), incl. AGENTS.md
│   └── stacks/         structure guides per technology choice
└── reference/          companion-skill links
```
