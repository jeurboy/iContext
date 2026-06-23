# app/ — Flutter, feature-first clean structure

```
app/
├── lib/
│   ├── core/                       config, theme (tokens), network, error, di
│   ├── features/
│   │   └── <feature>/
│   │       ├── data/               models, datasources, repository impl
│   │       ├── domain/             entities, repository interfaces, usecases
│   │       └── presentation/       pages, widgets, state (controllers/blocs)
│   └── shared/                     shared widgets/utils
├── test/                           unit + widget tests
├── integration_test/               flutter integration tests
└── pubspec.yaml
```

## Recommended stack (beyond Flutter core)
- State management: **Riverpod** (or Bloc)
- HTTP: **Dio** + **Retrofit** (typed client) · JSON: `json_serializable`
- Routing: **go_router** · DI: `get_it` / Riverpod providers
- Local cache: `shared_preferences` / `hive`
- Tests: unit + widget + integration. Mirror coverage > 80% intent.

## Rules
- Theme/colors come from `core/theme` tokens — no scattered hardcoded colors.
