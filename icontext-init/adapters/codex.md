# icontext-init — OpenAI Codex CLI adapter

Codex CLI reads `AGENTS.md` and runs shell/file ops. To run this workflow:

1. Prompt:
   > Follow the steps in `PROCEDURE.md` (in this skill folder) to scaffold a context backbone
   > for my project. Hybrid input: ask the key params, placeholder the rest. Do not commit.
2. Tool mapping:
   - Questions → ask inline.
   - Detection / `git init` → shell.
   - File creation → write from `templates/`, substituting `{{VARS}}`.
   - Brownfield → read manifests + source, summarize into `CONTEXT.md`.
3. Codex auto-reads `AGENTS.md`: the scaffold output includes one at the project root, so once
   created, Codex picks up the project rules automatically.
