# icontext-visualize - Cursor adapter

In chat, ask Cursor to read `PROCEDURE.md` and export the existing iContext project to a static
dependency graph. It should run `scripts/export-context-graph.js`, create `context-graph.html` and
`context-graph.js`, verify both outputs, report the paths plus node/edge counts, and stop without
editing source context or committing.
