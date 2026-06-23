# db — PostgreSQL

- Runs via root `docker-compose.yml` (port {{DB_PORT}} → container 5432).
- Migrations live in `api/migrations/` and are owned by the API service.
- ORM: GORM models map to tables; keep schema changes in migrations, not ad-hoc.

## Conventions
- snake_case tables/columns; `id` PK; `created_at` / `updated_at` timestamps.
- Use foreign keys + indexes; document relationships in CONTEXT.md §5.
- Seed data (optional) under `api/seeds/`.
