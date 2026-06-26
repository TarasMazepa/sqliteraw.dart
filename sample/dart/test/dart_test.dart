import 'package:ffi/ffi.dart';
import 'package:sqliteraw.dart/sqliteraw.dart' as ffi;
import 'package:test/test.dart';

void main() {
  test('sqlite3_libversion', () {
    final versionPtr = ffi.sqlite3_libversion();
    final versionStr = versionPtr.cast<Utf8>().toDartString();
    expect(versionStr, isNotEmpty);
    expect(versionStr, ffi.SQLITE_VERSION);
  });
}
