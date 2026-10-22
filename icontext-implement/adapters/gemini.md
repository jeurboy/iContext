# icontext-implement - Gemini CLI adapter

> Read `PROCEDURE.md` in this folder and execute it: resolve one `ready to implement` plan,
> summarize it via `icontext-feature-review` (or manually), slice the §10 + CR tasks, and run
> the §11.5 loop. Dispatch implementer sub-agents on the cheapest capable model only after I
> confirm each spawn (count · scope · model) — every time, including retries; without sub-agent
> support, implement each brief directly. Test concretely per `qa.md` and retest after every
> change; run the `security-review` implement-phase sub-skills per slice. After coding run
> `/unslop` on written artifacts, sync `docs/openapi.yaml` + `styles/` + `DEV.md` §7, and set
> `ready to test` in all three status places. Pre-commit: `/impeccable` re-check if design work,
> `/deslop` the diff, offer `/thermo-nuclear-code-quality-review` (optional, ask every time),
> then wait for my §11.7 confirmation before any commit or push.

Tool mapping: questions → ask inline · file ops → shell/file tools · sub-agents → agent runner
when available, else direct implementation.
