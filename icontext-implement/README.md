# icontext-implement (portable skill)

Execute one feature plan (`plans/NNN-name/` + its pending `CR-*.md`) through the §11.5
implementation loop — from `ready to implement` to `ready to test`. The orchestrator summarizes
the plan first via `icontext-feature-review`, slices the §10 tasks, then runs each slice with
**confirmed implementer sub-agents on a cheap/low-effort model** (the user approves every spawn:
count · scope · model). After coding: `/unslop` on written artifacts, sync
`docs/openapi.yaml` + `styles/` + `DEV.md` §7, and a pre-commit chain — `/impeccable` re-check
(if design work) → `/deslop` → optional `/thermo-nuclear-code-quality-review` → the §11.7 commit
confirmation.

Commits/pushes only on explicit per-invocation confirmation. Pairs with `icontext-feature`
(creates the plan) and `icontext-feature-review` (the pre-code summary).

## One procedure, many agents
Workflow defined once in **[PROCEDURE.md](./PROCEDURE.md)**.

| Agent | Entry point |
|-------|-------------|
| Claude Code | [SKILL.md](./SKILL.md) - `/icontext-implement` |
| Gemini CLI | [adapters/gemini.md](./adapters/gemini.md) |
| OpenAI Codex CLI | [adapters/codex.md](./adapters/codex.md) |
| Cursor | [adapters/cursor.md](./adapters/cursor.md) |
| Any other | point it at `PROCEDURE.md` |
