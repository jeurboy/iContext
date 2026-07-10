# icontext-visualize - procedure (agent-neutral)

> Source of truth for exporting iContext dependencies as an interactive static graph. The output is
> a pair of files, `context-graph.html` and `context-graph.js`, that can be opened directly in a
> browser.

## Operating rules
- **Requires an existing project context.** If the target root has no `CONTEXT.md`, stop and tell
  the user to run `icontext-init` first.
- **Read-only by default.** This workflow exports a visualization. Do not edit `CONTEXT.md`, plan
  files, docs, service files, or source code unless the user separately asks.
- **Use the bundled exporter.** Run `scripts/export-context-graph.js`; do not hand-roll a new
  visualization during normal use.
- **No external runtime dependency.** The generated graph must be static HTML + JavaScript and
  must not require a dev server, CDN, package install, or network access.
- **Node runtime required.** If `node` is unavailable, stop and tell the user this exporter needs
  Node.js but no npm packages.
- **Never commit / push** unless explicitly told.

## Step 0 - Update check
Run `check-update.sh` next to this file and surface its one-line result. Continue even if offline.

## Step 1 - Confirm target and output
At the target root, confirm `CONTEXT.md` exists. Choose the output directory:
- If the user provides a path, use it.
- Otherwise use `<project-root>/context-graph/`.

The expected outputs are:
- `<output-dir>/context-graph.html`
- `<output-dir>/context-graph.js`

The graph should open in a readable layout for dense projects. It should support zoom in/out, wheel
zoom, panning by dragging empty space, label-density controls, click-to-focus behavior that fades
nodes outside the selected dependency neighborhood, animated node dragging, a visible start node
with a control that focuses it, plan-status badges when plan files declare status, and a `View MD`
action on selected Markdown-backed nodes.

## Step 2 - Run the exporter
Run:

```bash
node <skill-dir>/scripts/export-context-graph.js --root <project-root> --out <output-dir>
```

The exporter should read:
- `CONTEXT.md`
- L1 files: `CLAUDE.md`, `AGENTS.md`, `AGENT.md`, `GEMINI.md`
- L2/status files: `ROLE.md`, `PLAN.md`, `plans/README.md`
- Feature plans under `plans/NNN-name/`
- `docs/openapi.yaml` or `docs/openapi.yml`
- `styles/css/tokens.css` and `styles/components/`
- Service `STRUCTURE.md` files and common manifests
- Project Markdown references that are useful context dependencies

## Step 3 - Verify output
After export:
- Confirm both files exist and are non-empty.
- Run `node --check <output-dir>/context-graph.js`.
- If possible, report the graph counts from the exporter output: nodes and edges.

If verification fails, fix the exporter or rerun with a safer output path before reporting success.

## Step 4 - Report
Return:
- The HTML file path.
- The JS file path.
- Node and edge counts.
- Any notable omissions, such as missing `PLAN.md`, missing plan folders, or no service manifests.

Stop here. Do not audit, patch, or implement application code.
