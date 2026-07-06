# sqliteraw Dart sample

Runnable examples showing how to use the raw SQLite C API from Dart via [sqliteraw](../../sqliteraw).

## Examples

| Example | Run | What it shows |
|---------|-----|---------------|
| Help | `dart run [directory]` | Runs all examples in order |
| [open_database.dart](example/open_database.dart) | `dart run example/open_database.dart [path]` | `sqlite3_open_v2`, `sqlite3_exec`, `sqlite3_close_v2` |
| [create_and_crud.dart](example/create_and_crud.dart) | `dart run example/create_and_crud.dart [path]` | `sqlite3_prepare_v2`, `sqlite3_bind_*`, `sqlite3_step`, `sqlite3_column_*` |
| [backup.dart](example/backup.dart) | `dart run example/backup.dart [source] [dest]` | `sqlite3_backup_init`, `sqlite3_backup_step`, `sqlite3_backup_finish` |

Implementation lives in `lib/`; the `example/` scripts are thin entry points with `main()`.

## Test

```bash
dart pub get
dart test
```

Tests exercise the same flows against temporary database files.
