# icontext-feature — Claude Code adapter

Claude Code is the **native** entry point: the skill ships `SKILL.md` and Claude loads it via the
`/icontext-feature` slash command. This file documents the mapping for parity with the other
adapters — Claude normally reads `SKILL.md` → `PROCEDURE.md` directly.

1. Invoke: `/icontext-feature` (run it *after* `icontext-init`, in a project that already has
   `CONTEXT.md`, `plans/`, `PLAN.md`, `ROLE.md`).
2. Tool mapping:
   - **Update check (FIRST, every run)** → `bash check-update.sh` via `Bash`; surface its output
     (local **version** + update availability).
   - **Next plan number / CR routing** → `Bash` to list `plans/NNN-*/` and compute `NNN`; if the
     feature already has a plan, route to CR mode instead — next `CR-<M>` from `CR-*.md` in that
     folder (PROCEDURE.md Step 2).
   - **Feature brief + optional persona prompt** → `AskUserQuestion`.
   - **Requirement workflow** → gather the minimal brief, ask the user to choose `/grill-with-docs`
     or `/wayfinder`, run the selected route, then use `context/ROLE.md` as a multi-agent requirement review
     panel before writing final plan content. Recommend `/wayfinder` for large, foggy requirements
     without a clear solution path.
   - **Write plan** → copy `templates/plan-template/` to `plans/NNN-<slug>/` (role files
     bu/po/dev/qa/ops/stk.md + README.md) with `Write`, fill sections, set `Task status: plan`, ref
     `CONTEXT.md`; register status in `plans/README.md` + `PLAN.md`. **CR mode** (existing feature
     with a plan) → write `plans/NNN-<slug>/CR-<M>.md` from `templates/cr-template.md` instead —
     single delta file linking back to the original plan; register in the plan folder README CR
     table + `plans/README.md` + `PLAN.md`.
   - **Plan preparation** → run gstack `/autoplan` (or the individual review chain) and apply
     accepted changes before implementation.
3. Honor the rules in `PROCEDURE.md`: never `git commit`/`git push` unless told; stop at the
   written plan or CR (do not implement the feature).
