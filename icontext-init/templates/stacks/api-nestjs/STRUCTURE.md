# api/ — NestJS (alternative to Go)

Clean-architecture-flavored modular layout.

```
api/
├── src/
│   ├── modules/<feature>/          controller, service, repository, dto, entity
│   ├── common/                     guards, interceptors, filters, pipes
│   ├── config/
│   └── main.ts
├── test/                           e2e
└── package.json
```

## Recommended pieces
- ORM: **Prisma** (or TypeORM) · Validation: `class-validator`
- Tests: Jest unit + e2e. Coverage > 80%.
