# icontext-update — Claude Code adapter

Claude Code is the native entry point: invoke `/icontext-update` in a project that already has
`CONTEXT.md`.

1. Run `bash check-update.sh` and surface the one-line result.
2. Read `PROCEDURE.md`.
3. Use `Bash`/`Read` to inventory the project against `../icontext-init/templates/`.
4. Present every proposed file creation/patch and confirm with `AskUserQuestion` before writing.
5. Use `Write`/`Edit` to create missing files or insert missing sections only after confirmation.
6. Use `AskUserQuestion` for mandatory unknowns; otherwise leave TODOs.
7. Stop after the final gap table. Do not create feature plans or implement code.
