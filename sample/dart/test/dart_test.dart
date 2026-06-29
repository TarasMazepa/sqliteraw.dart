import 'package:ffi/ffi.dart';
import 'package:sqliteraw.dart/sqliteraw.dart' as sqliteraw;
import 'package:test/test.dart';

void main() {
  test('sqlite3_libversion', () {
    expect(
      sqliteraw.sqlite3_libversion().cast<Utf8>().toDartString(),
      sqliteraw.SQLITE_VERSION,
    );
  });
}
