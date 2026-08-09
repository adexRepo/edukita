# Edukita Codex Guide

## Project overview

- Edukita is a local-first education foundation management application. It manages students, teachers, schedules, teaching reports, attendance and scores, assistance programs, parameters, dynamic reports, users, and local settings.
- Toolchain verified in this repository: Flutter 3.41.6 stable and Dart 3.11.4. `pubspec.yaml` requires Dart `^3.11.4` and currently declares app version `1.0.5`.
- Flutter platform scaffolds exist for Android, iOS, Linux, macOS, web, and Windows. The maintained and CI/release target is Windows desktop; do not assume another target works without a target-specific build and test.
- This is one deployable Flutter monolith. `lib/main.dart` is the bootstrap and `lib/app_shell.dart` owns the authenticated desktop shell.
- The dominant structure is feature-first under `lib/features/<feature>/`, usually split into `data`, `domain`, and `presentation`. Preserve existing feature paths, including established legacy spellings, unless a scoped migration is requested.
- State management is `flutter_bloc` with Cubit. Shared states commonly use `FeatureState<T>`; complex features use focused state classes.
- Dependency injection uses GetIt. Register repositories and caches as lazy singletons and Cubits as factories in `lib/core/router/service_locator.dart`.
- Navigation uses one centralized `go_router` configuration in `lib/core/router/app_router.dart`, with `ShellRoute` and permission-aware pages. Do not add a second router.
- Persistence uses SQLite through `sqflite`/`sqflite_common_ffi`; web has the FFI web factory. `DatabaseProvider` owns opening and schema version 29. `DatabaseTables`, `DatabaseMigrations`, and `DatabaseSeed` own schema lifecycle.
- There is no API client or backend integration in this repository. Do not invent network layers or remote synchronization.
- Uploaded documents live on the file system and their metadata is registered in `uploaded_files`. Runtime paths are resolved by `AppStoragePaths`, normally under `%LOCALAPPDATA%\Edukita` on Windows.
- Authentication is local SQLite authentication. Passwords use PBKDF2-HMAC-SHA256. `AuthSessionCache` persists a short-lived JSON session (currently two minutes); this is not OS secure storage.
- Authorization is role/menu/action based and implemented in the users feature. Admin is unrestricted; staff/teacher permissions and per-user grants come from SQLite.
- Localization uses generated Flutter ARB output from `lib/l10n/app_en.arb` and `app_id.arb`. Update ARB sources, then regenerate; do not manually treat generated localization Dart files as source of truth.
- Theme and UI use centralized Material theme values in `lib/theme/app_theme.dart`, shared widgets under `lib/widgets`, and selected `shadcn_ui` form components. Poppins is the app font.
- Responsive desktop layouts use `LayoutBuilder`, constraints, flexible layout, and deliberate scrolling. Minimum desktop window size is 800x600.
- Forms use Flutter `Form` plus shared `AppFormValidation`, input formatters, and feature business validation.
- Errors are represented in Cubit state and surfaced through shared toast/detail-dialog helpers. Keep diagnostic details available without exposing raw sensitive data in normal user messages.
- In-memory feature caches use `AppMemoryCache` and feature-specific cache services. Mutations must invalidate every affected cache and refresh visible state.
- There are no notification, alarm, or background-processing packages/workflows at present.
- Serialization uses Freezed and `json_serializable` where justified; generated files use snake-case JSON configuration from `build.yaml`. Many simpler models use explicit map conversion.
- Tests currently use `flutter_test`; the repository has a startup widget smoke test and no integration-test suite.
- Lints come from `flutter_lints` via `analysis_options.yaml`; formatting uses standard Dart formatting.
- No build flavors are configured. Runtime paths/branch identity use packaged `.env` keys `BRANCH_ID`, `DB_PATH`, and `STORAGE_PATH`, with optional `APP_DATA_PATH` supported by code.
- CI runs `flutter analyze` and `flutter test` on Windows for pushes/PRs to `main` and `develop`. Tags matching `v*.*.*` build and publish the Windows Inno Setup installer and offline update zip.

Important modules include `dashboard`, `students`, `teachers`, `schools`, `syllabus`, `strategy`, `schedule`, `teaching_activity`, `assistance`, `parameters`, `reports`, `report_definitions`, `users`, `auth`, and `settings`.

Common commands:

```powershell
flutter pub get
flutter run -d windows
dart run build_runner build --delete-conflicting-outputs
dart format path\to\changed_file.dart
flutter analyze
flutter test
flutter build windows --release
```

Prefer targeted analysis/tests while iterating, then run the full checks before release. Never claim a check passed unless it was run.

## Monolith boundaries

Keep Edukita one repository and one deployable Flutter application. Maintain feature-oriented internal modules, cohesive ownership, clear dependencies, genuinely shared code, and one predictable bootstrap.

Do not create microservices, internal message buses, package-per-layer structures, ordinary-feature Dart packages, app-internal plugins, or generic frameworks for hypothetical products. Extract a package only for an independent lifecycle, reuse by multiple applications, a required platform plugin boundary, or a demonstrated build/ownership problem.

## Engineering principles

### KISS and YAGNI

Choose the simplest correct implementation that fits the existing code. Do not add extension points, interfaces, settings, or dependencies for speculative use.

### Pragmatic DRY and SOLID

Share real business rules and reusable UI. Do not force unrelated screens into one highly configurable widget. Keep responsibilities and dependency direction clear without adding ceremonial layers.

### Focused changes

For each task:

1. Inspect the affected feature and its callers.
2. Trace UI, Cubit, cache, repository, SQLite, and cross-feature effects.
3. Reuse current theme, widgets, validation, error, authorization, and localization patterns.
4. Make the smallest complete change and preserve unrelated behavior/data.
5. Add meaningful regression coverage when practical.
6. Run checks proportional to the risk and report what was not run.

## Internal structure and dependencies

Preserve coherent existing structure. For a substantial feature, the current convention is:

```text
lib/features/feature_name/
  data/
  domain/
  presentation/
```

Only create a layer when it has real content. A small feature may keep page, Cubit, and repository close together.

Presentation may depend on Cubits, feature models, and public repository/domain APIs. Repositories own SQL, transactions, file persistence, and cross-table rules. `core` and shared widgets must not depend on a feature implementation. Avoid feature-to-feature internal imports and circular dependencies; expose the smallest useful public boundary when cross-feature coordination is required.

## Dart and widget standards

- Use sound null safety, `final` by default, meaningful `const`, immutable models/state where practical, explicit names, small cohesive methods, and structured async error handling.
- Avoid broad `dynamic`, unjustified `late`/`!`, mutable globals, swallowed exceptions, utility dumping grounds, and commented-out production code.
- Comments should explain a business constraint, compatibility reason, or non-obvious decision.
- Keep widgets focused and prefer composition. Extract meaningful UI, reused UI, complex rendering, or isolated stateful behavior; do not extract every small row.
- Keep build methods deterministic. Never start reads/writes, navigation, analytics, or state mutation during normal build execution. Do expensive work before state reaches the widget.
- Dispose controllers, focus nodes, scroll controllers, and subscriptions. Guard async completion with Cubit `isClosed` or widget `mounted` as appropriate.

## State, navigation, and authorization

- Reuse Cubit/Bloc; never introduce another state package for one feature.
- Keep ephemeral state local, feature state in its Cubit, session/language at app scope, persisted state in repositories, and cache state in existing cache services.
- Represent initial/loading/success/empty/failure explicitly. Preserve prior data during background refresh when that avoids whole-page blinking.
- Maintain one source of truth. Derived counts and labels should normally remain derived.
- After writes, invalidate all related caches before reloading. Prevent stale async responses and duplicate submissions.
- Add routes only through `app_router.dart` and keep shell/auth behavior consistent.
- Apply menu and action authorization both to discoverability and direct-route/action guards. Client-side visibility is not a substitute for repository validation of critical rules.

## UI, responsive layout, and accessibility

- Reuse `AppTheme`, `AppColors`, shared page headers, tables, dialogs, toasts, loading/error components, icons, spacing, radii, and typography.
- Match the current quiet desktop operations style. Avoid gradients, excessive shadows/cards, decorative effects, and inconsistent helper text.
- Implement loading, empty, error, disabled, and success states. Empty data tables should retain their structure where that is the established page behavior.
- Prefer constraints, `Expanded`/`Flexible`, and bounded scroll views over fixed heights. Test at 800x600 and a normal maximized desktop size. Never hide overflow as a fix.
- Keep tables scannable and horizontally scroll only when columns genuinely need it. Every `Scrollbar` and its `ScrollView` must share an attached controller.
- Support keyboard use, predictable focus, readable contrast/text scaling, semantic or tooltip labels for icon-only controls, and non-color-only status cues.
- Confirm destructive actions and guard rapid double-clicks with the existing action/dialog guard.

## Data, files, and security

- Keep SQL and file-system details out of widgets. Use repositories and transactions for multi-table writes.
- Preserve `DatabaseProvider.schemaVersion`, migration ordering, `ensureCriticalSchema`, seed idempotency, foreign keys, compatibility columns, and existing production data.
- Never drop/rebuild production tables or rename compatibility fields casually. Use guarded schema changes, `CREATE ... IF NOT EXISTS`, indexes for measured query paths, backfills, and migration tests where practical.
- Store files under managed storage and register metadata with `UploadedFileRepository`; do not put large files in SQLite blobs. Validate existence, extension, size, ownership, replacement policy, and cleanup behavior.
- Never commit or log real databases, passwords, session contents, personal records, financial values, or private document bodies.
- Treat packaged `.env` values as discoverable. Never place API secrets, signing keys, encryption master keys, or production credentials in Flutter assets.
- The app contains sensitive child/student, guardian, financial-assistance, and document data. Consider local database/file exposure, exports, backups, shared Windows accounts, screenshots, clipboard, and logs for every relevant change.
- No secure-storage package is present. Do not describe the JSON session cache or SQLite database as encrypted/secure storage.

## Networking and external integration

There is currently no application API client. If a concrete API requirement is added, use one centralized client/configuration boundary, normalized errors, timeouts, intentional offline/retry behavior, and repository integration. Do not call APIs from widgets or leak raw backend errors. Never retry non-idempotent operations automatically unless proven safe.

## Forms, errors, and asynchronous work

- Reuse `AppFormValidation`, localized field labels/messages, input formatters, form keys, and feature-level business validation.
- Preserve input after recoverable failure, prevent duplicate submission, show field errors near fields, and expose actionable submit errors.
- Use shared app toasts and error-detail dialogs. User messages should be understandable; diagnostics must not disclose sensitive content.
- Do not use artificial delays for synchronization. Handle loading, cancellation/staleness, disposal, duplicate actions, and errors explicitly.

## Performance and packages

- First fix unnecessary rebuild scope, repeated SQLite reads, unbounded lists, oversized images, repeated decoding, and leaked controllers.
- Use `const`, caching, selectors, memoization, pagination, or isolates only when the behavior/scale justifies them.
- Before adding a package, check Flutter/Dart and current dependencies, compare a small direct implementation, and evaluate maintenance/platform support. Do not perform unrelated upgrades.

## Testing and verification

Prioritize business rules, state transitions, migrations/transactions, authorization, critical user flows, cache invalidation, regressions, and loading/error/empty states. Use unit tests for pure rules, Cubit tests for transitions, widget tests for interaction/layout, and integration tests only for critical end-to-end flows. Avoid fragile private-widget assertions and excessive mocking.

A bug fix should normally include a regression test when practical. Before handoff, run relevant formatting, targeted/full analysis, tests, and the affected platform build. Report commands actually run and any residual risk.
