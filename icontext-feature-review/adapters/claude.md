# icontext-feature-review - Claude Code adapter

Invoke `/icontext-feature-review [plan number or name]` in a project that already has `CONTEXT.md` and `plans/`.

1. Run `bash check-update.sh` and surface the one-line result.
2. Read `PROCEDURE.md` and `templates/review-template.md`.
3. Resolve the plan, ask audience (plain/dev/both) and output (file/chat) with `AskUserQuestion`.
4. Read the plan folder + cross-check targets, fill the template, run the Step 4 checks.
5. Write `plans/NNN-<slug>/REVIEW.md`, verify no placeholders remain, report verdict + top gaps.
Read-only otherwise: do not edit the plan, implement, commit, or push.
