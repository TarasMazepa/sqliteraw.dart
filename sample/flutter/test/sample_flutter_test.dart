import 'package:ffi/ffi.dart';
import 'package:sqliteraw_dart/sqliteraw.dart' as ffi;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sqlite3_libversion', () {
    final versionPtr = ffi.sqlite3_libversion();
    final versionStr = versionPtr.cast<Utf8>().toDartString();
    expect(versionStr, isNotEmpty);
    expect(versionStr, ffi.SQLITE_VERSION);
  });
}
