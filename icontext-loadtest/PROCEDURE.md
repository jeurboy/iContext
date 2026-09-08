# icontext-loadtest — procedure (agent-neutral)

Create or refresh one page-specific k6 load-test package in an existing iContext project. The page
and its real request fan-out are the unit of design; generic endpoint guessing produces misleading
capacity numbers.

## Operating rules

- Ask for the target page/screen/route on every invocation, even when an existing load test is found.
- Inspect facts from the repository; ask the owner only for decisions or unavailable environment facts.
- Preserve existing owner-authored scripts and configs. Show proposed replacements before overwriting.
- Never copy credentials, real account files, result artifacts, environment-specific URLs, or DB dumps.
- Never execute a load test by default. Script generation and offline syntax checks are not execution
  approval.
- Never target production or a staging deployment that shares production data/services. A read-only
  journey can still consume production capacity, and login commonly writes refresh/session tokens.
- Keep request rate, journeys per time unit, VU concurrency, and in-flight HTTP concurrency as
  distinct concepts in docs and configuration.
- Default to GET-only. Every POST, PUT, PATCH, DELETE, or other non-GET endpoint requires a fresh
  owner decision on every invocation; list method, route, purpose, and expected write/side effect.

## Step 0 — Update check

Run `check-update.sh` next to this file and surface its one-line result. Continue if the check cannot
reach upstream.

## Step 1 — Ask for the page every time

Before reading existing load-test scripts or proposing a workload, ask one required question:

> Which page, screen, route, or user journey should this invocation load-test?

Capture the visible name and canonical client route. If the answer is ambiguous, ask which platform
(web/mobile/admin/API consumer) because pages with the same name may have different request fan-out.
Do not silently default to Home, Dashboard, or a previously tested page.

Then determine the invocation mode:

- **Create/refresh** — trace the page and generate or update the load-test package.
- **Interpret result** — use the result path already supplied by the owner, or ask for the JSON,
  HTML, or result-directory path if it was not supplied. Result interpretation is read-only and must
  never trigger a new k6 run.

## Step 2 — Read project context and trace the real journey

Require an existing iContext backbone. Read `CONTEXT.md` and, when present, the `context/`
siblings `context/DEV.md`, `context/QA.md`, `context/SECURITY.md`, and
`context/SKILLS.md` (on a pre-1.17 project these files may sit at the repo root — read them where
they are). Inspect the selected client route and every mounted provider/layout/component
that can issue requests.

Build an endpoint register containing:

| Field | Meaning |
|-------|---------|
| method + route | Stable report label, without volatile IDs/query values |
| trigger | initial mount, focus, cache stale, user action, polling, or background task |
| concurrency | serial, parallel batch, conditional, or deduplicated |
| auth | anonymous, login, access token, refresh path, role |
| side effect | explicit write and hidden write discovered in handler/usecase/middleware |
| dependency | DB, cache, object storage, queue, external API/AI |

Trace through the API implementation when available. A GET that updates activity, progress, cache,
preferences, usage logs, or generated content is not read-only. Separate or exclude it unless the
owner approves that write in an isolated environment.

Classify all non-GET endpoints into a separate approval list. Do not place them into an active
scenario until the owner approves each listed method/route in the current invocation. Login is not
an implicit exception: ask before including `POST /login` and explain token/session writes.

## Step 3 — Confirm workload decisions

Ask decisions one at a time when they are not already explicit:

1. Use GET-only with prepared access tokens/anonymous access, or approve each required non-GET route
   such as login for this invocation?
2. Cold cache, warm cache, focus refresh, or another lifecycle?
3. Which conditional requests and side effects are included?
4. Expected population/window and whether traffic is flat, peaked, ramped, burst, or sustained?
5. Maximum journey rate, VUs, batch concurrency, and in-flight request ceiling?
6. Target environment and proof that its data/services are isolated from production?
7. Generate only (default) or request a separately approved execution gate?

If the target is unsafe or shared with production, still generate the package but mark execution
blocked. Never weaken a guard just to make the script run.

## Step 4 — Generate from the bundled templates

Use every reusable file in `templates/load-tests/` as the starting package, excluding anything not
present there. The bundled folder intentionally contains no real `.env`, account file, result, URL,
password, token, or customer data.

Default destination: `<project>/load-tests/`. Before writing, show the exact file list and ask if any
existing file would be replaced. Adapt the starter rather than leaving example-specific names:

- Rename `load-test.js` to `<page-slug>.js` and `run-load-test.sh` to `run-<page-slug>.sh`; update
  all internal references and replace every mock/placeholder before delivery.
- Replace the endpoint registry with the traced routes and define the selected journey in
  `ENDPOINT_SCENARIOS` from one source of truth.
- Replace product/page labels and placeholder hosts. Keep real secrets outside the repository.
- Keep named load profiles separate from endpoint scenarios.
- Keep `JOURNEYS_PER_TIME_UNIT` paired with `JOURNEY_TIME_UNIT`; do not use a misleading
  `JOURNEYS_PER_SECOND` variable for non-second windows.
- Keep route-aligned `rt_*`, `req_*`, and `res_*` metrics plus exact `METHOD /route` tags.
- Keep the combined HTML report, dashboard export, JSON summary, optional time-series output, and
  result template.
- Keep safety checks for allowed/blocked host, isolated DB, read-only mode, process watchdog, VU/batch
  limits, `MAX_IN_FLIGHT_REQUESTS`, and `ALLOW_NON_GET=false` by default.
- When non-GET routes are approved, document the current-invocation decision and require the operator
  to set `ALLOW_NON_GET=true`; this runtime flag is a second guard, not a substitute for asking.
- For an authenticated GET-only flow, set scenario `auth` to `null` and use prepared short-lived test
  access tokens from the protected account file/secret source. Never commit those tokens.
- If non-GET authentication is approved, replace the template's fail-closed auth placeholder with the
  target API's real request/response contract; never carry an example login body into another project.

## Step 5 — Document the human meaning

For every named profile, document in plain language:

- how many users/journeys begin per time window;
- how many API calls one journey makes;
- expected aggregate requests and approximate RPS;
- VU behavior and maximum in-flight HTTP ceiling;
- duration, graceful stop, watchdog, and expected report files;
- whether the profile represents real traffic, compressed volume, ramp, concurrent burst, stress,
  or soak behavior.

Do not call a result “capacity” without the tested infrastructure profile, zero dropped iterations,
the agreed latency/error SLOs, and evidence from the real API/DB boundary.

## Step 6 — Validate offline

Run only non-traffic validation unless execution is separately approved:

- `bash -n` for shell files;
- JavaScript syntax checks that do not execute k6 requests;
- JSON parse checks for example account/config data;
- confirm no real secrets, result files, or mutable endpoint slipped into templates;
- confirm scenarios are GET-only unless the current invocation records explicit approval for every
  non-GET method/route and the generated env example still defaults `ALLOW_NON_GET=false`;
- confirm every endpoint is defined once and each scenario references registry entries;
- confirm request/response/time metrics share the same route suffix;
- confirm docs and commands use the generated filenames.

Report what was not verified: target connectivity, credentials, runtime response, DB effects,
dashboard generation, capacity, and deployment metrics.

## Step 7 — Execution gate

If the owner later asks to run, require a fresh instruction naming the exact target and profile.
Reconfirm isolation, approved time window, abort operator, maximum rate/concurrency, observability,
and before/after data checks. Approval for smoke does not authorise ramp, stress, soak, a different
environment, service startup, migration, fixture creation, or DB access.

## Step 7.5 — Interpret a user-provided result path

When the owner asks to summarize results, read
`references/result-summary.md` and follow its wording/analysis structure. Accept:

- a k6 summary JSON file;
- a combined/dashboard HTML report;
- a result directory containing JSON, HTML, and a sanitized environment snapshot.

Use the supplied path exactly; do not scan unrelated result directories. Prefer JSON for numbers,
combined HTML for the recorded profile/flow, and a sanitized env snapshot for intended load settings.
Never treat a filename such as `smoke.json` as proof of the selected profile; verify metadata or say
the profile is unknown.

Calculate and explain:

- intended versus completed journeys and achieved journeys/time unit;
- total HTTP requests, aggregate RPS, and final-response request/response counts;
- HTTP/network failures, failed checks, dropped and interrupted iterations;
- VU allocation/peak and whether insufficient VUs limited offered load;
- journey/login/route avg, p50, p95, p99, max, and SLO verdict;
- whether waiting/server time dominates connection/TLS time;
- slowest routes and evidence-backed bottleneck hypotheses;
- infrastructure profile and whether the run is valid for capacity acceptance.

If a comparison path is supplied, show absolute and percentage changes. Never infer causation from
one changed infrastructure variable unless the runs used the same script, workload, data, target,
duration, and observability boundary.

## Step 8 — Report and stop

List generated/changed files, selected page and endpoint count, available profiles, safety blockers,
offline validation evidence, and the execution status (`not authorised`, `blocked`, or separately
approved). For result interpretation, provide the plain-language verdict and cite the exact supplied
path. Stop without running k6 by default.
