# icontext-init — Gemini CLI adapter

Gemini has no native "skills". To run this workflow:

1. Point Gemini at the procedure:
   > Read `PROCEDURE.md` in this folder and execute every step to scaffold my project's
   > context. Confirm every CONTEXT.md section with me before writing it (a detailed interview
   > on a first-time init). If a backbone already exists, only fill the missing pieces and never
   > delete or overwrite my existing context.
2. Tool mapping:
   - Questions → just ask the user inline (no AskUserQuestion equivalent needed).
   - File checks / `git init` → shell tool.
   - File creation → write files by copying from `templates/`, substituting `{{VARS}}`.
   - Brownfield large-repo analysis → read files directly (no sub-agent); summarize.
3. Honor the rules in PROCEDURE.md: never commit/push unless told; stop at context review.

Tip: drop this repo's `templates/` next to the target project, or pass the absolute path so
Gemini can read the templates.
