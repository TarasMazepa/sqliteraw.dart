# sqliteraw

An SQLite binding for Dart that exposes the **full SQLite C API** through FFI — no wrappers, no hidden functionality.

sqliteraw compiles SQLite from source and generates Dart bindings with `ffigen`, so you call the same functions documented at [sqlite.org/c3ref](https://www.sqlite.org/c3ref/intro.html) directly from Dart.

## How it works

```
┌─────────────────┐     FFI      ┌──────────────────┐     links     ┌─────────────┐
│  Your Dart/     │ ──────────── │  sqliteraw       │ ───────────── │  SQLite C   │
│  Flutter app    │  sqlite3_*   │  (lib/sqliteraw) │   libsqliteraw│  (sqlite3.c)│
└─────────────────┘              └──────────────────┘               └─────────────┘
```

1. **Native build** — `sqliteraw/hook/build.dart` compiles `sqlite/sqlite3.c` into a platform library (`libsqliteraw.so`, `.dylib`, `.dll`, …) when you build or run your app.
2. **FFI bindings** — `sqliteraw/lib/sqliteraw.dart` is auto-generated from `sqlite/sqlite3.h` and exposes every `sqlite3_*` function and constant.
3. **Your code** — uses `dart:ffi` and `package:ffi` to call those functions (open, prepare, bind, step, backup, …).

SQLite is built with FTS4, FTS5, RTREE, and GEOPOLY enabled.

## Repository layout

| Path | Description |
|------|-------------|
| [`sqliteraw/`](sqliteraw/) | The `sqliteraw` package (bindings + native build hook) |
| [`sqlite/`](sqlite/) | Upstream SQLite C sources |
| [`sample/dart/`](sample/dart/) | Standalone Dart CLI examples |
| [`sample/flutter/`](sample/flutter/) | Flutter app examples (Android, iOS, desktop) |

## Requirements

- Dart SDK `^3.10.0` (see [`DART_SDK_VERSION`](DART_SDK_VERSION))
- For Flutter samples: Flutter `3.38.5` (see [`FLUTTER_VERSION`](FLUTTER_VERSION))
- A C toolchain (`clang` on Linux/macOS; MSVC on Windows; Android NDK / Xcode for mobile)

## Use in your own Dart project

Add a path or git dependency:

```yaml
dependencies:
  ffi: ^2.1.4
  sqliteraw:
    path: ../sqliteraw   # adjust path
```

Minimal usage:

```dart
import 'package:ffi/ffi.dart';
import 'package:sqliteraw/sqliteraw.dart' as sqlite;

void main() {
  print(sqlite.SQLITE_VERSION);
  print(sqlite.sqlite3_libversion().cast<Utf8>().toDartString());
}
```

The first `dart run` / `flutter run` triggers the native hook and builds `libsqliteraw` for your platform.

Regenerate bindings after updating `sqlite/sqlite3.h`:

```bash
cd sqliteraw
dart pub get
dart run ffigen
```

## Use in your own Flutter project

```yaml
dependencies:
  flutter:
    sdk: flutter
  ffi: ^2.1.4
  path_provider: ^2.1.5   # for app-writable database paths
  sqliteraw:
    path: ../../sqliteraw
```

On mobile and desktop, store database files in the application documents directory (see `sample/flutter/lib/utils/database_paths.dart`).

## Samples

Two sample projects demonstrate the same SQLite flows:

| | Dart CLI | Flutter app |
|---|----------|-------------|
| Location | [`sample/dart/`](sample/dart/) | [`sample/flutter/`](sample/flutter/) |
| README | [sample/dart/README.md](sample/dart/README.md) | [sample/flutter/README.md](sample/flutter/README.md) |

Both cover: **open database**, **CRUD with prepared statements**, and **online backup**.

### Quick start — Dart sample

```bash
cd sqliteraw && dart pub get && dart run ffigen
cd ../sample/dart && dart pub get
dart run                    # run all examples
dart test                   # run tests
```

### Quick start — Flutter sample

```bash
cd sqliteraw && dart pub get && dart run ffigen
cd ../sample/flutter && flutter pub get
flutter run                 # run app on connected device/emulator
flutter test                # run tests
flutter build apk --debug   # verify Android native build
flutter build ios --simulator --debug   # verify iOS build (macOS only)
```

## Build & test commands (from repo root)

### sqliteraw package

```bash
cd sqliteraw
dart pub get
dart run ffigen
dart test
```

### Dart sample

```bash
cd sample/dart
dart pub get
dart run
dart run example/open_database.dart
dart run example/create_and_crud.dart
dart run example/backup.dart [source] [dest]
dart test
```

### Flutter sample

```bash
cd sample/flutter
flutter pub get
flutter run
flutter test
flutter build apk --debug
flutter build ios --simulator --debug
```

## Continuous integration

GitHub Actions workflows in [`.github/workflows/`](.github/workflows/):

| Workflow | What it verifies |
|----------|------------------|
| `sqlite-build.yml` | SQLite compiles on Linux (arm + x64) |
| `sample-dart-test.yml` | Dart sample tests on Linux (arm + x64) |
| `sample-flutter-test.yml` | Flutter sample tests on Linux (arm + x64) |
| `update-sqlite-bindings.yml` | Regenerates FFI bindings when SQLite is updated |

## Learn more

- [SQLite C API reference](https://www.sqlite.org/c3ref/intro.html)
- [Dart FFI](https://dart.dev/interop/c-interop)
- Sample implementations: [`sample/dart/lib/crud/`](sample/dart/lib/crud/), [`sample/flutter/lib/example/`](sample/flutter/lib/example/)
