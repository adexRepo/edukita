---
name: security-review
description: Review or change Edukita authentication, authorization, passwords, local sessions, student and guardian PII, financial assistance data, private documents, uploaded files, exports, backups, logs, and local storage security. Use when work touches sensitive data or trust boundaries.
---

# Security Review

1. Map the data, actor, device/account boundary, storage location, and export/file lifecycle.
2. Verify authentication and authorization at navigation, action, and critical repository boundaries. Admin behavior must remain explicit.
3. Preserve PBKDF2 password handling and forced first-login password changes. Never log credentials or session payloads.
4. Remember the session is a short-lived JSON file and SQLite/files are not encrypted secure storage.
5. Validate uploaded file type, size, existence, managed destination, metadata registration, replacement/deactivation, download/open behavior, and cleanup.
6. Review database, backup, export, screenshot, clipboard, shared Windows account, and removable-media exposure.
7. Treat packaged `.env` and Flutter assets as discoverable; reject embedded secrets and signing material.
8. Keep user-facing failures safe while retaining non-sensitive diagnostics.
9. Prefer focused mitigations compatible with this local-first monolith. State residual device-level risks clearly.
