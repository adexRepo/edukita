---
name: flutter-implementation
description: Implement or modify Edukita Flutter features, screens, widgets, navigation, application behavior, bug fixes, and focused refactors. Use when a task requires changing application code while preserving the existing Cubit, GetIt, go_router, repository, SQLite, localization, and design-system conventions.
---

# Flutter Implementation

1. Read root `AGENTS.md` and inspect the affected feature, route, Cubit/state, repository, cache, and model.
2. Trace every affected read/write path and cross-feature invalidation before editing.
3. Inspect `AppTheme`, shared widgets, localization ARB, authorization helpers, and similar maintained features.
4. Choose the smallest complete change. Do not add packages, layers, or redesign unrelated UI without a current need.
5. Keep side effects out of build methods and persistence out of widgets.
6. Implement loading, empty, error, disabled, and success behavior relevant to the flow.
7. For mutations, prevent duplicate actions, use repository transactions when multiple rows/tables change, clear affected caches, and refresh visible state.
8. Preserve production data and compatibility fields. Route schema work through the database workflow.
9. Update English and Indonesian ARB sources for user-facing text and regenerate localization output when needed.
10. Add focused regression tests when practical and run checks proportional to the change.

Avoid broad refactors, a second state/navigation system, speculative abstractions, and unrelated package upgrades.
