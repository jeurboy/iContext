# icontext-visualize (portable skill)

Export an existing iContext project as an interactive static dependency graph. The output is a pair
of files, `context-graph.html` and `context-graph.js`, that can be opened directly in a browser
without a server or package install.

The exporter reads `CONTEXT.md`, agent files, role/status files, plans, docs, style artifacts,
service `STRUCTURE.md` files, manifests, and useful Markdown references. It then builds a graph of
how the project context depends on plans, services, API docs, styles, and supporting files, with a
readable lane layout, label-density controls, click focus with dependency fade, zoom controls,
panning, start-node focus, animated node dragging, plan-status badges, and a `View MD` panel for
Markdown-backed nodes.

## One procedure, many agents
Workflow defined once in **[PROCEDURE.md](./PROCEDURE.md)**. Thin entry points per agent:

| Agent | Entry point |
|-------|-------------|
| Claude Code | [SKILL.md](./SKILL.md) - `/icontext-visualize` |
| Gemini CLI | [adapters/gemini.md](./adapters/gemini.md) |
| OpenAI Codex CLI | [adapters/codex.md](./adapters/codex.md) |
| Cursor | [adapters/cursor.md](./adapters/cursor.md) |
| Any other | point it at `PROCEDURE.md` |
