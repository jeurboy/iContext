# web/ — Next.js (App Router) + React Query + Tailwind

Feature-folder structure. Data fetching via React Query; styling via Tailwind with tokens
mirrored from the root `styles/css/tokens.css`.

```
web/
├── src/
│   ├── app/                        App Router (routes, layouts, server components)
│   ├── components/                 shared/presentational components
│   ├── features/                   feature-first modules
│   │   └── <feature>/
│   │       ├── api/                React Query hooks (queries/mutations)
│   │       ├── components/
│   │       └── types.ts
│   ├── lib/                        api client, query client setup, utils
│   ├── hooks/                      shared hooks
│   └── styles/                     globals.css, tailwind layer (import root tokens)
├── tests/e2e/                      Playwright specs
├── tailwind.config.ts
├── package.json
└── Dockerfile
```

## Recommended pieces
- Data: **@tanstack/react-query** · Styling: **Tailwind** (no inline colors — map tokens)
- Tests: **Playwright** for UI/e2e. **Coverage > 80%** on critical flows.

## Rules
- Colors/spacing come from design tokens; do not hardcode hex in components.
