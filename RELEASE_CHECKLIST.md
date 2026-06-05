# Edukita Release Checklist

## Before Release

1. Update version in `pubspec.yaml`.
2. Update `CHANGELOG.md`.
3. Run:
   ```bash
   flutter analyze
   ```
4. Run:
   ```bash
   flutter test
   ```
5. Test app locally on Windows.
6. Test app using old SQLite database copy.
7. Confirm database migration works if there are schema changes.
8. Confirm `C:\ProgramData\Edukita` is not deleted by installer.

## Create Release

1. Commit all changes.
2. Push to main.
3. Create Git tag:
   ```bash
   git tag v1.0.1
   ```
4. Push tag:
   ```bash
   git push origin v1.0.1
   ```

## After GitHub Actions Completed

1. Open GitHub Release.
2. Download:
   ```text
   EdukitaSetup_v1.0.1.exe
   ```
3. Download:
   ```text
   EdukitaUpdate_v1.0.1.zip
   ```
4. Extract `EdukitaUpdate_v1.0.1.zip` to flashdisk.
5. Flashdisk should contain:
   ```text
   EdukitaUpdate/update.json
   EdukitaUpdate/EdukitaSetup_v1.0.1.exe
   ```

## User Update Flow

1. Insert flashdisk into user laptop.
2. Open Edukita.
3. Go to Settings / About.
4. Click Check Update.
5. Select `EdukitaUpdate` folder from flashdisk.
6. Edukita reads `update.json`.
7. If version is newer, click Install Update.
8. Edukita runs installer.
9. Edukita closes.
10. Installer updates app files.
11. Confirm local data still exists in:
    ```text
    C:\ProgramData\Edukita
    ```
