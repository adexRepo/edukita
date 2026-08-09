---
name: testing
description: Create, update, or plan Edukita unit, Cubit/state, widget, migration, repository, and integration tests. Use for regression coverage, critical user flows, business rules, authorization, persistence, cache behavior, and loading/error/empty UI states.
---

# Flutter Testing

1. Reproduce the user-visible behavior or business rule before choosing a test boundary.
2. Prefer pure unit tests for calculations/validation, Cubit tests for transitions, repository tests for SQLite rules and migrations, widget tests for interactions/layout, and integration tests only for critical complete flows.
3. Test public behavior and state, not private implementation details.
4. Cover success plus the realistic failure/regression that motivated the work.
5. Use deterministic temporary app data/database paths and isolate tests from developer or production files.
6. Reset GetIt, SharedPreferences, session/cache state, controllers, and temporary resources between tests as needed.
7. Avoid giant fixtures, broad mocks, and tests for trivial getters.
8. Run the narrow test first, then `flutter test` when scope/time permits. Report exactly what ran.
