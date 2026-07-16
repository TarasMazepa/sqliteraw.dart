# sqliteraw

An SQLite binding for Dart that doesn't hide functionality.

## Prerequisites

- Dart SDK ^3.10.0
- Flutter (see `FLUTTER_VERSION` in the repo root)
- For native samples: `clang`
- For WASM builds: LLVM with WebAssembly target (`clang` + `wasm-ld`)

```bash
brew install llvm lld
```

The build script prefers Homebrew LLVM over Xcode clang. If needed:

```bash
export PATH="/opt/homebrew/opt/llvm/bin:/opt/homebrew/bin:$PATH"
```

## Build WASM

The Flutter web sample loads `sqliteraw.wasm`. Build it before running or building for web:

```bash
sqliteraw/wasm/tool/build_wasm.sh
```

The output is written to `sqliteraw/wasm/out/sqliteraw.wasm` (gitignored; rebuild after a clean checkout or any change to the WASM sources).

Rebuild whenever WASM sources change:

```bash
sqliteraw/wasm/tool/build_wasm.sh
```

## Flutter web sample

Runs the same open-database example as the Dart sample, using WASM on web.

```bash
sqliteraw/wasm/tool/build_wasm.sh

cd sample/flutter
flutter pub get
flutter run -d chrome
```

Production build:

```bash
cd sample/flutter
flutter build web --wasm
```

## Dart sample

Native FFI example that opens an in-memory database and runs create/insert/update/delete/select.

```bash
cd sample/dart
dart pub get
dart run example/open_database.dart
```

## Tests

```bash
cd sample/flutter
flutter pub get
flutter test
```

```bash
cd sample/dart
dart pub get
dart test
```

## Quick start (Flutter web)

```bash
sqliteraw/wasm/tool/build_wasm.sh
cd sample/flutter
flutter pub get
flutter run -d chrome
```

The app prints the SQLite version, creates a `todos` table, inserts/updates/deletes rows, and shows the final query result.
