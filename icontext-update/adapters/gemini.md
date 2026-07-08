# icontext-update — Gemini CLI adapter

Point Gemini at `PROCEDURE.md` in this folder. It should confirm `CONTEXT.md` exists, compare the
project with `icontext-init/templates/`, confirm every proposed file creation/patch before writing,
add only missing artifacts/sections, preserve existing content, leave TODOs where facts are unknown,
report the final gap table, and stop without implementing or committing.
