# sqliteraw Flutter sample

Flutter app demonstrating the same raw SQLite C API usage as the [Dart sample](../dart), with platform-appropriate database paths via `path_provider`.

## How it works

1. **sqliteraw** is a dependency — Flutter's build runs the native hook and compiles `libsqliteraw` for each target platform (Android, iOS, macOS, Windows, Linux).
2. **FFI calls** are identical to the Dart sample — see [`lib/utils/sqlite_helpers.dart`](lib/utils/sqlite_helpers.dart) and [`lib/example/`](lib/example/).
3. **Database paths** — at runtime, files are stored in the application documents directory ([`lib/utils/database_paths.dart`](lib/utils/database_paths.dart)). Tests inject a temp directory instead to avoid platform channels in CI.
4. **App UI** — [`lib/main.dart`](lib/main.dart) runs all examples on launch and displays paths and CRUD results.

```
lib/main.dart
  └─ sample_flutter.runAllExamples()
       ├─ lib/example/open_database.dart      → sqliteraw (FFI)
       ├─ lib/example/create_and_crud.dart   → sqliteraw (FFI)
       └─ lib/example/backup.dart             → sqliteraw (FFI)
```

Unlike the Dart sample, this project does **not** depend on `sqliteraw_sample_dart` — all FFI code is self-contained under `lib/`.

## Setup

From the repository root:

```bash
cd sqliteraw
dart pub get
dart run ffigen

cd ../sample/flutter
flutter pub get
```

## Run the app

On a connected device or emulator:

```bash
flutter run
```

On a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

Examples run automatically when the app opens. Database files are created in the app documents directory.

## Build for mobile

Verify native sqliteraw compilation for release targets:

```bash
# Android
flutter build apk --debug
flutter build apk --release

# iOS (macOS host, simulator — no signing required)
flutter build ios --simulator --debug

# iOS device (requires signing setup in Xcode)
flutter build ios --no-codesign --debug
```

## Test

```bash
flutter test
```

Run individual test files:

```bash
flutter test test/open_database_test.dart
flutter test test/create_and_crud_test.dart
flutter test test/backup_test.dart
flutter test test/example_home_page_test.dart
flutter test test/sample_flutter_test.dart
```

Tests use a temporary directory for database files, so they work on Linux CI without an emulator.

## What each example shows

| Example | Location | SQLite C API |
|---------|----------|----------------|
| Open database | [lib/example/open_database.dart](lib/example/open_database.dart) | `sqlite3_open_v2`, `sqlite3_exec`, `sqlite3_close_v2` |
| Create & CRUD | [lib/example/create_and_crud.dart](lib/example/create_and_crud.dart) | `sqlite3_prepare_v2`, `sqlite3_bind_*`, `sqlite3_step`, `sqlite3_column_*` |
| Backup | [lib/example/backup.dart](lib/example/backup.dart) | `sqlite3_backup_init`, `sqlite3_backup_step`, `sqlite3_backup_finish` |

The CRUD flow matches the Dart sample: insert two todos, list, update the last one (title + ` Updated`, mark done), delete it, list again.

## Project layout

```
sample/flutter/
  lib/
    example/           # open, CRUD, backup (direct sqliteraw FFI)
    models/            # TodoItem, CrudDemonstrationResult, FlutterExampleResults
    utils/             # sqlite_helpers, database_paths, sqlite_exception
    main.dart          # Flutter UI
    sample_flutter.dart
  test/                # integration + widget tests
  android/ ios/ ...    # platform runners
```

## Use in your own Flutter app

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  ffi: ^2.1.4
  path_provider: ^2.1.5
  sqliteraw:
    path: ../../sqliteraw
```

Copy or adapt helpers from [`lib/utils/sqlite_helpers.dart`](lib/utils/sqlite_helpers.dart) and examples from [`lib/example/`](lib/example/).

**Android note:** sqliteraw links against `libm` and `libdl` on Android (configured in `sqliteraw/hook/build.dart`). After upgrading sqliteraw, run `flutter clean` if you see missing symbol errors for `log`.

## Compare with the Dart sample

| | Dart sample | Flutter sample |
|---|-------------|----------------|
| Entry | `dart run` / `example/*.dart` | `flutter run` (UI) |
| DB path | Temp dir or CLI argument | App documents dir (`path_provider`) |
| Code location | `sample/dart/lib/crud/` | `sample/flutter/lib/example/` |
| Shared package | — | Self-contained (no dart sample dependency) |

See also the [main README](../../README.md) for CI and repo-wide commands.
