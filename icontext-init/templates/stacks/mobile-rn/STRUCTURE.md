# app/ — React Native (Expo) (alternative to Flutter)

```
app/
├── src/
│   ├── features/<feature>/         screens, components, hooks (React Query)
│   ├── navigation/                 React Navigation stacks/tabs
│   ├── lib/                        api client, query client
│   └── theme/                      design tokens (no inline colors)
├── app.json
└── package.json
```

## Recommended pieces
- Data: **@tanstack/react-query** · Nav: **React Navigation** · State: Zustand (optional)
- Tests: Jest + React Native Testing Library; Maestro/Detox for e2e. Coverage > 80%.
