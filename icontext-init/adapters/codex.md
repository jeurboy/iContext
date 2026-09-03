# icontext-init — OpenAI Codex CLI adapter

Codex CLI conventionally reads `AGENTS.md`; iContext also accepts lowercase `agents.md` for other
tools. Agent auto-discovery remains vendor-specific. To run this workflow:

1. Prompt:
   > Follow the steps in `PROCEDURE.md` (in this skill folder) to scaffold a context backbone
   > for my project. Confirm every CONTEXT.md section with me before writing it (deep interview
   > on first-time init). If a backbone already exists, only fill the missing pieces and never
   > delete or overwrite my existing context. Do not commit.
2. Tool mapping:
   - Update check → run `check-update.sh` next to this procedure and surface the one-line result.
   - Questions → ask inline (per-section confirm; first-time init = detailed interview).
   - Detection / `git init` → shell. Detect an existing iContext backbone first → update/sync.
   - File creation → write from `templates/`, substituting `{{VARS}}`. Never overwrite existing files.
   - Brownfield → read manifests + source, summarize into `CONTEXT.md`.
   - Safety hook → create `.icontext/hooks/`; if the active Codex host exposes a documented
     interactive project hook, merge and verify it. Otherwise report instruction-only enforcement.
3. For Codex, prefer uppercase `AGENTS.md`. For another tool, preserve its selected
   `agents.md`/`agent.md` casing. iContext generates one alias from each pair, never both.
   Those rules require fresh confirmation for every commit, push, DB command, migration, or seed.
