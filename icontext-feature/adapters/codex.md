# icontext-feature — OpenAI Codex CLI adapter

> Follow `PROCEDURE.md` to create one feature plan: next `plans/NNN`, gather a minimal brief, ask
> the user to choose `/grill-with-docs` or `/wayfinder`, run the selected discovery route, review
> the requirement through `context/ROLE.md` as a multi-agent panel, write `plans/NNN-<slug>/ (folder, role files)` from
> `templates/plan-template/` (task status `plan`, ref CONTEXT.md), register in `plans/README.md` +
> `PLAN.md`, then run gstack `/autoplan` to prepare the plan before implementation. If the feature
> already has a plan, write `CR-<M>.md` inside that plan's folder from `templates/cr-template.md`
> instead — a single delta file linking back to the original plan (PROCEDURE.md Step 2). Stop at
> the plan/CR. Don't commit.

Codex conventionally auto-reads uppercase `AGENTS.md`; iContext also recognizes lowercase
`agents.md`/`agent.md` for other tools, whose auto-discovery behavior remains vendor-specific.
Tool mapping: questions → inline · file ops → shell/file.
