# icontext-implement - Claude Code adapter

Invoke `/icontext-implement [plan number or name]` in a project that already has `CONTEXT.md`,
`plans/`, and a plan at `ready to implement` (or `implement`).

1. Run `bash check-update.sh` and surface the one-line result.
2. Read `PROCEDURE.md`. Resolve the plan, check status, read the L2 context it touches.
3. Invoke the `icontext-feature-review` skill (audience `dev`, chat) and surface findings/blockers.
4. Show the slice list, then loop: per slice, `AskUserQuestion` the spawn gate (agents · scopes ·
   model/effort · order), dispatch confirmed implementers via `Task` on a cheap/low-effort model
   (haiku-class) with a self-contained brief, review the diff, run/retest per `qa.md`, owner
   review, `security-review` implement-phase sub-skills, fold feedback.
5. After coding: `unslop` skill over written artifacts; sync `docs/openapi.yaml`, `styles/`,
   `DEV.md` §7; 3-place status sync to `ready to test` when gates pass.
6. Pre-commit: `impeccable` re-check if design work, `deslop` on the diff, offer
   `thermo-nuclear-code-quality-review` (optional, every run), then §11.7 confirmation before
   any commit/push.

Never spawn an implementer without the user's confirmation for that spawn. Never commit or push
without the §11.7 per-invocation confirmation.
