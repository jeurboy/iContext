# icontext-feature-review (portable skill)

Summarize one feature plan (`plans/NNN-name/` + its `CR-*.md`) into a single plain-language review
summary with two lenses — **requirement** (goal · decisions · scope · stories → AC → tests · open
questions) and **technical** (architecture · DB/migration · API contract · UI routes · security · deploy) —
plus automatic cross-checks against `docs/openapi.yaml`, `context/DEV.md` §7 and the plan status indexes.

Read-only on plans/code; answers in chat by default and writes `plans/NNN-name/REVIEW.md` only on request. Pairs with `icontext-feature`
(creates the plan) and `icontext-audit` (whole-project drift).

## One procedure, many agents
Workflow defined once in **[PROCEDURE.md](./PROCEDURE.md)**; output shape in
**[templates/review-template.md](./templates/review-template.md)**.

| Agent | Entry point |
|-------|-------------|
| Claude Code | [SKILL.md](./SKILL.md) - `/icontext-feature-review` |
| Gemini CLI | [adapters/gemini.md](./adapters/gemini.md) |
| OpenAI Codex CLI | [adapters/codex.md](./adapters/codex.md) |
| Cursor | [adapters/cursor.md](./adapters/cursor.md) |
| Any other | point it at `PROCEDURE.md` |
