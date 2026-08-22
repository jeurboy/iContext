# icontext-update — OpenAI Codex CLI adapter

Codex should follow `PROCEDURE.md` to update an existing iContext project. Confirm `CONTEXT.md`
exists, inventory against the latest templates in `icontext-init/templates/`, create missing
artifacts such as `AGENTS.md`, and patch only missing sections such as `CONTEXT.md §11.0`,
the selectable `/grill-with-docs` or `/wayfinder` discovery route, `ROLE.md` Requirement Review
Protocol, and plan-template §4. If §10 still lives in `CONTEXT.md`, propose moving it verbatim into
`SKILLS.md` and leaving a pointer stub; do not create a duplicate registry. Before every file
creation or patch, show the file, reason, and exact action, then wait for user confirmation. Preserve existing content,
leave TODOs for unknown facts, and include `.icontext/hooks/` plus documented interactive host
wiring when approved. Verify without executing commit/push/DB actions, report the final gap table,
and stop.
