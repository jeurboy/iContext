# icontext-feature (portable skill)

Generate one feature plan (`plans/NNN-<slug>/ (folder, role files)`) using the standard §0–11 structure with
role owners, a status lifecycle, and an optional persona-panel review. Pairs with
`icontext-init`. Stops at the plan — never implements.

## One procedure, many agents
Workflow defined once in **[PROCEDURE.md](./PROCEDURE.md)**. Thin entry points per agent:

| Agent | Entry point |
|-------|-------------|
| Claude Code | [SKILL.md](./SKILL.md) — `/icontext-feature` |
| Gemini CLI | [adapters/gemini.md](./adapters/gemini.md) |
| OpenAI Codex CLI | [adapters/codex.md](./adapters/codex.md) |
| Cursor | [adapters/cursor.md](./adapters/cursor.md) |
| Any other | point it at `PROCEDURE.md` |

Plan structure is owned by the project's `CONTEXT.md §11.1`; the template lives at
`templates/plan-template/` (and as `plans/_TEMPLATE/` in an initialized project).
