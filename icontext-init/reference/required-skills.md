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

Check (Claude Code layout):
```bash
for s in gstack security-review ui-ux-pro-max impeccable grill-with-docs wayfinder; do
  test -d "$HOME/.claude/skills/$s" && echo "OK  $s" || echo "MISSING  $s"
done
```

`gstack` and `security-review` are **wired into the lifecycle** (SKILLS.md §10, CONTEXT.md §11.4,
and SECURITY.md §11.6): the
plan review chain, `/investigate` root-cause bug workflow, and the plan/implement security reviews
depend on them. Requirement discovery
requires one alternative route (`grill-with-docs` or `wayfinder`, with documented manual
fallbacks); design companions are recommended for UI work.

`security-review` phase wiring — **plan:** supply-chain · **implement:** secret · code-review ·
auth · dependency · docker. (api · iac · kubernetes · cicd-pipeline · race-condition = ad hoc.)
