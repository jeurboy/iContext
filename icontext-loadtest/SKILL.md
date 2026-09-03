---
name: icontext-loadtest
description: Create, refresh, or interpret a page-specific k6 load-test package for an existing iContext project. Use whenever the user asks for load testing, capacity, throughput, RPS/TPS, concurrent users, ramp-up, stress, soak, performance scripts, or asks to summarize a k6 result file/path. Ask which page, screen, or route to test at the start of every invocation; inspect the real client/API fan-out and hidden writes; generate guarded scripts/profiles/reports or summarize user-provided results in plain language; never execute load traffic without separate explicit approval naming the target environment.
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - AskUserQuestion
---

# icontext-loadtest

> Run `bash check-update.sh` first and surface its one-line result. The check is best-effort and does
> not block when offline or unpublished.

> On every invocation, ask which page, screen, user journey, or route the owner wants to test before
> generating or changing scripts. Do not reuse the page selected in a prior invocation without asking.

Read [PROCEDURE.md](./PROCEDURE.md) completely and follow it. Reusable starter files live under
`templates/load-tests/`. When interpreting results, also read
[references/result-summary.md](./references/result-summary.md).

## Safety boundary

- Generate and validate offline by default; do not run k6 automatically.
- A staging hostname is not safe when it shares production services or a production database.
- Login and GET routes may still write tokens, activity timestamps, caches, or generated content;
  inspect implementation rather than assuming HTTP method semantics.
- Generate and execute GET-only workloads by default. If the journey needs POST, PUT, PATCH, DELETE,
  or another non-GET method, ask the owner for explicit approval on every invocation and name each
  method/route plus its side effect. Never reuse approval from a prior invocation.
- Running k6, starting/restarting services, applying migrations, seeding, querying a DB, or creating
  fixtures needs a new explicit approval for the exact environment and command.

## Stop rule

Stop after the generated package and offline validation unless the owner separately authorises an
execution gate. Never infer permission to run from permission to create the script.
