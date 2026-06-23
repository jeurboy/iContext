# {{PROJECT_NAME}} — CONTEXT.md (Layer 2 · single source of truth)

> Architecture §1–13. **Read this before anything.** Every plan in `plans/` must `ref` this file.
> Companion indexes: `PLAN.md` (status dashboard) · `plans/README.md` (plan index) · `ROLE.md` (persona panel).

---
## ผลิตภัณฑ์ & ทิศทาง · Product & Direction

### 1. ภาพรวมผลิตภัณฑ์ · Product Overview
- **What:** {{PROJECT_DESC}}
- **Platforms:** {{PLATFORMS}}
- **Reference:** {{REFERENCE}}
- **Status:** scaffolded — features not yet implemented
<!-- TODO: target users, value proposition -->

### 2. Key Decisions
<!-- Log decisions: date · decision · why · alternatives rejected. -->
- {{DATE}} — Stack chosen: web {{WEB_STACK}}, mobile {{MOBILE_STACK}}, api {{API_STACK}}, db {{DB_STACK}}.

---
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
- Context backbone (this file, `CLAUDE.md`/`AGENT.md`/`GEMINI.md`, `ROLE.md`, `plans/`, `styles/`,
  `docs/`, `PLAN.md`) lives at the root.

### 6. รายการ Service · Services
| Service | Stack | Port | STRUCTURE |
|---------|-------|------|-----------|
| api | {{API_STACK}} | {{API_PORT}} | api/STRUCTURE.md |
| web | {{WEB_STACK}} | {{WEB_PORT}} | web/STRUCTURE.md |
| app | {{MOBILE_STACK}} | — | app/STRUCTURE.md |
| db | {{DB_STACK}} | {{DB_PORT}} | docker-compose.yml |

### 7. Data Model
<!-- TODO: entities + relationships. (Brief rule: one model can have many physical units.) -->

---
## คุณภาพ & ความปลอดภัย · Quality & Security

### 8. Security Model
<!-- TODO: authn/authz, roles (e.g. admin vs customer), data protection, secrets handling -->

### 9. Testing & Quality Gates
- Unit tests on API + Playwright UI tests. **Coverage > 80%** (hard gate).
- A plan reaches `done` only when: API spec synced · User Stories complete · tests > 80%.

### 10. Skills ที่ใช้ · Skills Used
- `gstack` · `ux-ui-pro-max` · `impeccable` (design/QA companions)
- `icontext-init` (scaffold) · `icontext-feature` (plans)

---
## กระบวนการ & ดีไซน์ · Process & Design

### 11. Workflow + Plan Standard
- Build context first → then features one at a time via `/icontext-feature`. Never commit/push unless told.

#### 11.1 Plan structure (every plan is a **folder** `plans/NNN-<name>/` split by role; sections 0–11)
Roles: **BU** ธุรกิจ · **PO** เจ้าของงาน · **DEV** พัฒนา · **QA** ทดสอบ · **OPS** DevOps/Deploy · **STK** Stakeholder.
Each section lives in exactly one role file:

| # | Section | Owner | File |
|---|---------|-------|------|
| 0 | Decisions | STK BU PO | bu.md |
| 1 | Goal | STK BU PO | bu.md |
| 2 | Scope (in/out) | PO DEV | po.md |
| 3 | User Stories (mandatory) | PO QA | po.md |
| 4 | Persona Panel | STK BU PO DEV | stk.md |
| 5 | Tech & Architecture | DEV OPS | dev.md |
| 6 | Data Model / Schema | DEV OPS | dev.md |
| 7 | API Contract | DEV QA | dev.md |
| 8 | Security & Privacy | DEV QA OPS | ops.md |
| 9 | Test Plan (>80%) | QA DEV OPS | qa.md |
| 10 | Tasks / Checklist | DEV PO OPS | po.md |
| 11 | Open Questions | PO BU STK | po.md |

The folder also has `README.md` (index + canonical Status). Template: `plans/_TEMPLATE/`.
Status lifecycle: `todo → implement → ready to test → done`

#### 11.2 Rules for every plan
- **ref CONTEXT.md** always.
- **Update status in 3 places in one go:** the plan's `README.md` · `plans/README.md` · `PLAN.md`.
- **sync API spec** (`docs/openapi.yaml`) before `done`.
- **User Stories complete** before `done`.
- **test > 80%** before `done`.

### 12. Design Tokens
- Central tokens in `styles/css/tokens.css`. **Never inline colors / look-and-feel.** Web (Tailwind)
  and mobile (theme) mirror these tokens.

### 13. Open Questions
<!-- TODO: collect unknowns here -->
