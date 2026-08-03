# {{PROJECT_NAME}} — DESIGN.md (Layer 2 · design system)

> **Split out of `CONTEXT.md`.** Holds §12. Section numbers are unchanged, so every existing
> `§12` reference in plans and docs still resolves — only the file moved.
> Siblings: [CONTEXT.md](./CONTEXT.md) (architecture + workflow) · [PRODUCT.md](./PRODUCT.md) ·
> [QA.md](./QA.md) · [SECURITY.md](./SECURITY.md)

**Owners:** `DEV` + design · **Read by:** anyone touching UI (web or mobile), before writing a
single component.

---

### 12. Design Tokens & Design System

#### 12.1 Hard rules
- **Central tokens only** — `styles/css/tokens.css` is the single source of truth.
- **Never inline colors / spacing / typography / shadows** in components. No hex codes, no magic
  `px` in JSX/templates. If a value isn't in tokens, add a token first.
- Web (Tailwind config) and mobile (theme) both **mirror** these tokens — one change propagates.
- New/changed UI component ⇒ update the style guide (`styles/components/<name>.html`) **in the
  same change**, before the plan can reach `done`.

#### 12.2 Token map
<!-- TODO: fill from styles/css/tokens.css. Keep this table and the CSS file in sync. -->
| Group | Token | Value | Used for |
|-------|-------|-------|----------|
| Color | `--color-primary` | <!-- ... --> | <!-- ... --> |
| Color | `--color-surface` | <!-- ... --> | <!-- ... --> |
| Typography | `--font-sans` / scale | <!-- ... --> | <!-- ... --> |
| Spacing | `--space-*` scale | <!-- ... --> | <!-- ... --> |
| Radius | `--radius-*` | <!-- ... --> | <!-- ... --> |
| Elevation | `--shadow-*` | <!-- ... --> | <!-- ... --> |
| Motion | `--duration-*` / easing | <!-- ... --> | <!-- ... --> |

#### 12.3 Theming
<!-- TODO: light/dark strategy, how the theme is switched, which tokens flip, contrast targets. -->

#### 12.4 Component inventory
<!-- One row per component in `styles/components/`. A component not listed here doesn't exist yet —
     don't invent a one-off in a feature branch. -->
| Component | Style guide file | States covered | Used by |
|-----------|------------------|----------------|---------|
| <!-- Button --> | `styles/components/button.html` | <!-- default/hover/disabled/loading --> | <!-- web, app --> |

#### 12.5 Layout & responsive
<!-- TODO: breakpoints, grid/container widths, and the rule for each surface.
     Note per-platform intent, e.g. mobile = app-like; desktop = use the wide viewport, don't
     lock content into a narrow fixed column. Every UI change is checked at mobile AND desktop
     viewport before `done`. -->
| Breakpoint | Width | Layout intent |
|------------|-------|---------------|
| <!-- sm --> | <!-- ... --> | <!-- ... --> |

#### 12.6 Accessibility baseline
<!-- TODO: contrast ratio target, focus-visible treatment, hit-target size, keyboard nav,
     reduced-motion handling, form labelling. These are gates, not suggestions. -->

#### 12.7 Design workflow & companion skills
<!-- Every UI change (page, component, screen, flow) goes through:
     1. Design skills — e.g. `ui-ux-pro-max` + `impeccable` (see CONTEXT.md §10). If the project
        mandates them, say so here and don't start UI work before they're installed.
     2. `/plan-design-review` on any plan that has UI (CONTEXT.md §11.4).
     3. Style-guide update in the same change (12.1).
     4. Check both mobile and desktop viewports before `done`. -->

#### 12.8 Voice & content
<!-- TODO: UI copy tone, casing (sentence vs title), date/number/currency formats, i18n keys,
     error-message pattern. Inconsistent copy reads as a broken product. -->

---

## Keeping this in sync
- Any look-and-feel change ⇒ update `styles/css/tokens.css` + this file + the affected plan
  together (CONTEXT.md §11.3).
- Add a token before using a value; add a component here before shipping it.
