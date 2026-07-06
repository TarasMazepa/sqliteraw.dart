# sqliteraw Flutter sample

Flutter app demonstrating how to use the raw SQLite C API from Dart via [sqliteraw](../../sqliteraw), with platform-appropriate database paths via `path_provider`.

## Examples

| Example | Location | What it shows |
|---------|----------|---------------|
| Open database | [lib/example/open_database.dart](lib/example/open_database.dart) | `sqlite3_open_v2`, `sqlite3_exec`, `sqlite3_close_v2` |
| Create & CRUD | [lib/example/create_and_crud.dart](lib/example/create_and_crud.dart) | `sqlite3_prepare_v2`, `sqlite3_bind_*`, `sqlite3_step`, `sqlite3_column_*` |
| Backup | [lib/example/backup.dart](lib/example/backup.dart) | `sqlite3_backup_init`, `sqlite3_backup_step`, `sqlite3_backup_finish` |

Shared FFI helpers live in [lib/sqlite_helpers.dart](lib/sqlite_helpers.dart). At runtime, [lib/sample_flutter.dart](lib/sample_flutter.dart) resolves paths via the application documents directory. Tests pass an explicit temporary directory instead.

## Run

```bash
flutter pub get
flutter run
```

## Test

```bash
flutter test
```
