# icontext-visualize - OpenAI Codex CLI adapter

Codex should follow `PROCEDURE.md` to export an existing iContext project as a static dependency
graph. Confirm `CONTEXT.md` exists, run the bundled
`scripts/export-context-graph.js` with `--root` and `--out`, then verify that
`context-graph.html` and `context-graph.js` were created and that the generated JS passes
`node --check`. Report the paths plus node/edge counts. This is a read-only source workflow: do not
patch context files, create feature plans, implement app code, commit, or push.
