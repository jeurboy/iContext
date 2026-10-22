# icontext-self-update - procedure (agent-neutral)

> Source of truth for updating the installed icontext-* skill packages to the latest published
> version, and the workspace's dependency skills to their latest upstream. It updates the **skill
> files themselves** (the folders the agent loads), not a project's context — for `CONTEXT.md` /
> template work use `icontext-update`.

## Operating rules
- **Confirmation-first.** Show the full old → new table and get approval before replacing any folder
  or pulling any repo. No silent writes.
- **Non-destructive pulls.** `git pull --ff-only` only. A diverged or dirty source repo is reported,
  never stashed, reset, or forced.
- **Never commit or push** anything, anywhere.
- **Offline-tolerant.** If GitHub is unreachable and no newer local clone exists, report and stop.
- **Skills only.** Never touch a project's `CONTEXT.md`, plans, app code, or config.

## Step 0 - Update check
Run `check-update.sh` next to this file (a stub that execs the shared `scripts/check-update.sh`);
surface the one line; continue even if offline. To preview every skill at once, run the shared
script directly with no arguments.

## Step 1 - Discover installed skills
Scan these locations (Bash) and record, per location, each `icontext-*/VERSION` and whether the
skill folders are **copies** or **symlinks** (symlink = installed with `install.sh --link`):
1. `$HOME/.agents/skills` — ZCode & similar global agents
2. `$HOME/.claude/skills` — Claude Code global
3. `$PWD/.claude/skills` — Claude Code project
4. `${ICONTEXT_HOME:-$HOME/.icontext}` — shared cache that pointer files read

Ignore locations with no `icontext-*` folders. If none are found at all, stop and point the user to
the repo's `install.sh`.

## Step 2 - Find the latest published version
Fetch `https://raw.githubusercontent.com/jeurboy/iContext/main/icontext-init/VERSION` (all skills
are version-locked per release; one number describes the release). If the fetch fails and no
candidate source repo in Step 3 is at a newer version than every installed copy, report "offline or
already newest" and stop. When the user pinned a fork/branch in `$ICONTEXT_REPO`, fetch from there.

## Step 3 - Locate the source repo
Pick the update source, in this order:
1. **Link mode** — a discovered skill folder is a symlink: the source is the repo root it resolves
   into. Updating means one `git -C <repo> pull --ff-only`; every linked location updates at once.
2. **`$ICONTEXT_REPO_PATH`** — env var pointing at a clone (must contain `icontext-init/` + `.git`).
3. **`${ICONTEXT_HOME:-~/.icontext}/repo`** — the one-liner install cache: `git pull --ff-only` it,
   or `git clone --depth 1 <repo-url>` (default `https://github.com/jeurboy/iContext.git`, honor
   `$ICONTEXT_REPO`) when absent.
4. Nothing found → `AskUserQuestion`: clone into the cache (default) or name a local clone path.

Read `<source>/icontext-*/VERSION`; those are the target versions. If the source is dirty
(`git status --porcelain` non-empty) or ahead of the published VERSION (unreleased local edits),
say so in the Step 4 table — the user decides whether to ship them to their install locations.

## Step 4 - Confirm the change set
Build one table — per location × per installed skill → `local -> target` — plus:
- skills shipped in the source but **not installed** at that location (offer to add; default no —
  respects intentionally partial installs),
- locations in link mode vs copy mode.

Get approval for the exact set of folders to replace / repos to pull. If declined, stop; nothing changed.

## Step 5 - Apply (icontext-* skills)
- **Link mode:** `git -C <source> pull --ff-only`. If it fails (diverged), stop and report — never force.
- **Copy mode:** for each approved location and skill, replace the folder exactly like `install.sh`:
  `rm -rf <loc>/<skill> && cp -R <source>/<skill> <loc>/<skill>`.
- **Shared check script:** sync `<source>/scripts/check-update.sh` to
  `${ICONTEXT_HOME:-~/.icontext}/scripts/check-update.sh`. Every installed skill's `check-update.sh`
  is a thin stub that execs that one shared file — without this sync the stubs fall back to a
  "skipped" line.
- **Shared cache:** also sync the skill folders inside `${ICONTEXT_HOME:-~/.icontext}` (same
  replace) so pointer-based tools (Cursor · Copilot · Gemini · Codex · Windsurf · Cline · Aider)
  read the new files through their fixed paths.
- **Pointer files:** their paths are unchanged, so they stay valid. If the release changed the
  pointer body, suggest re-running `./install.sh <tool>` inside each affected project — do not
  hunt for projects yourself.

## Step 6 - Dependency skills (skills-lock.json)
Third-party skills the workspace pinned with the Skills CLI (e.g. `mattpocock/skills`: `wayfinder`,
`code-review`, `implement`, `grill-with-docs`, …). Scope: **the current workspace only** — a
generated iContext project keeps its own `skills-lock.json`.
1. Look for `$PWD/skills-lock.json` (and `$PWD/.agents/skills/`). Missing → report "no dependency
   skills pinned here" and skip the step.
2. Best-effort check: `npx --yes skills@latest check`. No `npx`/network → note it, skip.
3. Show the outdated list (skill → old → new hash/version) and ask once whether to update.
4. On approval run `npx --yes skills@latest update`, then re-run `check` and report the result.
   The Skills CLI owns `skills-lock.json` — never hand-edit `computedHash` or vendor files yourself.
5. Remind: dependency-skill updates may change behavior the project's `SKILLS.md` §10 routes rely
   on; suggest running `/icontext-audit` if a major version jumped.

## Step 7 - Verify and report
Re-read every `VERSION` at every touched location, and confirm the shared
`${ICONTEXT_HOME:-~/.icontext}/scripts/check-update.sh` matches the source. Report the final table:
every location on the target version = success; anything still old = named follow-up. End with the
reminder to **restart the agent app** so it reloads the skill files, then re-run any `/icontext-*`
command.

## Stop rule
Finish at the update report. Do not update project context, run other icontext workflows, commit,
or push.
