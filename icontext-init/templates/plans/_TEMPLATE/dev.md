# NNN · DEV (Development) — <Feature Name>

> ref: [CONTEXT.md](../../CONTEXT.md) · index: [README.md](./README.md)
> Owns: technical design, data model, API. Align with CONTEXT.md §3–7.

## 5. Tech & Architecture · `DEV OPS`
<!-- Components, services touched (api/web/app), design decisions. -->

## 6. Data Model / Schema · `DEV OPS`
<!-- Tables/entities + relationships. Align with CONTEXT.md §7. -->

### Migration scripts · `DEV OPS`
<!-- Migrations this feature adds (keep consistent with CONTEXT.md §7 + DB). e.g.:
| File | Up (change) | Down (rollback) |
|------|-------------|-----------------|
| `NNN_create_x.sql` | <!-- ... --> | <!-- ... --> | -->

## 7. API Contract · `DEV QA`
<!-- Endpoints, request/response. SYNC to docs/openapi.yaml before `done`. -->

### API changes — added / modified · `DEV`
| Method | URL | Added/Modified | Purpose | openapi synced |
|--------|-----|----------------|---------|----------------|
| <!-- GET --> | <!-- /api/... --> | <!-- added --> | <!-- ... --> | [ ] |

### Pages / routes — added / modified · `DEV`
| URL / route | Added/Modified | Purpose | Service (web/app) |
|-------------|----------------|---------|-------------------|
| <!-- /... --> | <!-- added --> | <!-- ... --> | <!-- web --> |
