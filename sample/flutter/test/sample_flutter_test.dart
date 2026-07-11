import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqliteraw/sqliteraw_native.dart' as ffi;

void main() {
  test('sqlite3_libversion', () {
    final versionPtr = ffi.sqlite3_libversion();
    final versionStr = versionPtr.cast<Utf8>().toDartString();
    expect(versionStr, isNotEmpty);
    expect(versionStr, ffi.SQLITE_VERSION);
  });
}
