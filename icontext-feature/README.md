# icontext-feature (portable skill)

Generate one feature plan (`plans/NNN-<slug>/ (folder, role files)`) using the standard §0–11
structure with role owners, a status lifecycle, selectable requirement discovery (`/grill-with-docs`
or `/wayfinder`), `ROLE.md` multi-agent requirement review, and gstack `/autoplan` plan preparation. Pairs with
`icontext-init`. Stops at the plan — never implements.

## Prerequisite — discovery skills
The plan flow **runs requirement discovery before writing it** and then reviews the requirement
through `ROLE.md` (see PROCEDURE.md Steps 3.5–4). For Claude Code, install Matt Pocock's discovery
skills once:

```
npx skills@latest add mattpocock/skills
```

Select `wayfinder` + `grill-me` + `grill-with-docs` (which pull in `grilling` + `domain-modeling`),
target Claude Code, then run `/setup-matt-pocock-skills`. Sources:
<https://www.aihero.dev/skills-wayfinder> and <https://github.com/mattpocock/skills>.
If they aren't installed, the flow falls back to `/grill-me` / `/grilling`, or a manual discovery
pass. After that, run the `ROLE.md` multi-agent panel before `/autoplan`.

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
