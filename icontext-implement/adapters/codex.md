# icontext-implement - OpenAI Codex CLI adapter

Follow `PROCEDURE.md`: pick one `plans/NNN-<slug>/` plan at `ready to implement` (or resuming
`implement`), summarize it with `icontext-feature-review` (or manually in its shape), slice the
§10 tasks + pending CR tasks, then run the §11.5 loop per slice. If the runtime supports
sub-agents, dispatch confirmed cheap-model implementers with self-contained briefs — the user
confirms every spawn (count · scope · model) before it happens; otherwise implement each brief
directly. Test per `qa.md`, retest after every change, run the `security-review` implement-phase
sub-skills, fold feedback. After coding: `/unslop` on written artifacts, sync `docs/openapi.yaml`
+ `styles/` + `DEV.md` §7, advance status to `ready to test` in all three places. Pre-commit:
`/impeccable` re-check (if design work) → `/deslop` → optional
`/thermo-nuclear-code-quality-review` (ask every time) → §11.7 confirmation. Never commit or
push without it.
