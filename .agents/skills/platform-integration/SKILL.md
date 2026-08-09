---
name: platform-integration
description: Implement or review Edukita Windows desktop behavior, window management, app-data paths, file pick/drop/open/download flows, Inno Setup packaging, GitHub Windows releases, and target-specific Flutter integration. Use for platform files, installers, storage paths, desktop keyboard/focus, or release artifacts.
---

# Platform Integration

1. Treat Windows as the maintained production target; platform folders for other targets do not prove runtime support.
2. Inspect Flutter/Dart code plus the relevant native runner, plugin registration, installer, CI, and release workflow.
3. Keep binaries under Program Files and mutable user data under the runtime app-data path. Never rely on the current working directory for installed-app data.
4. Preserve database/uploads across installer upgrades and uninstalls unless the user explicitly requests removal with backup guidance.
5. Package the complete Flutter Windows release directory, not only the executable.
6. Validate file selector/drop behavior, extensions, size, managed copies, metadata, open/download errors, and missing-file recovery.
7. Keep window constraints, keyboard/focus, scroll behavior, DPI, and minimized-size layouts safe.
8. Keep release version/tag, `pubspec.yaml`, installer filename, and GitHub workflow behavior understandable; do not embed signing secrets.
9. Run the affected platform build when practical and clearly state unverified targets.
