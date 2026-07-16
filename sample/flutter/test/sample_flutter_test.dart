import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqliteraw/sqliteraw_native.dart';

void main() {
  test('sqlite3_libversion', () {
    expect(sqlite3_libversion().cast<Utf8>().toDartString(), SQLITE_VERSION);
  });
}
