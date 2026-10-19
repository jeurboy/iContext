---
name: icontext-feature-review
description: Summarize an existing feature plan (plans/NNN-name/ folder + its CR-*.md files) into one
             plain-language review document that covers BOTH the requirement view (goal, decisions,
             scope, user stories → acceptance criteria → test cases, open questions) and the technical
             view (architecture, DB/data model + migration, API contract, UI routes, security, deploy),
             then cross-checks the plan against docs/openapi.yaml, context/DEV.md §7, and plan status.
             Use whenever the user asks to "summarize / review / explain plan NNN", "สรุป plan",
             "สรุปเป็นภาษาคน", "feature review", "plan walkthrough", or needs a hand-off/briefing doc of
             a plan for stakeholders or developers. Read-only on plans and code; writes nothing unless a file is
             explicitly requested. Does not create plans (icontext-feature) or implement.
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---

# icontext-feature-review

> Run `bash check-update.sh` first and surface its one-line result. Best-effort, never blocks.

Read **[PROCEDURE.md](./PROCEDURE.md)** and execute it. The output shape is fixed by
**[templates/review-template.md](./templates/review-template.md)** — fill it, do not invent a new layout.

## Mappings
- **Input** - one plan folder `plans/NNN-<slug>/` (role files `bu/po/dev/qa/ops/stk.md` + README + any `CR-*.md`).
  Ask which plan if the user did not name one or the name is ambiguous.
- **Output** - default is a **chat summary only** (no file written). Write `plans/NNN-<slug>/REVIEW.md` only when the user explicitly asks for a file or gives a path.
- **Audience switch** - ask once: `plain` (default, non-technical stakeholder wording), `dev`
  (keeps identifiers, SQL-ish detail), or `both` (plain first, technical appendix). Language follows the user.
- **Read-only source** - never edit the plan, `plans/README.md`, `PLAN.md`, docs, or code.
- **Evidence rule** - every claim cites the file/section it came from; anything the plan does not say is
  written as "ไม่ระบุในแผน / not stated in the plan", never guessed.
- **Git** - never commit or push unless explicitly told.

## Stop rule
Finish at the written review (or chat summary). Do not fix the plan gaps you find — list them.
