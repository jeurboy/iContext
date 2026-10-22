---
name: icontext-self-update
description: Update the installed icontext-* skill packages themselves to the latest published
             version — the skill folders under ~/.agents/skills, ~/.claude/skills, the project's
             .claude/skills, or the ~/.icontext cache — and update the workspace's dependency
             skills (skills-lock.json, e.g. mattpocock/skills) via the Skills CLI. Use when
             check-update.sh prints "update available", after a git pull in the iContext repo, or
             when the user asks to "update the skills / อัพเดท skill / self-update / อัพเดท
             icontext เป็นล่าสุด / update dependency skills". Discovers every install location
             (copy or symlink mode), pulls the iContext repo fast-forward only, re-syncs the skill
             folders and the shared scripts/check-update.sh after showing an old-to-new table and
             getting approval, then offers `npx skills update` for dependency skills. Never
             commits or pushes. Do NOT use for updating a project's CONTEXT.md or context
             templates — that is icontext-update.
allowed-tools:
  - Read
  - Bash
  - AskUserQuestion
---

# icontext-self-update

> **Run `bash check-update.sh` first** and surface its one-line result. The check is best-effort
> and never blocks.

Read **[PROCEDURE.md](./PROCEDURE.md)** and execute it. This skill updates the **skill packages
themselves** — the installed `icontext-*` folders an agent loads, plus the workspace's dependency
skills — not any project's context.

## Mappings
- **Discover (Step 1)** — scan `~/.agents/skills`, `~/.claude/skills`, `$PWD/.claude/skills`, and
  `${ICONTEXT_HOME:-~/.icontext}` for `icontext-*/VERSION`; record copy vs symlink (link) mode.
- **Latest version (Step 2)** — fetch `<skill>/VERSION` from GitHub raw; skills are version-locked
  per release, so one shared number.
- **Source (Step 3)** — symlinked installs update via `git pull --ff-only` in the linked repo; copy
  installs sync from `$ICONTEXT_REPO_PATH`, the `~/.icontext/repo` cache, or a fresh clone.
- **Confirm (Step 4)** — one old → new table per location × skill; replace or pull only after approval.
- **Apply (Step 5)** — link mode: ff-only pull. Copy mode: `rm -rf` + `cp -R` per skill exactly like
  `install.sh`, then refresh the shared `~/.icontext` cache **and** sync
  `scripts/check-update.sh` into `${ICONTEXT_HOME:-~/.icontext}/scripts/` — every skill's
  `check-update.sh` is a stub that execs that one shared script.
- **Dependency skills (Step 6)** — if the workspace has `skills-lock.json`, run `npx skills check`,
  show the outdated list, and after approval run `npx skills update` (the Skills CLI owns the lock
  file; never hand-edit `computedHash`). Best-effort: skip with a note when npx is missing or
  offline. Scope is the current workspace only — generated projects keep their own lock.
- **Verify (Step 7)** — re-read every `VERSION`, print the final table, remind the user to restart
  the agent app so it reloads the skills.
- **Restricted actions** — never commit, never push, never stash/reset/force a diverged source repo;
  stop and report instead.

## Stop rule
Finish at the update report. Do not touch project context (`CONTEXT.md`, plans, code) and do not
run other icontext workflows; those stay separate invocations.
