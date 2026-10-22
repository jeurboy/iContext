# icontext-self-update - Claude Code adapter

Invoke `/icontext-self-update` when `check-update.sh` reports an update, or the user asks to update
the icontext skills to the latest version.

1. Run `bash check-update.sh` and surface the one-line result.
2. Read `PROCEDURE.md` and execute Steps 1–4: discover install locations, fetch the latest
   version, locate the source repo, and build the old → new table.
3. Get approval for the exact change set with `AskUserQuestion` before touching anything.
4. Apply (Step 5): ff-only pull for link mode, `rm -rf` + `cp -R` per skill for copy mode, then
   refresh the `~/.icontext` cache.
5. Verify (Step 6): re-read every `VERSION`, report the final table, remind to restart Claude Code.
Never commit, push, or force a diverged repo; never touch a project's `CONTEXT.md`.
