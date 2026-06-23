# api/ — Go + GORM, Clean Architecture (Uncle Bob)

Recommended layout. Dependencies point inward: delivery → usecase → domain; repository
implements domain interfaces. Use GORM; keep raw SQL to a minimum.

```
api/
├── cmd/
│   └── server/main.go              composition root (wire deps, start http)
├── internal/
│   ├── domain/                     entities + repository INTERFACES (no framework imports)
│   │   ├── entity/
│   │   └── repository/             interfaces only
│   ├── usecase/                    business rules (depends on domain only)
│   ├── repository/                 GORM implementations of domain interfaces
│   ├── delivery/http/              handlers, routes, DTOs, middleware (Echo or Gin)
│   └── infrastructure/             db connection, config, logger
├── pkg/                            shared helpers safe to import anywhere
├── migrations/                     SQL migrations
├── go.mod
└── Dockerfile
```

## Recommended pieces
- Router: **Echo** (or Gin) · ORM: **GORM** · Config: env + `viper` (optional)
- Tests: table-driven unit tests on usecases + repositories (sqlmock / test DB).
  **Coverage > 80%.** `go test ./... -cover`.

## Rules
- `domain/` imports nothing framework-specific.
- Prefer GORM query builder over raw SQL; document any raw query and why.
