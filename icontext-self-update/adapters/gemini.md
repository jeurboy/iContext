# icontext-self-update - Gemini CLI adapter

> Read `PROCEDURE.md` in this folder and execute it: discover every installed `icontext-*` location
> (`~/.agents/skills`, `~/.claude/skills`, `./.claude/skills`, `~/.icontext`), fetch the latest
> published VERSION, locate the source repo (symlink target > `$ICONTEXT_REPO_PATH` >
> `~/.icontext/repo`), show the old → new table, and after my approval pull `--ff-only` or
> `rm -rf` + `cp -R` the skill folders. Verify the VERSIONs afterwards and tell me to restart.
> Don't commit, don't push, don't force a diverged repo, don't touch project context.

Tool mapping: questions → ask inline · file ops → shell/file tools.
