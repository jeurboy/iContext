# icontext-audit - Gemini CLI adapter

Point Gemini at `PROCEDURE.md` in this folder. It should confirm `CONTEXT.md` exists, compare the
project with latest iContext templates, compare context against actual repo evidence, identify
missing/stale/unclear items and Markdown cleanup candidates, ask the user for every decision before
editing or cleanup, apply only approved updates, re-audit, report the final table, and stop without
implementing or committing.
