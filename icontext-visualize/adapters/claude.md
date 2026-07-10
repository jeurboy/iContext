# icontext-visualize - Claude Code adapter

Claude Code is the native entry point: invoke `/icontext-visualize` in a project that already has
`CONTEXT.md`.

1. Run `bash check-update.sh` and surface the one-line result.
2. Read `PROCEDURE.md`.
3. Confirm the target root contains `CONTEXT.md`.
4. Run `node scripts/export-context-graph.js --root <project-root> --out <output-dir>`.
5. Verify `context-graph.html` and `context-graph.js` exist and run `node --check` on the JS.
6. Report the output paths plus node/edge counts. Do not patch context, implement code, commit, or
   push.
