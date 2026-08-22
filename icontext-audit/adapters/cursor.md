# icontext-audit - Cursor adapter

In chat, ask Cursor to read `PROCEDURE.md` and audit the existing iContext backbone. It should
compare the project against latest templates, compare context against actual repo evidence,
inspect `.icontext/hooks/`, L1/§11.7 rules, and active host wiring, identify missing/stale/unclear
items and Markdown cleanup candidates, ask for a separate decision
on every item, apply only approved updates, re-audit, report a final gap table, and stop without
implementing or executing commit/push/DB actions.
