# Required companion skills

Check these are installed before scaffolding. If missing, share the link and ask whether
to continue anyway.

| Skill | Source |
|-------|--------|
| `gstack` | https://github.com/garrytan/gstack |
| `ui-ux-pro-max` | https://ui-ux-pro-max-skill.nextlevelbuilder.io |
| `impeccable` | https://impeccable.style |
| `grill-with-docs` | https://github.com/mattpocock/skills |
| `wayfinder` | https://www.aihero.dev/skills-wayfinder |

Check (Claude Code layout):
```bash
for s in gstack ui-ux-pro-max impeccable grill-with-docs wayfinder; do
  test -d "$HOME/.claude/skills/$s" && echo "OK  $s" || echo "MISSING  $s"
done
```

These are advisory companions (design/QA quality), not hard dependencies of the scaffold.
