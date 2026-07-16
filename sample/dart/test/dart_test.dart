import 'package:ffi/ffi.dart';
import 'package:sqliteraw/sqliteraw_native.dart';
import 'package:test/test.dart';

void main() {
  test('sqlite3_libversion', () {
    expect(sqlite3_libversion().cast<Utf8>().toDartString(), SQLITE_VERSION);
  });
}
