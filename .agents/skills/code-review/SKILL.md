---
name: code-review
description: Review Edukita Flutter changes, pull requests, features, or modules for correctness, state consistency, async lifecycle safety, sensitive-data handling, regressions, responsive/accessibility issues, performance, maintainability, and missing tests. Use whenever the user asks for a code review or risk audit.
---

# Flutter Code Review

Inspect the relevant diff plus callers, Cubits, repositories, schema, cache, routes, permissions, and tests. Review in this order:

1. Correctness and data integrity.
2. State consistency and cache invalidation.
3. Async lifecycle, duplicate actions, and disposed/closed object safety.
4. Credentials, student PII, financial data, files, exports, and logs.
5. User-flow and authorization regressions.
6. Responsive layout, overflow, keyboard, focus, and accessibility.
7. SQLite/query/rebuild performance and resource leaks.
8. Maintainability and architectural fit.
9. Test gaps.

Lead with findings ordered by severity. For each finding include severity, precise file/line, realistic failure scenario, and recommended fix. Avoid formatter/lint trivia and speculative abstractions. If no findings exist, say so and state residual test or platform risk.
