# icontext-audit - procedure (agent-neutral)

> Source of truth for auditing an existing iContext project for completeness, drift, and Markdown
> cleanup. This is stricter than `icontext-update`: it checks latest-template shape, current repo
> reality, and extra/stale Markdown, then asks the owner for every decision before changing files.

## Operating rules
- **Requires an existing project context.** If the target root has no `CONTEXT.md`, stop and tell
  the user to run `icontext-init` first.
- **Audit before editing.** Inventory, compare, and build the gap table before writing anything.
- **Ask about every issue.** Every missing, empty, placeholder, stale, conflicting, unclear, or
  cleanup-candidate item must be shown to the user and receive an explicit decision before action.
  For long audits, ask in chunks, but keep each row individually addressable.
- **Never silently defer mandatory context.** If required project facts are missing, ask the user
  for the value. Write a TODO only when the user explicitly chooses to defer that item.
- **Do not invent facts.** Repo-derived values must cite evidence such as file paths, manifests,
  ports, routes, migrations, or tests. When evidence is weak, ask the owner.
- **Preserve owner-authored content.** Patch only the approved missing or stale parts. Do not
  normalize prose just to match the template.
- **Cleanup is opt-in.** Markdown outside the template is not automatically "extra." Mark it as a
  cleanup candidate only with evidence, then ask whether to keep, merge, archive, or delete it.
  Delete only when the user explicitly approves deletion for that specific file or section.
- **Never commit / push** unless explicitly told.

## Step 0 - Update check
Run `check-update.sh` next to this file and surface its one-line result. Continue even if offline.

## Step 1 - Confirm audit target
At the target root, confirm `CONTEXT.md` exists. Then identify the iContext source templates from
the sibling path `../icontext-init/templates/`.

Inventory the expected backbone:
- L1 files: `CLAUDE.md`, `AGENTS.md`, `AGENT.md`, `GEMINI.md`
- L2 files: `CONTEXT.md`, `ROLE.md`
- L3/status files: `PLAN.md`, `plans/README.md`, `plans/_TEMPLATE/`
- Shared scaffolding: `docs/openapi.yaml`, `styles/css/tokens.css`, `styles/components/`,
  `.vscode/launch.json`, `docker-compose.yml`
- Service guides: each service's `STRUCTURE.md`, using service names from `CONTEXT.md` section 6
- Feature plans: each `plans/NNN-name/` folder and its role files

## Step 2 - Compare against the latest template
Build a template-completeness table. Do not edit yet.

Check:
- `CONTEXT.md` contains the latest section set: sections 1-13, section 11.0 main workflow,
  section 11.1 plan structure, section 11.2 plan rules, section 11.3 sync rule, section 11.4
  review chain, and section 11.5 implementation loop.
- `ROLE.md` includes the Requirement Review Protocol.
- Plan templates include `README.md`, `bu.md`, `po.md`, `dev.md`, `qa.md`, `ops.md`, and `stk.md`,
  including the latest Requirement Discovery / Requirement Review / Persona Panel shape.
- L1 files point agents to `CONTEXT.md`, preserve the project rules, and include current workflow
  guidance.
- Shared scaffolding exists or is intentionally absent with a documented reason.

Mark each item as `present`, `missing`, `partial`, `placeholder`, `stale`, or `unknown`.

## Step 3 - Compare context against repository reality
Read the repo enough to detect whether `CONTEXT.md` is still true. Use evidence, not guesses.

Useful checks:
- Service names and directories in section 6 vs actual top-level services and manifests
  (`package.json`, `go.mod`, `pyproject.toml`, `requirements.txt`, `pubspec.yaml`, `Cargo.toml`,
  `pom.xml`, `*.csproj`, and similar).
- Ports and run commands in context vs `docker-compose.yml`, `.vscode/launch.json`, package
  scripts, env examples, or documented commands.
- Stack and architecture claims vs manifests, framework files, entry points, routing, data layer,
  and migrations.
- Data model section vs schema files, migrations, ORM models, or database docs.
- API contract docs vs routes/controllers/handlers.
- Test strategy and coverage claims vs test folders, config, CI, and actual commands.
- Plan status sync across a plan folder `README.md`, `plans/README.md`, and `PLAN.md`.

Add stale or conflicting items to the audit table with file evidence and a proposed question for
the owner.

## Step 4 - Find Markdown cleanup candidates
List Markdown files with:

```bash
rg --files -g '*.md'
```

Categorize them before proposing cleanup:
- **Expected iContext files** - L1/L2/L3 files and role-split plans.
- **Project docs** - useful docs that should remain, possibly linked from context.
- **Superseded duplicates** - old plans, duplicate READMEs, or docs repeating newer context.
- **Generated/temp notes** - scratch files, old AI handoffs, obsolete one-off reports.
- **Unknown** - do not touch without asking.

A file is a cleanup candidate only when you can explain why it may be obsolete, duplicated,
unreferenced, or superseded. Include the safest proposed action: keep, link from context, merge,
archive, or delete. Prefer `archive` or `merge` over deletion unless the user explicitly asks for
deletion.

## Step 5 - Build the audit register
Before asking or editing, present an audit register like this:

| ID | Type | File / section | Evidence | Question for owner | Proposed action |
|----|------|----------------|----------|--------------------|-----------------|
| A1 | missing | `CONTEXT.md` section 8 | heading absent | What auth/security model should be recorded? | add confirmed section |
| A2 | stale | `CONTEXT.md` section 6 | `backend/` exists, context says `api/` | Should section 6 use `backend/`? | patch service list |
| A3 | cleanup | `OLD_PLAN.md` | superseded by `plans/002-name/` | Keep, merge, archive, or delete? | archive if approved |

Use stable IDs so the user can answer by ID.

## Step 6 - Ask the user for every item
Ask in manageable chunks, but require an explicit decision for each item:
- **Missing mandatory fact** - ask for the value. Do not create an empty required section unless
  the user chooses to defer.
- **Missing optional artifact** - ask whether to create it from the latest template, defer it, or
  mark it intentionally absent.
- **Partial/stale context** - show the evidence and ask whether to update to the inferred value,
  use a corrected user-provided value, or leave as-is.
- **Cleanup candidate** - ask whether to keep, merge, archive, or delete. State the exact file and
  destination before moving or deleting anything.

If the user approves a batch, ensure the batch lists every item and action. If a new issue appears
while applying changes, stop and ask about the new item before writing it.

## Step 7 - Apply approved updates
Apply only approved actions:
- Create missing files from `../icontext-init/templates/` with variables inferred from confirmed
  context. Use TODO markers only for values the user deferred.
- Patch missing `CONTEXT.md` sections or subsections additively. Keep existing owner prose.
- Patch stale context only for confirmed values, citing repo evidence when useful.
- Update plan status in all required places when approved.
- For cleanup, merge/archive/delete exactly as approved. If archiving and the project has no
  convention, ask for the archive location before moving files.

If an approved patch becomes materially different from what was shown, pause and ask again.

## Step 8 - Re-audit and report
Run the relevant inventory checks again. Output:
- Final audit table with statuses: `already present`, `created`, `patched`, `merged`, `archived`,
  `deleted`, `deferred`, `intentionally absent`, or `blocked`.
- Remaining TODOs or deferred owner questions.
- Files changed and files intentionally left alone.

Stop here; do not create a feature plan and do not implement app code.
