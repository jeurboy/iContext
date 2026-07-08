# icontext-update (portable skill)

Update an existing iContext project to the latest template shape. Use it when the project already
has `CONTEXT.md` or an iContext backbone, but is missing newer sections such as the main
development workflow, Codex `AGENTS.md`, `ROLE.md` multi-agent requirement review, refreshed plan
templates, style/docs scaffolding, or service `STRUCTURE.md` files.

The workflow is additive and confirmation-first: it inventories gaps, shows each proposed file
creation or patch, waits for user confirmation, then creates missing files, inserts missing
sections, leaves TODOs for unknown facts, and never overwrites owner-authored content.

## One procedure, many agents
Workflow defined once in **[PROCEDURE.md](./PROCEDURE.md)**. Thin entry points per agent:

| Agent | Entry point |
|-------|-------------|
| Claude Code | [SKILL.md](./SKILL.md) — `/icontext-update` |
| Gemini CLI | [adapters/gemini.md](./adapters/gemini.md) |
| OpenAI Codex CLI | [adapters/codex.md](./adapters/codex.md) |
| Cursor | [adapters/cursor.md](./adapters/cursor.md) |
| Any other | point it at `PROCEDURE.md` |
