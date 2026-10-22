# icontext-self-update (portable skill)

Updates the installed `icontext-*` skill packages **themselves** to the latest published version —
the folders under `~/.agents/skills`, `~/.claude/skills`, the project's `.claude/skills`, and the
`~/.icontext` cache that pointer-based tools read — and refreshes the one shared
`scripts/check-update.sh` every skill stub execs. Discovers every install location (copy or
symlink mode), pulls the iContext repo `--ff-only`, shows a per-location old → new table, and
re-syncs only after approval. Never commits, pushes, or forces a diverged repo.

It then updates the workspace's **dependency skills** (`skills-lock.json`, e.g. mattpocock/skills)
through the Skills CLI: `npx skills check` → confirm → `npx skills update`. Scope is the current
workspace; the CLI owns the lock file.

Run it whenever `check-update.sh` prints "update available" — instead of the manual
`git pull && ./install.sh` round-trip. It updates skill files only; a project's `CONTEXT.md`
belongs to `icontext-update`.

## One procedure, many agents
Workflow defined once in **[PROCEDURE.md](./PROCEDURE.md)**.

| Agent | Entry point |
|-------|-------------|
| Claude Code | [SKILL.md](./SKILL.md) - `/icontext-self-update` |
| Gemini CLI | [adapters/gemini.md](./adapters/gemini.md) |
| OpenAI Codex CLI | [adapters/codex.md](./adapters/codex.md) |
| Cursor | [adapters/cursor.md](./adapters/cursor.md) |
| Any other | point it at `PROCEDURE.md` |
