# Required companion skills

Check these are installed before scaffolding. If missing, share the link and ask whether
to continue anyway.

| Skill | Source |
|-------|--------|
| `gstack` | https://github.com/garrytan/gstack |
| `ux-ui-pro-max` | https://ui-ux-pro-max-skill.nextlevelbuilder.io |
| `impeccable` | https://impeccable.style |

Check (Claude Code layout):
```bash
for s in gstack ux-ui-pro-max impeccable; do
  test -d "$HOME/.claude/skills/$s" && echo "OK  $s" || echo "MISSING  $s"
done
```

These are advisory companions (design/QA quality), not hard dependencies of the scaffold.
