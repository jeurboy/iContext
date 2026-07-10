# icontext-audit - OpenAI Codex CLI adapter

Codex should follow `PROCEDURE.md` to audit an existing iContext project. Confirm `CONTEXT.md`
exists, compare the project with the latest templates in `icontext-init/templates/`, then compare
the written context against current repo evidence such as service dirs, manifests, routes,
migrations, tests, docs, and plan statuses. Produce an audit register with stable IDs for every
missing, stale, unclear, or cleanup-candidate item. Ask the user for an explicit decision on each
item before applying any file creation, patch, move, archive, or deletion. Preserve owner-authored
content, leave TODOs only when the user defers, re-audit after approved updates, report the final
table, and stop. Do not commit.
