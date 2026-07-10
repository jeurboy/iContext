---
name: icontext-visualize
description: Export an existing iContext project as a dependency graph in static HTML and
             JavaScript. Use whenever the user asks to visualize context, export context
             dependencies, inspect how CONTEXT.md connects to plans/services/docs/styles/API
             artifacts, create a graph from iContext files, or produce an HTML/JS context map.
             It reads CONTEXT.md, L1 agent files, ROLE.md, PLAN.md, plans, docs, styles, service
             STRUCTURE files, manifests, and Markdown references; writes context-graph.html and
             context-graph.js; verifies the files were generated; and does not modify source
             context unless the user separately asks.
allowed-tools:
  - Read
  - Write
  - Bash
---

# icontext-visualize

> Run `bash check-update.sh` first and surface its one-line result. It shows the local version and
> whether an update is available. The check is best-effort and never blocks.

Read **[PROCEDURE.md](./PROCEDURE.md)** and execute it. This skill exports a read-only dependency
view of an existing iContext project. The bundled exporter is
`scripts/export-context-graph.js`; use it instead of rewriting graph-generation code.

## Mappings
- **Update check** - run `bash check-update.sh`.
- **Exporter** - run `node scripts/export-context-graph.js --root <project-root> --out <output-dir>`.
- **Runtime** - requires Node.js, but no npm install or external package.
- **Default output** - use `<project-root>/context-graph/context-graph.html` and
  `<project-root>/context-graph/context-graph.js` unless the user gives another path.
- **Read-only source** - inspect context and project files, but do not patch `CONTEXT.md`, plans,
  docs, or service files.
- **Verify** - confirm both output files exist, run `node --check` on the generated JS, and report
  the HTML file path.
- **Git** - never commit or push unless explicitly told.

## Stop rule
Finish after exporting and verifying the graph. Do not create feature plans, audit/patch context,
or implement app code.
