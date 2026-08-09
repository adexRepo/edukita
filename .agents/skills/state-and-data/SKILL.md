---
name: state-and-data
description: Change or review Edukita Cubits, feature state, repositories, SQLite reads and writes, cache behavior, optimistic or background refresh, and asynchronous data flow. Use when a task affects loading, mutations, persistence, cache invalidation, stale data, or state consistency.
---

# State and Data

1. Identify the owner of ephemeral, feature, session, persisted, and cached state.
2. Trace UI event -> Cubit -> repository -> SQLite/file system -> cache invalidation -> refreshed UI.
3. Reuse Cubit/Bloc and existing state shapes. Do not add another state package or unnecessary global state.
4. Keep one source of truth and derive display values. Model meaningful initial/loading/success/empty/failure states explicitly.
5. Preserve existing data during background refresh when possible to prevent whole-page blinking.
6. Guard duplicate actions, stale async responses, closed Cubits, and disposed widgets. Do not use artificial delays.
7. Perform multi-table writes in one repository transaction. Rethrow when the UI needs actionable failure handling.
8. Invalidate every affected feature cache after successful writes and force-refresh visible consumers.
9. Keep SQL, file operations, and business rules outside widgets.
10. Add tests for state transitions, failure behavior, transaction boundaries, and cache invalidation when practical.
