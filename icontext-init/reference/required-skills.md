# Required companion skills

Check these are installed before scaffolding. If missing, share the link and ask whether
to continue anyway.

| Skill | Source |
|-------|--------|
| `gstack` | https://github.com/garrytan/gstack |
| `security-review` | https://github.com/ice-limited/security-skill |
| `ui-ux-pro-max` | https://ui-ux-pro-max-skill.nextlevelbuilder.io |
| `impeccable` | https://impeccable.style |
| `grill-with-docs` | https://github.com/mattpocock/skills |
| `wayfinder` | https://www.aihero.dev/skills-wayfinder |

Check (Claude Code layout):
```bash
for s in gstack security-review ui-ux-pro-max impeccable grill-with-docs wayfinder; do
  test -d "$HOME/.claude/skills/$s" && echo "OK  $s" || echo "MISSING  $s"
done
```

`gstack` and `security-review` are **wired into the lifecycle** (CONTEXT.md §11.4 and §11.6): the
plan review chain and the plan/implement security reviews depend on them. The rest are advisory
companions (design/QA quality), not hard dependencies of the scaffold.

`security-review` phase wiring — **plan:** supply-chain · **implement:** secret · code-review ·
auth · dependency · docker. (api · iac · kubernetes · cicd-pipeline · race-condition = ad hoc.)
