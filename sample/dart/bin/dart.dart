import 'package:dart/dart.dart' as dart;

void main(List<String> arguments) {
  print('SQLite compile-time version: ${dart.version()}');
  print('SQLite runtime version (via FFI): ${dart.versionFromLibrary()}');
}
