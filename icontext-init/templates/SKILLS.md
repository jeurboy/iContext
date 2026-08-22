# {{PROJECT_NAME}} — SKILLS.md (Layer 2 · skill dependencies & routing)

> **Split out of `CONTEXT.md`.** Holds §10. Section numbers are unchanged, so every existing
> `§10` reference in plans and docs still resolves — only the file moved.
> Read [CONTEXT.md](./CONTEXT.md) first for the context map and workflow.
> Siblings: [DEV.md](./DEV.md) · [PRODUCT.md](./PRODUCT.md) · [QA.md](./QA.md) ·
> [SECURITY.md](./SECURITY.md) · [DESIGN.md](./DESIGN.md)

**Owners:** all · **Read by:** anyone selecting, invoking, composing, adding, or removing a skill.

---

### 10. Skills ที่ใช้ · Skill Dependencies & Invocation

#### 10.1 Registry rules
- This file is the project source of truth for **direct skill dependencies**, invocation triggers,
  ordering, and fallbacks. Do not flatten transitive dependencies here; the owning skill documents
  those in its own `SKILL.md` or reference files.
- Each individual `SKILL.md` remains the source of truth for that skill's own trigger and procedure.
  This file decides how the project composes those skills.
- Classify every dependency as **required**, **alternative**, **recommended**, or **optional**.
  A required dependency may block its phase; an alternative dependency requires one approved route
  from its group; recommended and optional dependencies must have a manual fallback.
- Check availability at runtime. Do not claim a skill or detector ran when it was unavailable, and
  never substitute an LLM opinion for a required detector's output.
- Every external direct dependency must have a verified Git/source URL in §10.3. Prefer the
  upstream Git clone URL; when no public Git repository exists, record the canonical installer page
  and label it clearly. Never invent a repository URL.

#### 10.2 Dependency registry

| Skill / group | Class | Invoke when | Do not invoke when | Direct dependency | Output / fallback |
|---------------|-------|-------------|--------------------|-------------------|-------------------|
| `gstack` | required | installing the project workflow; provides `/autoplan`, `/investigate`, and the plan-review chain | the project has explicitly approved equivalent review and debugging workflows | — | Install from https://github.com/garrytan/gstack; if unavailable, run the equivalent workflow manually and record that fallback |
| `/grill-with-docs` | alternative: requirement discovery | requirements mostly fit one planning session but need sharper scope, edge cases, terms, ADRs, or domain updates | the solution path is still too large or foggy to produce a useful plan | companion docs/domain workflow | Fall back to `/grill-me`, `/grilling`, or a documented manual interview |
| `/wayfinder` | alternative: requirement discovery | the request spans multiple research/decision/prototype sessions or has no clear solution path yet | planning-critical decisions are already clear enough for one plan | issue tracker or durable ticket map | Keep resolving the map; do not force an iContext plan while critical tickets remain open |
| `/autoplan` + `/plan-*-review` | required: plan | a feature plan is written and must be prepared before `ready to implement` | there is no plan yet | `gstack` | Run CEO · engineering · design (if UI) · DevEx (if developer-facing); if unavailable, perform and record equivalent passes manually |
| `/investigate` | required: bug investigation | the user reports an error, 500, stack trace, failing regression, unexpected behavior, a previously working flow that stopped, or asks for debugging/root-cause analysis | a planned enhancement or known mechanical change has no bug evidence | `gstack` | Reproduce and trace the root cause before any fix; if a fix is authorized, make the smallest root-cause change, add a regression test, rerun the relevant/full suite, and freshly verify the original scenario. For diagnosis-only requests, stop after the evidence-backed root cause report |
| `security-review` | required: plan + implement | plan: after `/autoplan`; implement: before each changed slice leaves the loop | never skip based only on an LLM review | detector prerequisites owned by `security-review` | Plan: `supply-chain`; implement: `secret`, `code-review`, plus conditional `auth`, `dependency`, `docker`; report unavailable prerequisites explicitly |
| `ui-ux-pro-max` + `impeccable` | recommended: UI | designing or reviewing a page, component, screen, responsive flow, or visual system | no UI/look-and-feel is touched | — | Use the project's design rules and a documented manual design review if unavailable |
| `icontext-init` | required only for first setup | no iContext backbone exists, for greenfield or brownfield onboarding | an existing `CONTEXT.md` backbone is already present | — | Creates the project context backbone; does not create a feature plan |
| `icontext-update` | required for template migration | an existing iContext project needs the latest template shape or an approved L2 restructure | first-time setup or one feature plan | `icontext-init/templates/` | Confirmation-first additive update; preserves owner-authored text |
| `icontext-audit` | optional maintenance | checking completeness, repo drift, plan/status sync, placeholders, or Markdown cleanup candidates | first-time setup or a known narrow migration | latest iContext templates | Read-only until every proposed change receives an explicit decision |
| `icontext-visualize` | optional inspection | exporting the current context and dependencies as an interactive graph | the user asked to modify context rather than inspect it | Node.js runtime | Generates static HTML/JS without editing source context |
| `icontext-feature` | required for a new feature plan | adding a feature or capability after the context backbone exists | implementing the feature or doing whole-project setup | one discovery route, `ROLE.md`, `/autoplan`, `security-review` | Creates and prepares one numbered role-split plan; stops before implementation |

#### 10.3 Source & install registry

| Skill(s) | Upstream Git/source URL | Install guidance |
|----------|-------------------------|------------------|
| `gstack` (`/investigate`, `/autoplan`, `/plan-*-review`) | https://github.com/garrytan/gstack.git | Read the upstream setup instructions and install for the active agent/host |
| `security-review` | https://github.com/ice-limited/security-skill.git | Install the skill and its detector prerequisites from upstream; report any unavailable detector |
| `/grill-with-docs`, `/wayfinder` | https://github.com/mattpocock/skills.git | Use the upstream skill installer for the selected skill; do not install the whole catalog unless requested |
| `ui-ux-pro-max` | https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git | Follow the repository's agent-specific installation instructions |
| `impeccable` | https://github.com/pbakaus/impeccable.git | Prefer the upstream installer documented by the repository |
| `icontext-init`, `icontext-update`, `icontext-audit`, `icontext-visualize`, `icontext-feature` | https://github.com/jeurboy/iContext.git | Install or update iContext for the active agent using the repository instructions |

When a selected required skill is missing, surface its URL and use the active agent's supported
installation flow. Review upstream instructions before running an installer, respect host/user
approval requirements, and never treat a successful clone as proof that the skill is installed or
discoverable; verify it through the target agent's skill lookup afterward.

#### 10.4 Invocation routes

| Situation | Route |
|-----------|-------|
| No iContext backbone | `icontext-init` |
| Existing backbone needs latest structure | `icontext-update` |
| Existing context needs a completeness/drift review | `icontext-audit` |
| Need a dependency graph only | `icontext-visualize` |
| Bug, error, failed regression, or unexpected system behavior | `/investigate` → collect evidence + reproduce → trace root cause → test the hypothesis → fix only if authorized → regression test + fresh verification |
| Clear-ish new feature | `/grill-with-docs` → `ROLE.md` review → `icontext-feature` → `/autoplan` → `security-review:supply-chain` |
| Large/foggy new feature | `/wayfinder` until planning-critical tickets resolve → `ROLE.md` review → `icontext-feature` → `/autoplan` → `security-review:supply-chain` |
| Each implementation slice | implement → test/retest → `security-review` scoped detectors → owner feedback |

#### 10.5 Composition and precedence
- Requirement discovery is **exclusive per planning pass**: choose `/grill-with-docs` **or**
  `/wayfinder`; switch routes only when the reason is recorded in the affected plan or ticket map.
- Project privacy, security, repository, and approval rules override a dependency skill's defaults.
- The project mutation gates in `CONTEXT.md` §11.7 override every skill: no skill may commit, push,
  access/change a DB, migrate, or seed without the required per-invocation confirmation. When the
  host supports interactive hooks, keep `.icontext/hooks/guard-command.sh` wired.
- A skill may narrow work but must not silently broaden the user's authorization, commit/push,
  deploy, delete, or mutate production state.
- When two skills overlap, use the narrower skill for the task and link its output into the broader
  workflow instead of running duplicate passes.
- When QA or review exposes a bug whose cause is unknown, route to `/investigate` before changing
  code. After the root-cause fix, return to QA/review for end-to-end verification.

#### 10.6 Keeping this registry current
- When adding, removing, renaming, or changing the trigger/fallback of a direct dependency, update
  this file in the **same change** as the affected workflow, plan template, or security/design rule.
- Keep install links and minimum-version constraints here only when the project actually depends on
  them. Runtime installed/uninstalled state belongs in the execution report, not durable context.
- Verify source URLs against the upstream repository before changing them. If a project pins a
  fork or revision, record that explicit URL/ref instead of silently following latest upstream.
- Keep overview-only lists in `README.md`; link them here instead of maintaining a second registry.
