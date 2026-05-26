# Edukita

Edukita is a Flutter desktop application for education foundation operations.
It is designed as a local-first Education Management Information System for
student administration, teaching sessions, schedules, assistance programs, and
operational reporting.

The current implementation targets Windows desktop with a local SQLite database.

## Table Of Contents

- [Product Scope](#product-scope)
- [Technology Stack](#technology-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Environment Configuration](#environment-configuration)
- [Database And Storage](#database-and-storage)
- [Development Workflow](#development-workflow)
- [Windows Build](#windows-build)
- [Release And Installation Notes](#release-and-installation-notes)
- [Security Notes](#security-notes)
- [Troubleshooting](#troubleshooting)

## Product Scope

Edukita currently includes these main areas:

- Dashboard analytics
- Student management and student detail profile
- Teacher management and teacher detail profile
- Schedule and calendar planning
- Teaching activity reports
- Attendance and learning score capture
- Parameter maintenance
- Curriculum, syllabus, subjects, units, competencies, and strategies
- Assistance programs, periods, target candidates, approval document, and recipients
- Dynamic report definitions and report inquiry
- Local settings, backup, and cache maintenance

## Technology Stack

- Flutter desktop
- Dart
- Bloc/Cubit for state management
- Repository pattern for data access
- GetIt for dependency injection
- SQLite via `sqflite_common_ffi`
- `go_router` for navigation
- `fl_chart` for dashboard charts
- `file_selector` for document upload and export flows
- `.env` based runtime configuration

## Architecture

The application follows a feature-based structure:

- Presentation layer: pages, dialogs, widgets
- Domain layer: cubits, repositories, business logic
- Data layer: models, DTOs, mappers
- Core layer: database, routing, shared infrastructure
- Widgets layer: reusable UI components

General flow:

```text
UI Page/Dialog
  -> Cubit
  -> Repository
  -> SQLite
  -> Cubit State
  -> UI
```

Business rules should live in repositories or domain services, not directly in UI widgets.
UI code should mainly handle rendering, validation feedback, and user interaction.

## Project Structure

```text
lib/
  app_shell.dart
  main.dart
  core/
    database/
    router/
    storage/
    helper/
  features/
    assistance/
      plans/
      periods/
      programs/
    auth/
    dashboard/
    parameters/
    reports/
    report_definitions/
    schedule/
    schools/
    settings/
    strategy/
    students/
    syllabus/
    teachers/
    teaching_activity/
  theme/
  widgets/
```

## Getting Started

Install Flutter and enable Windows desktop support:

```bash
flutter config --enable-windows-desktop
flutter doctor
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run -d windows
```

Default seeded login:

```text
Username: admin
Password: admin
```

For development only. Change this before real user deployment.

## Environment Configuration

The app loads `.env` at startup.

Current recommended local configuration:

```env
BRANCH_ID=JKTM1
DB_PATH=database
STORAGE_PATH=storage
```

Relative `DB_PATH` and `STORAGE_PATH` values are resolved under the application
data folder, not under the executable folder.

On Windows this is typically:

```text
%LOCALAPPDATA%\Edukita\database
%LOCALAPPDATA%\Edukita\storage
```

This keeps user data outside `Program Files`, avoids Windows permission issues,
and makes app updates safer.

Optional portable mode:

```env
APP_DATA_PATH=.
DB_PATH=database
STORAGE_PATH=storage
```

Use portable mode only when you intentionally want database and uploaded files
near the running directory.

## Database And Storage

The app uses a local SQLite database:

```text
edukita.db
```

Database schema is created and upgraded through:

```text
lib/core/database/database_tables.dart
lib/core/database/database_migrations.dart
lib/core/database/database_seed.dart
```

Important rules:

- Do not drop production tables in migrations.
- Use safe incremental migrations.
- Prefer `CREATE TABLE IF NOT EXISTS`.
- Add missing columns with guarded `ALTER TABLE`.
- Keep old columns when backward compatibility is needed.
- Store uploaded files in storage, not in SQLite blobs.
- Store file metadata/path in database tables.

The app contains a compatibility copy step for older local databases from:

```text
./edukita/database/edukita.db
```

If the new app data location is empty, the old database is copied automatically.

## Development Workflow

Recommended checks before a pull request:

```bash
flutter analyze
flutter test
```

Generate model code when changing Freezed or JSON serializable models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

General engineering conventions:

- Keep changes scoped to the feature being modified.
- Reuse existing widgets and theme styles.
- Keep business logic out of presentation widgets.
- Use repository transactions for multi-table writes.
- Keep desktop layouts responsive and scroll-safe.
- Prefer small, explicit migrations over destructive schema changes.
- Keep user data stable across app updates.

## Windows Build

Create a release build:

```bash
flutter build windows --release
```

Release output:

```text
build/windows/x64/runner/Release/
```

Do not distribute only `edukita.exe`. Flutter Windows apps require the generated
DLLs, assets, and `data` folder beside the executable.

## Release And Installation Notes

Recommended packaging for Windows users:

- Build Flutter Windows release.
- Package the full release folder with an installer.
- Use Inno Setup for the first production installer.
- Install binaries under `Program Files`.
- Keep database and uploads under `%LOCALAPPDATA%\Edukita`.
- Create Start Menu and optional Desktop shortcuts.
- Add database backup instructions before upgrades.

Suggested installer output:

```text
EdukitaSetup-<version>.exe
```

Future release improvements:

- Code signing certificate
- Auto-update flow
- Structured backup and restore UI
- Per-branch configuration
- User and role management hardening

## Security Notes

This app currently stores data locally. Treat the local machine as part of the
security boundary.

Recommended deployment practices:

- Use trusted Windows devices only.
- Restrict file system access to the Windows user account.
- Change default admin credentials before real use.
- Back up SQLite database regularly.
- Avoid storing database files in shared public folders.
- Do not commit real user data, uploaded documents, or production databases.
- Consider database encryption before handling sensitive production data.

## Troubleshooting

### App cannot login with admin

The app seeds the default admin user when the database opens. If login still
fails, check whether the app is using a different database path in Settings.

### Database looks empty after changing path

Check the database path shown in:

```text
Settings -> Storage -> Database
```

If needed, copy the previous `edukita.db` into the active database directory.

### Uploaded files cannot be opened

Check the storage path shown in:

```text
Settings -> Storage -> Uploads
```

The database stores file paths. Moving or deleting files from storage can break
document links.

### Windows build works locally but not on another computer

Make sure the full release folder is packaged, not only the executable file.

Required release contents include:

- `edukita.exe`
- Flutter DLLs
- plugin DLLs
- `data/`
- assets

## Current Status

Edukita is an active desktop MVP. The codebase is evolving toward a stable
local-first Windows application with structured data modules, dynamic reporting,
and safer installer-ready storage behavior.
