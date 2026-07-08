# icontext-init — OpenAI Codex CLI adapter

Codex CLI reads `AGENTS.md` and runs shell/file ops. To run this workflow:

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
3. Codex auto-reads `AGENTS.md`: the scaffold output includes one at the project root (alongside
   the vendor-neutral `AGENT.md`), so once created, Codex picks up the project rules automatically.
