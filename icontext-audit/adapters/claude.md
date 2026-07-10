# icontext-audit - Claude Code adapter

Claude Code is the native entry point: invoke `/icontext-audit` in a project that already has
`CONTEXT.md`.

1. Run `bash check-update.sh` and surface the one-line result.
2. Read `PROCEDURE.md`.
3. Use `Bash`/`Read` to inventory the project against `../icontext-init/templates/`.
4. Compare the written context against the actual repo structure, manifests, docs, tests, plans,
   and service files.
5. Present every missing, stale, unclear, or cleanup-candidate item with a stable ID.
6. Use `AskUserQuestion` to get an explicit decision for every item before writing, moving,
   archiving, or deleting.
7. Use `Write`/`Edit` only for approved updates.
8. Re-audit, report the final gap table, and stop. Do not create feature plans, implement code,
   commit, or push.
