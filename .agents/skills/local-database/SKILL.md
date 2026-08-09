---
name: local-database
description: Implement or review Edukita SQLite tables, columns, constraints, indexes, migrations, seeds, transactions, queries, compatibility backfills, and local data integrity. Use for any change to DatabaseProvider, DatabaseTables, DatabaseMigrations, DatabaseSeed, repositories with SQL, or schema-dependent models.
---

# Local Database

1. Inspect current table creation, schema version, migration history, `ensureCriticalSchema`, seeds, indexes, repository queries, and installed-data compatibility.
2. Preserve production data. Prefer guarded additive migration and backfill; do not drop/rebuild/rename tables or compatibility columns without explicit need and a proven recovery path.
3. Bump `DatabaseProvider.schemaVersion` for versioned schema changes and keep `onCreate`, upgrades, and `onOpen` repair paths consistent.
4. Keep seeds idempotent, deterministic, and limited to required defaults. Never overwrite user-managed values on every open.
5. Use foreign keys, uniqueness, checks, defaults, and indexes deliberately. Verify old rows satisfy new constraints.
6. Use one transaction for related writes, file metadata updates where appropriate, and recipient/history finalization.
7. Parameterize values. Allow dynamic identifiers only from trusted report/schema definitions with explicit validation.
8. Check query plans/indexes for frequently used joins and filters; avoid duplicate indexes.
9. Test fresh creation, upgrade from the relevant prior version, repeated open/seed, rollback/failure, and representative repository reads.
10. Never run destructive commands against a developer or production database during verification.
