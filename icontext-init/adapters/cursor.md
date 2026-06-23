# icontext-init — Cursor adapter

Cursor uses rules (`.cursor/rules/*.mdc`) and chat. To run this workflow:

1. In chat:
   > Read `PROCEDURE.md` in this folder and execute it to scaffold my project's context
   > backbone. Ask me the key parameters; leave the rest as TODO. Don't commit.
2. Tool mapping:
   - Questions → ask inline in chat.
   - Detection / `git init` → terminal.
   - File creation → create from `templates/`, substituting `{{VARS}}`.
3. Optional: after scaffolding, add a Cursor rule that points at `CONTEXT.md` so every Cursor
   session loads the project context:
   ```
   ---
   description: Project context
   alwaysApply: true
   ---
   Read CONTEXT.md before doing anything. Follow its rules (tests >80%, central style tokens,
   no commit without instruction).
   ```
