# sqliteraw Dart sample

Standalone Dart CLI project showing how to use the raw SQLite C API via [sqliteraw](../../sqliteraw).

## How it works

1. Add `sqliteraw` as a dependency — the native hook builds `libsqliteraw` on first `dart run` or `dart test`.
2. Import `package:sqliteraw/sqliteraw.dart` for `sqlite3_*` functions and constants.
3. Use helpers in [`lib/utils/sqlite_helpers.dart`](lib/utils/sqlite_helpers.dart) for common FFI patterns (open, prepare, bind, error checking).
4. Example logic lives in [`lib/crud/`](lib/crud/); [`example/`](example/) scripts are thin `main()` entry points.

```
example/open_database.dart  →  lib/crud/open_database.dart  →  sqliteraw (FFI)
example/create_and_crud.dart → lib/crud/create_and_crud.dart → sqliteraw (FFI)
example/backup.dart         →  lib/crud/backup.dart          →  sqliteraw (FFI)
```

Database files default to the system temp directory. Pass a path argument to store them elsewhere.

## Setup

From the repository root:

```bash
cd sqliteraw
dart pub get
dart run ffigen

cd ../sample/dart
dart pub get
```

## Run examples

Run **all** examples in order (open → CRUD → backup):

```bash
dart run
```

Run with a custom directory for database files:

```bash
dart run /path/to/database/dir
```

Run **individual** examples:

```bash
dart run example/open_database.dart [path]
dart run example/create_and_crud.dart [path]
dart run example/backup.dart [source] [dest]
```

Without arguments, examples use files under the system temp directory, for example:

- `/tmp/sqliteraw_open_example.db`
- `/tmp/sqliteraw_crud_example.db`
- `/tmp/sqliteraw_backup_source.db` → `/tmp/sqliteraw_backup_copy.db`

## What each example shows

| Example | SQLite C API |
|---------|----------------|
| [open_database.dart](example/open_database.dart) | `sqlite3_open_v2`, `sqlite3_exec`, `sqlite3_close_v2` |
| [create_and_crud.dart](example/create_and_crud.dart) | `sqlite3_prepare_v2`, `sqlite3_bind_*`, `sqlite3_step`, `sqlite3_column_*` |
| [backup.dart](example/backup.dart) | `sqlite3_backup_init`, `sqlite3_backup_step`, `sqlite3_backup_finish` |

The CRUD example inserts two todos, lists them, updates one (appends ` Updated` to the title), then deletes the other.

## Test

```bash
dart test
```

Run a single test file:

```bash
dart test test/open_database_test.dart
dart test test/create_and_crud_test.dart
dart test test/backup_test.dart
dart test test/run_examples_test.dart
```

## Project layout

```
sample/dart/
  bin/sqliteraw_sample_dart.dart   # default entry for `dart run`
  example/                         # runnable scripts
  lib/
    crud/                          # open, CRUD, backup implementations
    models/                        # TodoItem, CrudDemonstrationResult
    utils/                         # sqlite_helpers, sqlite_exception
  test/                            # integration tests
```

## Use in your own Dart CLI app

```yaml
# pubspec.yaml
dependencies:
  ffi: ^2.1.4
  sqliteraw:
    path: ../../sqliteraw
```

See [`lib/utils/sqlite_helpers.dart`](lib/utils/sqlite_helpers.dart) and [`lib/crud/open_database.dart`](lib/crud/open_database.dart) as starting points.
