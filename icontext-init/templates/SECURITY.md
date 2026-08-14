# {{PROJECT_NAME}} — SECURITY.md (Layer 2 · security model & review wiring)

> **Split out of `CONTEXT.md`.** Holds §8 (security model) and §11.6 (`security-review` lifecycle
> wiring). Section numbers are unchanged, so every existing `§8` / `§11.6` reference in plans and
> docs still resolves — only the file moved.
> Siblings: [CONTEXT.md](./CONTEXT.md) (context map + workflow) · [DEV.md](./DEV.md) (development) · [PRODUCT.md](./PRODUCT.md) ·
> [DESIGN.md](./DESIGN.md) · [QA.md](./QA.md)

**Owners:** `DEV QA OPS` · **Read by:** anyone adding a route, page, dependency, or secret.

---

### 8. Security Model

#### 8.1 Authentication
<!-- TODO: auth methods (password / SSO / OTP), session model, token types + TTL, refresh/rotation,
     lockout policy, where the session lives. -->

#### 8.2 Authorization (roles & permissions)
<!-- TODO: the role list and how permission checks are enforced.
     Recommended: **deny-by-default** — a route/page with no explicit permission is denied, not
     allowed. Name the middleware/guard and the permission catalog file so plans can reference it. -->

| Role | Can do | Cannot do |
|------|--------|-----------|
| <!-- admin --> | <!-- ... --> | <!-- ... --> |

**Permissions matrix rule:** every plan that adds an API route or a page **must** carry a
Permissions matrix (route/page → permission, or an explicit `public` / `self-scope` with the
reason) in its `ops.md` §8. Public exceptions are listed here, nowhere else:
<!-- TODO: e.g. healthz, auth.login, auth.refresh, auth.logout -->

#### 8.3 Data protection & privacy
<!-- TODO: PII inventory (which entities/fields), encryption at rest/in transit, retention +
     deletion policy, what may appear in logs (and what must never), audit trail. -->

#### 8.4 Secrets handling
<!-- TODO: where secrets live (env / vault / CI), what is NEVER stored in the DB or a repo,
     rotation procedure, who can read them, what happens on config change (restart? hot reload?). -->

#### 8.5 Threats & accepted risks
<!-- TODO: known threats and the mitigation. Accepted risks get an explicit decision here with
     the reason and who accepted it — an unwritten accepted risk is an unowned one. -->

---

### 11.6 Security review — `security-review` wired into the lifecycle

The `security-review` skill (CONTEXT.md §10, https://github.com/ice-limited/security-skill) is a
**dependency skill**, not an optional extra. It invokes real static-analysis detectors and reports
their own structured findings (Problem / Impact / Recommendation / Reference / severity /
confidence). If a detector's prerequisite tool isn't installed, say so and relay the install
command — **never substitute an LLM opinion for a detector that didn't run.**

| Phase | Sub-skills to run | When | Recorded in |
|-------|-------------------|------|-------------|
| **Plan** (before `ready to implement`) | **supply-chain** | after the CONTEXT.md §11.4 review chain, on the plan's proposed dependencies / build / release surface | `ops.md` §8 |
| **Implement** (each slice, CONTEXT.md §11.5 step 5.5) | **secret** · **code-review** · **auth** · **dependency** · **docker** | on the files the slice touched, before the slice leaves the loop | `ops.md` §8 + `qa.md` |

Scope per slice — run only what the slice touched:
- **secret** — always (any diff can leak a credential).
- **code-review** — always (injection / SSRF / unsafe patterns in changed source).
- **auth** — when authn/authz, sessions, tokens, roles, or permission checks change.
- **dependency** — when a manifest or lockfile changes.
- **docker** — when a `Dockerfile`, compose file, or image base changes.

Other detectors the skill ships (**api · iac · kubernetes · cicd-pipeline · race-condition**) are
not wired into the default lifecycle — run them ad hoc when a plan touches those surfaces.

**Gate:** a plan reaches `done` only with no unresolved high/critical finding; anything accepted is
written down as an explicit decision in the plan's `ops.md` §8 with the reason, and mirrored into
§8.5 above if it is a standing risk rather than a one-off.

---

## Keeping this in sync
- New route/page ⇒ permission decided here (§8.2) **before** it is built, and recorded in the
  plan's Permissions matrix.
- Security-relevant test cases (permission-denied, deny-by-default per role) are mandatory Edge
  scenarios — see [QA.md](./QA.md) §9.
- A change to the auth model ⇒ update §8 here + the affected plan's `ops.md` in the same change
  (CONTEXT.md §11.3).
