# icontext-init — Claude Code adapter

Claude Code is the **native** entry point: the skill ships `SKILL.md` and Claude loads it via the
`/icontext-init` slash command. This file just documents the mapping for parity with the other
adapters — you normally don't need to read it; Claude reads `SKILL.md` → `PROCEDURE.md` directly.

1. Invoke:
   > `/icontext-init` — or just ask Claude to scaffold/maintain the project context backbone.
2. Tool mapping (see `SKILL.md` for the canonical list):
   - **Update check (FIRST, every run)** → `bash check-update.sh` via `Bash`; surface its output
     (local **version** + update availability).
   - **Mode detection / `git init`** → `Bash` file-presence checks. Detect an existing iContext
     backbone first → **update/sync** (fill gaps only).
   - **Per-section confirm** → `AskUserQuestion` (first-time init = detailed interview; update/sync
     = light, gaps only).
   - **Brownfield inventory** → dispatch the `Explore` agent (read-only fan-out) for large repos,
     then synthesize into `CONTEXT.md`.
   - **File creation** → `Write`/`Edit`, copying from `templates/` and substituting `{{VARS}}`.
3. Honor the hard rules in `PROCEDURE.md`: **non-destructive** (never delete/overwrite existing
   context — only add the missing pieces); never `git commit`/`git push` unless told; stop at
   context review (do not create feature plans — that's `icontext-feature`).
