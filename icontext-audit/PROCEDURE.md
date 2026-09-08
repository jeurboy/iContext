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
- **Never commit / push or access/change a DB without per-invocation confirmation.** Audit is
  read-only until approved; never run a DB client, migration, seed/reset/import/restore, or a
  DB-changing startup path merely to verify documentation (CONTEXT.md §11.7).

## Step 0 - Update check
Run `check-update.sh` next to this file and surface its one-line result. Continue even if offline.

## Step 1 - Confirm audit target
At the target root, confirm `CONTEXT.md` exists. Then identify the iContext source templates from
the sibling path `../icontext-init/templates/`.

Inventory the expected backbone:
- L1 files: `CLAUDE.md`, one of `AGENTS.md` or `agents.md`, one of `AGENT.md` or `agent.md`, and
  `GEMINI.md`. Treat each casing pair as one logical artifact and preserve existing casing. If both
  aliases exist, add a duplication row and ask which is canonical; never merge/archive/delete one
  without its own explicit decision.
  Detect the actual casing from directory entries, not two independent existence checks; on a
  case-insensitive filesystem both alias paths can resolve to the same inode.
- L2 files: `CONTEXT.md` (repo-root entry point) plus the `context/` folder — `context/DEV.md`,
  `context/PRODUCT.md`, `context/QA.md`, `context/SECURITY.md`, `context/DESIGN.md`,
  `context/SKILLS.md`, `context/ROLE.md`.
  A project holding all of sections 1-13 in one `CONTEXT.md` is **not a defect** — it predates the
  L2 split. Report it as a `split candidate` and point the owner at `/icontext-update` Step 5.5;
  never split it here.
  A six-file project with §10 still in `CONTEXT.md` is also a `SKILLS.md split candidate`; point
  it at the same update step and do not create a duplicate §10 during audit.
  A project whose concern files or `ROLE.md` sit at the repo root instead of `context/` (the
  pre-1.17 layout) is a `relocate candidate`, not a defect — point the owner at
  `/icontext-update` Step 5.7; never move files during audit.
  A §10 pointer stub with no `SKILLS.md` target is a dangling-reference defect and requires owner
  recovery input; do not silently reconstruct project-specific dependencies from the template.
- L3/status files: `PLAN.md`, `plans/README.md`, `plans/_TEMPLATE/`
- Shared scaffolding: `docs/openapi.yaml`, `styles/css/tokens.css`, `styles/components/`,
  `.vscode/launch.json`, `docker-compose.yml`
- Agent safety: `.icontext/hooks/guard-command.sh`, `.icontext/hooks/POLICY.md`, executable mode,
  L1/CONTEXT.md §11.7 rules, and the active host's project-local hook registration/status
- Service guides: each service's `STRUCTURE.md`, using service names from `DEV.md` section 6
- Feature plans: each `plans/NNN-name/` folder and its role files

## Step 1.5 - Offer page-specific load-test scaffolding every run

Ask the owner on every invocation:

> Do you want to create or refresh a load-test script for a page/screen/route after this audit?

Record yes/no in the audit register. This optional offer is not an audit defect and approval does
not authorise traffic. If yes, finish the audit and all separately approved maintenance first, then
invoke `/icontext-loadtest`. That workflow asks which page/screen/route to test every time, traces
the real request fan-out and hidden writes, and generates/validates offline by default.

## Step 2 - Compare against the latest template
Build a template-completeness table. Do not edit yet.

Check:
- The L2 files contain the latest section set **across all of them** — a section counts as present
  wherever it lives (`context/PRODUCT.md` 1/2/13 · `context/DEV.md` 3-7 · `context/SKILLS.md` 10 · `CONTEXT.md` 11 ·
  `context/SECURITY.md` 8/11.6 · `context/QA.md` 9 · `context/DESIGN.md` 12), and section numbers
  are stable across the split so existing
  references still resolve. Flag a section that appears in **two** files as a duplication defect,
  except for a `➜ Moved to …` pointer stub in `CONTEXT.md`, which is navigation rather than content.
  Sections to check: 1-13, section 11.0 main workflow,
  section 11.1 plan structure, section 11.2 plan rules, section 11.3 sync rule, section 11.4
  review chain, section 11.5 implementation loop, and section 11.6 `security-review` phase wiring
  (plan = supply-chain; implement = secret, code-review, auth, dependency, docker), plus section
  11.7 agent mutation safety and hook wiring.
- `ROLE.md` includes the Requirement Review Protocol.
- `SKILLS.md` §10 includes the direct dependency registry and invocation routes, including the
  gstack `/investigate` route for errors, regressions, stack traces, and unexpected behavior, the
  `resolving-merge-conflicts` route for in-progress merge/rebase conflicts together with its
  `DEV.md` §5.1 workflow section, the user-invoked `to-spec` tracker-spec route, the mattpocock `code-review`
  standards/spec pass (distinct from `security-review`'s security-scoped
  `code-review` detector), and the user-invoked mattpocock `implement` executor together with its
  `DEV.md` §5.2 execution-flow section (the §11.5 loop keeps its original step order; flag a
  missing one as an additive gap, not a registry rewrite).
  Each external direct dependency also has an upstream Git/source URL and installation guidance;
  flag missing, placeholder, or obviously non-upstream URLs for owner confirmation.
- Plan templates include `README.md`, `bu.md`, `po.md`, `dev.md`, `qa.md`, `ops.md`, and `stk.md`,
  including the latest Requirement Discovery / Requirement Review / Persona Panel shape and the
  `ops.md` section 8.1 Security review table.
- L1 files (including the selected lowercase/uppercase aliases) point agents to `CONTEXT.md` and
  `context/SKILLS.md`, preserve the project rules, and include
  current workflow guidance.
- The portable mutation guard protects every `git commit`, `git push`, direct DB command, and
  migration/seed/reset/import/restore action with an interactive per-invocation confirmation. If the
  active host supports hooks, verify the project hook is registered and exercises the guard; if it
  does not, record instruction-only enforcement rather than treating that as silently active.
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
| A1 | missing | `context/SECURITY.md` section 8 | heading absent | What auth/security model should be recorded? | add confirmed section |
| A2 | stale | `context/DEV.md` section 6 | `backend/` exists, context says `api/` | Should section 6 use `backend/`? | patch service list |
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
- For an approved safety-hook gap, add/patch the portable artifacts, L1 rules, and CONTEXT.md §11.7;
  merge the active host's documented project hook without overwriting unrelated hooks. Dry-run safe
  and restricted payloads through the guard and the real host path when available.
- Patch missing L2 sections or subsections additively. Keep existing owner prose. Route a legacy
  §10 move to `icontext-update` instead of copying it into `context/SKILLS.md` during audit, and
  route a root-level concern-file layout to `icontext-update` Step 5.7 instead of relocating here.
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
- Hook status: `active and verified`, `artifacts present; wiring pending`, or
  `hook unavailable; policy enforced by instructions`.

Stop here; do not create a feature plan and do not implement app code. If the owner accepted Step
1.5, continue only by handing off to `/icontext-loadtest` as a separate workflow with its own page
question and execution gate.
