# Required companion skills

This reference supplies install locations and a quick availability check. The generated project's
`SKILLS.md` §10 is the source of truth for dependency class, invocation triggers, composition,
exclusions, and fallbacks.

Check these are installed before scaffolding. If missing, share the link and ask whether
to continue anyway.

| Skill | Source |
|-------|--------|
| `gstack` | https://github.com/garrytan/gstack.git |
| `security-review` | https://github.com/ice-limited/security-skill.git |
| `ui-ux-pro-max` | https://github.com/nextlevelbuilder/ui-ux-pro-max-skill.git |
| `impeccable` | https://github.com/pbakaus/impeccable.git |
| `grill-with-docs` | https://github.com/mattpocock/skills.git |
| `wayfinder` | https://github.com/mattpocock/skills.git |
| `resolving-merge-conflicts` | https://github.com/mattpocock/skills.git |
| `to-spec` | https://github.com/mattpocock/skills.git |
| `code-review` | https://github.com/mattpocock/skills.git |
| `implement` | https://github.com/mattpocock/skills.git |
| `poteto-mode` | https://github.com/michael-denyer/pstack-claude.git |

Check (Claude Code layout):
```bash
for s in gstack security-review ui-ux-pro-max impeccable grill-with-docs wayfinder resolving-merge-conflicts to-spec code-review implement poteto-mode; do
  test -d "$HOME/.claude/skills/$s" && echo "OK  $s" || echo "MISSING  $s"
done
```

`gstack` and `security-review` are **wired into the lifecycle** (SKILLS.md §10, CONTEXT.md §11.4,
and SECURITY.md §11.6): the
plan review chain, `/investigate` root-cause bug workflow, and the plan/implement security reviews
depend on them. Requirement discovery
requires one alternative route (`grill-with-docs` or `wayfinder`, with documented manual
fallbacks); design companions are recommended for UI work. Merge-conflict resolution
(`resolving-merge-conflicts`) is recommended, not blocking: generated `DEV.md` §5.1 documents the
manual fallback workflow for when the skill is unavailable. `to-spec` is optional and
user-invoked only (it disables model invocation); it also needs the upstream issue-tracker and
triage vocabulary from `/setup-matt-pocock-skills` before it can publish a spec. `code-review`
(mattpocock) is recommended and is a **different thing** from `security-review`'s security-scoped
`code-review` detector: it reviews standards/spec conformance and works without the tracker when
given the `plans/NNN-*` folder or a user-passed spec path. mattpocock `implement` is optional and
user-invoked: the CONTEXT.md §11.5 loop keeps its original step order and the skill only executes
the slice-implement step (detailed in generated `DEV.md` §5.2); its final commit step stays
§11.7-gated, and its chaining to upstream `/tdd` stays owned by that skill's own `SKILL.md`.

`security-review` phase wiring — **plan:** supply-chain · **implement:** secret · code-review ·
auth · dependency · docker. (api · iac · kubernetes · cicd-pipeline · race-condition = ad hoc.)

`poteto-mode` (pstack-claude) is **optional and user-invoked only**: an opt-in goal-driven
execution style (bug · planning · feature · refactor · performance · prototype · PR maintenance ·
shipping playbooks) that routes its bundled skills (`how`, `why`, `architect`, `swarm`,
`interrogate`, `unslop`, …). It never replaces the required routes — bugs stay with gstack
`/investigate`, merge conflicts with `resolving-merge-conflicts`, plan preparation with
`/autoplan` + `security-review` — and the §11.7 mutation gates override its autopilot/shipping
defaults. Install is all-or-nothing: the bundled skills cross-reference each other by sibling
path, so copy/symlink the whole `plugins/pstack/skills/*` set (a flat install that already has
mattpocock's skills must skip pstack's colliding `tdd`/`teach`). Skills-only installs have no
session-start routing hook — invoke `/poteto-mode` by name. A missing `poteto-mode` never blocks
scaffolding: the standard iContext workflow is complete without it.
