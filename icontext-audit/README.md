# icontext-audit (portable skill)

Audit an existing iContext project for completeness, drift, and Markdown cleanup. Use it when the
project already has `CONTEXT.md`, but you want to verify that the current context still matches the
latest template and the real repository.

The workflow is audit-first and confirmation-first: it inventories the iContext backbone, compares
it with the latest templates, checks for drift against repo evidence, lists unnecessary or stale
Markdown candidates, asks for an explicit decision on every item, applies only approved updates,
then re-runs the audit and reports the final table.

## One procedure, many agents
Workflow defined once in **[PROCEDURE.md](./PROCEDURE.md)**. Thin entry points per agent:

| Agent | Entry point |
|-------|-------------|
| Claude Code | [SKILL.md](./SKILL.md) - `/icontext-audit` |
| Gemini CLI | [adapters/gemini.md](./adapters/gemini.md) |
| OpenAI Codex CLI | [adapters/codex.md](./adapters/codex.md) |
| Cursor | [adapters/cursor.md](./adapters/cursor.md) |
| Any other | point it at `PROCEDURE.md` |
