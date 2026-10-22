# icontext-self-update - OpenAI Codex CLI adapter

Follow `PROCEDURE.md`: discover the installed `icontext-*` locations, fetch the latest published
version, pick the source repo (symlink target > `$ICONTEXT_REPO_PATH` > `~/.icontext/repo`),
confirm the old → new table, then apply — `git pull --ff-only` for linked installs, folder replace
for copies, plus a `~/.icontext` cache refresh. Re-read every `VERSION` and report; remind the
user to restart. Never commit, push, force a diverged repo, or touch project context.
