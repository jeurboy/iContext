# {{PROJECT_NAME}} — DEV.md (Layer 2 · development & architecture)

> **Owners:** `DEV OPS` · Sections: §3–7
> Read [CONTEXT.md](./CONTEXT.md) first for the full context map and workflow.
> Siblings: [PRODUCT.md](./PRODUCT.md) · [QA.md](./QA.md) ·
> [SECURITY.md](./SECURITY.md) · [DESIGN.md](./DESIGN.md)

## สถาปัตยกรรม · Architecture

### 3. สถาปัตยกรรมระบบ · System Architecture
<!-- TODO: diagram / data flow -->
- `web/` ({{WEB_STACK}}) → `api/` ({{API_STACK}}) → `db` ({{DB_STACK}})
- `app/` ({{MOBILE_STACK}}) → `api/`

### 4. Tech Stack
| Layer | Choice | Notes |
|-------|--------|-------|
| Web | {{WEB_STACK}} | React Query · Tailwind · Playwright |
| Mobile | {{MOBILE_STACK}} | state + Dio + feature-first (app/STRUCTURE.md) |
| API | {{API_STACK}} | Clean Architecture · ORM-first, minimal raw SQL |
| DB | {{DB_STACK}} | docker-compose · migrations |

### 5. โครงสร้าง Repo · Repo Structure
- Mono-root with each service as its **own git repo wired as a submodule**: `api/`, `web/`, `app/`.
- Context backbone lives at the root:
  - **L1 agent files** — `CLAUDE.md` / `AGENTS.md` / `AGENT.md` / `GEMINI.md`
  - **L2 context (6 files, split by concern)** — `CONTEXT.md` (context map + workflow) ·
    `DEV.md` (this file: development + architecture) · `PRODUCT.md` · `QA.md` · `SECURITY.md` ·
    `DESIGN.md` — see the context map in `CONTEXT.md`
  - **L3 + shared** — `ROLE.md`, `PLAN.md`, `plans/`, `styles/`, `docs/`

### 6. รายการ Service · Services
| Service | Stack | Port | STRUCTURE |
|---------|-------|------|-----------|
| api | {{API_STACK}} | {{API_PORT}} | api/STRUCTURE.md |
| web | {{WEB_STACK}} | {{WEB_PORT}} | web/STRUCTURE.md |
| app | {{MOBILE_STACK}} | — | app/STRUCTURE.md |
| db | {{DB_STACK}} | {{DB_PORT}} | docker-compose.yml |

### 7. Data Model
> Single source of truth for entities. Keep in sync with the plan's schema section + DB migrations
> (CONTEXT.md §11.3). Update this whenever the data model changes.

**Entities**
| Entity | Key fields | Description |
|--------|-----------|-------------|
| <!-- e.g. User --> | id, ... | <!-- TODO --> |

**Relationships**
<!-- TODO: e.g. User 1—N Order; Order N—N Product (via OrderItem). One model can have many physical units. -->

**ERD / notes**
<!-- TODO: link or embed a diagram; note enums, indexes, soft-delete, audit fields -->

---
## Keeping this in sync
- Architecture, stack, repo, service, or data-model changes belong here; keep the affected plan,
  `docs/openapi.yaml`, service `STRUCTURE.md`, and DB migrations aligned in the same change
  ([CONTEXT.md](./CONTEXT.md) §11.3).
- If a technical decision changes product scope, security, testing, or design, update the matching
  L2 sibling in the same change. Link across files; never duplicate a section.
