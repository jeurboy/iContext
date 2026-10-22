# iContext

**Version 1.22.0** · eight portable agent-skills that bootstrap, audit, visualize, load-test, and maintain a **layered project
context** for web/mobile builds — so any AI agent (Claude, Gemini, Codex, Cursor, …) starts every
session already knowing your architecture, conventions, and plan status.

| Skill | Command | Does |
|-------|---------|------|
| **icontext-init** | `/icontext-init` | Scaffold the context backbone (L1 agent files · L2 `CONTEXT.md` at the root + the `context/` folder holding `DEV.md` + `PRODUCT.md` + `QA.md` + `SECURITY.md` + `DESIGN.md` + `SKILLS.md` + `ROLE.md` · L3 `plans/`) + service skeletons. **Greenfield** (new), **brownfield** (read & summarize an existing codebase), or **update/sync** (fill only the missing pieces of an existing backbone). Confirms every L2 section with you first; **idempotent & non-destructive** — re-running never deletes or overwrites your context. |
| **icontext-update** | `/icontext-update` | Update an existing iContext project that already has `CONTEXT.md` to the latest template shape. **Refactors legacy L2 ownership into the latest split** (concern files in `context/`: `DEV.md` · `PRODUCT.md` · `QA.md` · `SECURITY.md` · `DESIGN.md` · `SKILLS.md`, with `CONTEXT.md` at the root) with per-file approval, moving owner text verbatim and leaving pointer stubs. It also upgrades six-file projects by moving legacy §10 from `CONTEXT.md` into `context/SKILLS.md`, relocates pre-1.17 root-level concern files into `context/` (Step 5.7), then adds only approved missing sections/artifacts. |
| **icontext-audit** | `/icontext-audit` | Audit an existing iContext project for latest-template completeness, context/repo drift, plan-status sync, stale placeholders, and unnecessary Markdown cleanup candidates. It asks for an explicit decision on every missing, stale, unclear, or cleanup item before updating, archiving, or deleting anything, then re-audits and reports the final gap table. |
| **icontext-visualize** | `/icontext-visualize` | Export an existing iContext project as an interactive static dependency graph: `context-graph.html` + `context-graph.js`. It reads the L2 set (`CONTEXT.md` + the `context/` concern files, resolved from `context/` first and the repo root second) into a dedicated **L2 lane**, plus agent files, plans, docs, styles, services, and Markdown references without editing source context. |
| **icontext-feature** | `/icontext-feature` | Add one feature plan — a **folder** `plans/NNN-name/` split into role files — with the standard §0–11 structure, role owners, task-status lifecycle, selectable requirement discovery (`/grill-with-docs` or `/wayfinder`), `ROLE.md` multi-agent requirement review, and gstack `/autoplan` plan preparation. Pre-checks required scaffolding (style guide · `docs/openapi.yaml` · `.vscode/launch.json`) and offers to create what's missing. |
| **icontext-feature-review** | `/icontext-feature-review` | Summarize one existing feature plan (folder + `CR-*.md`) into a single plain-language `REVIEW.md` with two lenses — **requirement** (goal · decisions · scope · story→AC→test trace · open questions) and **technical** (architecture · DB/migration · API · UI routes · security · deploy) — plus cross-checks against `docs/openapi.yaml`, `context/DEV.md` §7 and the 3-place status sync, ending in a readiness verdict. Read-only on plans/code. |
| **icontext-loadtest** | `/icontext-loadtest` | Ask which page/screen/route to test on every invocation, trace its real client/API fan-out and hidden writes, then generate guarded k6 profiles, route metrics, and HTML/JSON reports from bundled templates. Never runs load traffic without a separate exact environment approval. |
| **icontext-self-update** | `/icontext-self-update` | Update the installed `icontext-*` skill packages **themselves** to the latest published version — every discovered location (`~/.agents/skills` · `~/.claude/skills` · project `.claude/skills` · the `~/.icontext` cache), copy or symlink mode, `--ff-only` pulls, one confirmed old → new table — and refresh the single shared `scripts/check-update.sh`. It then updates the workspace's **dependency skills** (`skills-lock.json`, e.g. mattpocock/skills) through the Skills CLI (`npx skills check` → confirm → `npx skills update`). Never commits or pushes. |

## The 3-layer context model

```
Layer 1  CLAUDE.md · AGENTS.md/agents.md · AGENT.md/agent.md · GEMINI.md
                                                agent boilerplate (hard rules, vendor-neutral)
Layer 2  CONTEXT.md                          context map · workflow §11 (repo-root entry point)
         context/                            L2 concern folder — one file per concern
           DEV.md                            §3–7 architecture · stack · repo · services · data model
           PRODUCT.md                        §1 product overview · §2 key decisions · §13 open questions
           QA.md                             §9 testing standard + quality gates
           SECURITY.md                       §8 security model · §11.6 security-review wiring
           DESIGN.md                         §12 design tokens + design system
           SKILLS.md                         §10 skill dependencies · triggers · routing · fallbacks
           ROLE.md                           multi-agent role panel (BU/PO/DEV/QA/OPS/STK)
Layer 3  plans/NNN-name/                     one folder per feature, each refs the L2 files
         PLAN.md · plans/README.md           status dashboards (kept in sync, 3 places)
```

**L2 keeps `CONTEXT.md` at the repo root as the entry point and holds the six concern files plus
`ROLE.md` in `context/`, split by concern; section numbers are stable.** A section keeps its `§N`
wherever it lives, so existing `§8` / `§9` / `§10` / `§12` references keep resolving after the
split. `CONTEXT.md`
opens with a **context map** (§ → file → owners) and leaves a `➜ Moved to …` stub where a
section moved out. One concern lives in exactly one file — link to it, never copy it.
Projects created before the split still work; `/icontext-update` offers the refactor, including
moving §10 from a legacy six-file project into `context/SKILLS.md` and relocating pre-1.17
root-level concern files into `context/` (Step 5.7).

Each plan is a **folder split by role** — sections **0–11** distributed across files by their
primary owner (BU/PO/DEV/QA/OPS/STK):

```
plans/NNN-name/
├── README.md   index + canonical Task status + review chain + done gates
├── bu.md       0 Decisions · 1 Goal · Use Cases · User Stories · Acceptance Criteria · Definition of Done
├── po.md       2 Scope · 3 User Stories · 10 Tasks · 11 Open Questions
├── dev.md      5 Tech & Architecture · 6 Data Model · Migration scripts · 7 API Contract · API changes · Pages/routes
├── qa.md       9 Test Plan (>80%) · AC trace · Test Scenarios · Test Cases · Scenario checklist · Test Status · Test Coverage
├── ops.md      8 Security & Privacy · Deploy/Migrations · 8.1 security-review results
└── stk.md      4 Requirement Discovery / Requirement Review / Persona Panel
```

Main feature workflow:
choose `/grill-with-docs` or `/wayfinder` for requirement discovery → `ROLE.md` multi-agent
requirement review → write the role-split plan → gstack `/autoplan` plan preparation →
`security-review` **supply-chain** (plan phase) → iterative implementation, each slice closed by
`security-review` **secret · code-review · auth · dependency · docker** → QA gates.

Context maintenance workflow:
run `/icontext-update` when the template itself changed or a known artifact is missing; run
`/icontext-audit` when you want a full health check against the latest template, real repo state,
plan status, and Markdown cleanup candidates; run `/icontext-visualize` when you want an HTML/JS
dependency graph of the current context; run `/icontext-loadtest` for page-specific capacity scripts.

## Skill dependency routing

Generated projects keep the complete direct-dependency registry and invocation matrix in
[`SKILLS.md`](./icontext-init/templates/context/SKILLS.md) §10. It owns required/alternative/recommended/
optional classification, when and when not to invoke each skill, composition order, and fallbacks.
Individual skill packages still own their own trigger and procedure in their `SKILL.md`; the
project-level `SKILLS.md` owns how those skills are composed.

## Self-update check
Each skill ships a `VERSION`; its `check-update.sh` is a thin stub that execs the **one shared**
[`scripts/check-update.sh`](./scripts/check-update.sh) (synced to `~/.icontext/scripts/` at
install). On **every run** (Step 0) it compares the local version to the published one on GitHub
and prints a one-line result — best-effort and non-blocking (offline/unpublished just prints
"skipped"). Run the shared script with no arguments to check all skills at once. When an update
exists, run **`/icontext-self-update`** — it pulls the repo `--ff-only`, re-syncs every install
location after a confirmed old → new table, refreshes the shared script, and updates the
workspace's dependency skills (`skills-lock.json`) via the Skills CLI. The manual route
(`git pull && ./install.sh`) still works.

## Install

### One-liner (recommended) — pick your tool

```bash
# Claude Code (global)
curl -fsSL https://raw.githubusercontent.com/jeurboy/iContext/main/install.sh | bash -s -- claude

# Cursor (run in your project folder)
curl -fsSL https://raw.githubusercontent.com/jeurboy/iContext/main/install.sh | bash -s -- cursor

# Copilot / Gemini / Codex / Windsurf / Cline / Aider … — change the trailing word per the table
curl -fsSL https://raw.githubusercontent.com/jeurboy/iContext/main/install.sh | bash -s -- <tool>
```

| tool | target | scope |
|------|--------|-------|
| `claude` *(default)* | `~/.claude/skills/` | global slash-command skills |
| `agents` | `~/.agents/skills/` | global skills for ZCode & similar agents |
| `claude-project` | `./.claude/skills/` | this project |
| `cursor` | `./.cursor/rules/icontext.mdc` | project rule |
| `copilot` | `./.github/instructions/icontext.instructions.md` | project |
| `windsurf` | `./.windsurf/rules/icontext.md` | project |
| `cline` | `./.clinerules/icontext.md` | project |
| `gemini` | `./.gemini/GEMINI.md` | project |
| `codex` | existing `./AGENTS.md` or `./agents.md` *(uppercase default; append)* | project |
| `aider` | `./CONVENTIONS.md` *(append)* | project |

Skill files are cached at `~/.icontext/` (override with `ICONTEXT_HOME`); non-Claude tools get a
small pointer file that references them. For Claude Code, the full skill folders are installed so
`/icontext-init` works as a slash command.

### From a clone

```bash
git clone https://github.com/jeurboy/iContext.git
cd iContext
./install.sh                 # Claude Code, copy (default)
./install.sh --link          # symlink instead — repo stays the single source of truth
./install.sh cursor          # …or target any tool from the table above
```

Restart Claude Code, then run `/icontext-init` in a project directory.

## Works with any agent

The workflow is defined once, agent-neutrally, in each skill's `PROCEDURE.md`. Thin entry
points adapt it per agent:

| Agent | Entry point |
|-------|-------------|
| Claude Code | `SKILL.md` (slash command) · `adapters/claude.md` (mapping reference) |
| Gemini CLI | `adapters/gemini.md` |
| OpenAI Codex CLI | `adapters/codex.md` |
| Cursor | `adapters/cursor.md` |
| Any other | point it at `PROCEDURE.md` |

## Repo layout

Skills live at the repo root (no wrapper folder):

```
iContext/
├── README.md
├── install.sh
├── scripts/            validation helpers
├── icontext-init/      SKILL.md · PROCEDURE.md · VERSION · check-update.sh · templates/ · adapters/ · reference/
├── icontext-update/    SKILL.md · PROCEDURE.md · VERSION · check-update.sh · adapters/
├── icontext-audit/     SKILL.md · PROCEDURE.md · VERSION · check-update.sh · adapters/
├── icontext-visualize/ SKILL.md · PROCEDURE.md · VERSION · check-update.sh · scripts/ · adapters/
├── icontext-feature/   SKILL.md · PROCEDURE.md · VERSION · check-update.sh · templates/ · adapters/
├── icontext-feature-review/ SKILL.md · PROCEDURE.md · VERSION · check-update.sh · templates/review-template.md · adapters/
├── icontext-loadtest/  SKILL.md · PROCEDURE.md · VERSION · check-update.sh · templates/ · adapters/
└── icontext-self-update/ SKILL.md · PROCEDURE.md · VERSION · check-update.sh · adapters/
```

## Conventions baked in
- Every `git commit`, `git push`, direct DB command, migration, seed/reset/import/restore, or known
  DB-changing startup command requires explicit confirmation for that exact invocation. When the
  host supports interactive hooks, `.icontext/hooks/guard-command.sh` enforces the gate.
- **Follow `SKILLS.md` §10** for direct dependencies, triggers, exclusions, order, and fallbacks;
  keep README skill lists overview-only.
- **Confirm every L2 section** with the owner before writing; **non-destructive** — never delete/overwrite existing context, only add what's missing.
- **Audit before cleanup** — `/icontext-audit` must ask about every missing, stale, unclear, or extra Markdown item before updating, archiving, or deleting it.
- **Visualize read-only** — `/icontext-visualize` exports static HTML/JS graphs without changing context or app source files.
- **On architecture-impacting change, update context · plan · doc · style · data model together** (no drift).
- Tests: unit (API) + Playwright (UI), coverage > 80% (gate before `done`).
- `styles/`: central design tokens only — no inline colors / look-and-feel.
- Each service is its own git repo, wired as a submodule under the root.
- Stack defaults (Next.js · Flutter · Go+GORM clean-arch · Postgres) are overridable per project.

## Validate

```bash
./scripts/validate.sh
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-init
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-update
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-audit
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-visualize
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-feature
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-feature-review
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-loadtest
python3 /Users/jeurboy/.codex/skills/.system/skill-creator/scripts/quick_validate.py icontext-self-update
```

## Changelog

### 1.22.0
- **pstack workflow stack (`poteto-mode`) wired into the §10 registry** — generated `SKILLS.md`
  registers the optional, user-invoked `poteto-mode` (pstack-claude) goal-driven execution style:
  give it a goal and it picks the playbook (bug · planning · feature · refactor · performance ·
  prototype · PR maintenance · shipping) and routes its bundled skills (`how`, `why`,
  `architect`, `swarm`, `interrogate`, `unslop`, …). It is never a replacement route — bugs stay
  with gstack `/investigate`, merge conflicts with `resolving-merge-conflicts`, plan preparation
  with `/autoplan` + `security-review` — and the §11.7 mutation gates override pstack's
  autopilot/shipping defaults in every case; durable outcomes fold back into `plans/NNN-*` and
  the L2 files.
- **Source & install guidance** — §10.3 records the upstream
  https://github.com/michael-denyer/pstack-claude.git with multi-harness install guidance
  (Claude Code plugin marketplace; Codex, Copilot, Pi, Muse, OpenCode, Gemini CLI, Prime Agent;
  or the skills-only route as one sibling set — cross-references break on partial installs, and
  a flat install skips pstack's `tdd`/`teach` where mattpocock's occupy the names).
- **Maintenance wiring** — `/icontext-update` backfills the row/route/source entry as an
  approved additive gap; `/icontext-audit` flags its absence; `required-skills.md` documents the
  availability check; `scripts/validate.sh` enforces all of it. The workspace dependency install
  itself is CLI-owned: `skills-lock.json` pins all 63 pstack skills via the Skills CLI.

### 1.21.0
- **New skill: `icontext-self-update`** — updates the installed `icontext-*` skill packages
  themselves to the latest published version: discovers every install location
  (`~/.agents/skills` · `~/.claude/skills` · project `.claude/skills` · the `~/.icontext` cache),
  supports copy and symlink (`--link`) installs, pulls the source repo `--ff-only`, shows a
  per-location old → new table, and re-syncs only after approval. It also updates the workspace's
  **dependency skills** (`skills-lock.json`, e.g. mattpocock/skills) via the Skills CLI
  (`npx skills check` → confirm → `npx skills update`). Wired into `install.sh` (new `agents`
  target for `~/.agents/skills`) and `scripts/validate.sh`.
- **One shared `check-update.sh`** — every skill's `check-update.sh` is now a thin stub that execs
  the single shared `scripts/check-update.sh` (repo root or `~/.icontext/scripts/`); the update
  logic lives in exactly one file. Running the shared script with no arguments checks all skills.
- **SKILLS.md §10 registry recheck** — added the missing `icontext-feature-review` row and routes
  (a gap since 1.19.0) plus the new `icontext-self-update` row, extended the §10.3 iContext source
  row, and wired the rows into `icontext-update` (backfill), `icontext-audit` (gap check), and
  validation. All mattpocock registry entries verified against the workspace `skills-lock.json`.
  Also fixed an `icontext-feature` description angle bracket flagged by `quick_validate.py`.

### 1.20.0
- **`icontext-feature` asks full plan vs CR on every run** — no silent inference. For a CR it finds the
  owning plan and asks the user to confirm it every time; with no existing plan it optionally offers to
  create a new full plan instead (declining stops with no CR written).

### 1.19.0
- **New skill: `icontext-feature-review`** — summarizes one existing feature plan (folder + `CR-*.md`)
  into a single plain-language `REVIEW.md` with requirement and technical lenses, cross-checks against
  `docs/openapi.yaml`, `context/DEV.md` §7 and the 3-place status sync, and ends with a readiness
  verdict. Read-only on plans/code. Wired into `install.sh` and `scripts/validate.sh`.

### 1.17.0
- **`context/` folder for Layer 2** — the six concern files (`DEV.md`, `PRODUCT.md`, `QA.md`,
  `SECURITY.md`, `DESIGN.md`, `SKILLS.md`) and `ROLE.md` now live in a dedicated `context/` folder
  instead of loose at the repo root. `CONTEXT.md` stays at the root as the L2 entry point (context
  map + workflow §11), and the L1 agent files stay at the root where every AI tool discovers them.
  Section numbers §1–13 are unchanged, so existing references keep resolving.
- **Legacy relocation (update Step 5.7)** — `/icontext-update` detects pre-1.17 projects whose
  concern files still sit at the root and offers a per-file, approval-first move into `context/`:
  contents stay verbatim, only relative links change (`./CONTEXT.md` → `../CONTEXT.md` inside the
  moved files; inbound refs in `CONTEXT.md`, the L1 files, and plan `ref:` lines are rewritten and
  verified dangling-free). The L2 split (Step 5.5) now creates new files directly in `context/`,
  so monolithic projects don't do a double move.
- **Layout awareness everywhere** — init scaffolds and inventories the new layout, update/audit
  treat root-level siblings as a `relocate candidate` (not a defect) and route them to Step 5.7,
  feature plan templates ref `../../context/<FILE>.md`, load-test reads the `context/` siblings,
  and the visualize exporter resolves each L2 file in `context/` first, then at the root, so both
  layouts export the same graph.

### 1.16.0
- **Merge-conflict routing** — generated `DEV.md` §5.1 documents the `resolving-merge-conflicts`
  workflow (inspect merge state → recover each side's intent from commits/PRs/issues → resolve
  hunks preserving both intents without inventing behaviour → run typecheck · tests · format →
  finish only after the §11.7 confirmation), and generated `SKILLS.md` §10 owns its dependency
  row, upstream source URL, and invocation route.
- **Maintenance wiring** — `/icontext-update` backfills the registry row/route and §5.1 section
  as approved additive gaps; `/icontext-audit` flags their absence. The external skill stays a
  recommended dependency with a documented manual fallback.
- **Tracker-spec route** — generated `SKILLS.md` §10 also registers the user-invoked `to-spec`
  skill: synthesize an already-discussed requirement into a spec, confirm the test seams with the
  owner, publish it to the configured issue tracker, then import/link it into the `plans/NNN-*`
  folder, which stays the canonical plan artifact.
- **Standards/spec code review** — generated `SKILLS.md` §10 registers mattpocock's `code-review`
  (explicitly distinguished from `security-review`'s security-scoped `code-review` detector): a
  two-axis pass over a diff since a fixed point — repo coding standards + smell baseline, and
  faithfulness to the originating plan/spec — with the `plans/NNN-*` folder as the default spec
  source. It complements, never replaces, the §11.6 security-review detectors.
- **Implementation executor** — generated `SKILLS.md` §10 also registers the user-invoked
  mattpocock `implement` skill: it only executes the "Implement the slice" step of the §11.5
  loop, which keeps its **original step order** (slice → implement → concrete test → full-suite
  retest after every change → owner review → §11.6 detectors → fold feedback) — the skill's
  internal ordering yields to it, and its final commit step stays §11.7-gated. Generated
  `DEV.md` §5.2 spells out the execution flow, the optional `code-review` pre-review pass, and
  the commit gate; `/tdd` chaining stays owned upstream.

### 1.15.0
- **New `/icontext-loadtest` skill** — asks for the target page/screen/route every invocation,
  traces real API fan-out and hidden writes, and generates guarded k6 profiles plus route-level
  metrics and HTML/JSON reports from sanitized bundled templates without running by default.
- **Development context wiring** — generated `DEV.md` documents k6 load-test tooling, evidence, and
  the isolated-environment execution boundary; generated `SKILLS.md` owns invocation routing.
- **Maintenance opt-in** — `/icontext-update` and `/icontext-audit` now ask on every run whether the
  owner wants a page-specific load-test script, then hand off only when accepted.
- **L1 casing aliases** — init/update/audit/visualize and the installer accept `AGENTS.md` or
  `agents.md`, and `AGENT.md` or `agent.md`, preserving the project's selected casing without
  generating duplicate instruction files.

### 1.14.0
- **Dedicated skill-routing context** — Layer 2 now includes `SKILLS.md` as the owner of stable
  §10: direct dependencies, invocation triggers, composition order, exclusions, and fallbacks.
  `CONTEXT.md` keeps the context map, a §10 pointer stub, and workflow §11.
- **Legacy restructuring** — `icontext-update` now detects both monolithic projects and older
  six-file projects, offers `SKILLS.md` as a separate per-file migration, moves owner-authored §10
  text verbatim, leaves a pointer stub, and rewrites L1/plan references only after approval.
- **End-to-end ownership** — init, audit, feature planning, visualization, plan templates, L1
  templates, documentation, and validation understand the seven-file L2 shape.
- **Systematic bug routing** — generated `SKILLS.md` registries route errors, regressions, stack
  traces, and unexpected behavior through gstack `/investigate`: reproduce and prove root cause
  before an authorized minimal fix, regression test, and fresh verification.
- **Installable dependency provenance** — generated registries include verified upstream Git/source
  URLs and install guidance so an agent can resolve a missing selected skill without guessing its
  repository, then verify discovery in the target agent after installation.
- **Confirmation-gated mutation hook** — generated projects include a portable pre-command guard
  and policy for every commit, push, direct DB access/mutation, migration, seed, reset, import, or
  restore. Init wires it when the host supports interactive hooks; update backfills it; audit verifies
  both the artifacts and the real host path without running the restricted action.

### 1.13.0
- **Dedicated development context** — Layer 2 now includes `DEV.md` as the owner of stable
  sections §3–7 (architecture, stack, repository, services, and data model); at that release,
  `CONTEXT.md` kept the context map, pointer stubs, skills, and workflow.
- **End-to-end migration support** — `icontext-update` can opt-in migrate existing projects to the
  six-file L2 shape, while init, audit, feature-plan references, visualization, and validation all
  understand the new `DEV.md` ownership boundary.

### 1.10.2
- **Readable graph focus** — `icontext-visualize` now lays dense context graphs out in lanes,
  keeps labels readable while zooming, adds label-density controls, and fades unrelated nodes when
  a node is clicked so the selected dependency neighborhood is easier to inspect.

### 1.10.1
- **Interactive graph controls** — `icontext-visualize` exports graphs with zoom in/out, mouse wheel
  zoom, canvas panning, a highlighted `START` node with focus control, animated node dragging,
  plan-status badges, and a `View MD` panel for selected Markdown nodes.

### 1.10.0
- **New `icontext-visualize` skill** — exports an existing iContext project to a static
  dependency graph (`context-graph.html` + `context-graph.js`) using a bundled dependency-free
  Node script. It links `CONTEXT.md` to agent files, role/status files, plans, services, manifests,
  docs, API contracts, styles, and referenced Markdown without editing source context.
- Installer, pointers, README, and validation now include all five skills:
  `icontext-init`, `icontext-update`, `icontext-audit`, `icontext-visualize`, and
  `icontext-feature`.

### 1.9.0
- **New `icontext-audit` skill** — audits an existing iContext project against latest templates,
  current repo evidence, plan-status sync, stale placeholders, and Markdown cleanup candidates.
  It asks for an explicit owner decision on every missing, stale, unclear, or cleanup item before
  applying updates, archiving, or deleting anything.
- Installer, pointers, README, and validation now include all four skills:
  `icontext-init`, `icontext-update`, `icontext-audit`, and `icontext-feature`.

### 1.8.0
- **Wayfinder discovery route** — feature planning now asks the user to choose `/grill-with-docs`
  for clear-ish requirements or `/wayfinder` for large/foggy requirements without a clear solution
  path. If Wayfinder creates unresolved planning-critical tickets, `icontext-feature` stops at the
  map and resumes plan creation once the way is clear.
- **Plan §4 expanded** — `stk.md` now records Requirement Discovery separately from Requirement
  Review / Persona Panel, including Wayfinder map/ticket links when used.

### 1.7.0
- **New `icontext-update` skill** — for projects that already have `CONTEXT.md`; backfills missing
  sections/artifacts from the latest templates without overwriting existing context. It reports and
  confirms every proposed change before writing.
- Installer, pointers, README, and validation now include all three skills:
  `icontext-init`, `icontext-update`, and `icontext-feature`.

### 1.6.0
- **Codex L1 template** — scaffold now includes `AGENTS.md` and update/sync detects it.
- **Main development workflow in CONTEXT.md** — `/grill-with-docs` for requirements, `ROLE.md`
  multi-agent requirement review, gstack `/autoplan` for plan preparation, then implementation and
  QA gates.
- **ROLE.md upgraded** — now defines a repeatable multi-agent requirement review protocol.
- **Codex validation cleanup** — removed unsupported `version` frontmatter from skill files; version
  stays in each `VERSION` file.
- **Companion skill naming** — corrected `ui-ux-pro-max` and added `grill-with-docs`.

### 1.4.0
- **Implementation loop (loop engineering)** — `CONTEXT.md` §11.5 + plan `qa.md` now spell out the
  `implement` phase as a tight iterate-and-retest loop: slice → implement → test (with the exact
  run commands + coverage method) → re-run the whole suite (regression) → review with the owner
  and ask for feedback → repeat, until User Stories pass and coverage > 80%.
- **Optimized `icontext-init` description** — restructured for sharper triggering (two clear
  situations + explicit "do NOT use" cases), from a skill-creator description pass.

### 1.3.0
- **Confirm the repo strategy before wiring submodules** — `icontext-init` asks the owner to pick
  git submodules (default), a monorepo, or separate un-wired repos, and records the choice.
- **Custom service directories** — services no longer assumed to be `api/ web/ app/`; the owner
  names the real dirs (e.g. `backend/ frontend/ admin/ worker/`), and brownfield detects them.
- **Review polish** — broadened skill descriptions for better triggering, and reframed caps-heavy
  directives as reasoning (per the skill-creator review).

### 1.2.0
- **Update/sync mode** — re-running `icontext-init` on an existing backbone fills only the missing
  pieces; **non-destructive** (never deletes/overwrites existing context).
- **Section-by-section confirmation** — every `CONTEXT.md` section is confirmed with the owner;
  first-time init is a deep per-section interview, and mandatory fields (e.g. project description)
  are always asked.
- **Version + update check runs first on every skill invocation.**
- **gstack + review chain** baked into context — run `/autoplan` (ceo · eng · design · devex)
  before implementing any plan.
- **Sync-on-architecture-change rule** — keep context · plan · doc · style · data model in step.
- **Richer plan templates** — bu (use cases · user stories · acceptance criteria · definition of
  done), qa (test scenarios · cases · status · coverage), dev (migration scripts · API changes ·
  pages/routes); expanded `DEV.md` §7 Data Model.
- **6-state task status** — `to do → plan → ready to implement → implement → ready to test → done`.
- **icontext-feature scaffolding pre-check** — style guide · `docs/openapi.yaml` · `.vscode/launch.json`.
- Added `adapters/claude.md` for both skills.
- **Multi-tool one-liner installer** — `curl … | bash -s -- <tool>` for Claude Code, Cursor,
  Copilot, Gemini, Codex, Windsurf, Cline, Aider; self-clones and caches at `~/.icontext/`.

### 1.1.0
- Role-split plan folders + self-update check.

### 1.0.0
- Initial context-init toolkit for web/mobile projects.
