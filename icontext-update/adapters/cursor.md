# icontext-update — Cursor adapter

In chat, ask Cursor to read `PROCEDURE.md` and update the existing iContext backbone to the latest
template shape. It should inventory gaps, confirm every proposed file creation/patch before
writing, add only missing files/sections, preserve existing content, leave TODOs for unknown facts,
report a gap table, and stop without implementing or committing.
