import 'dart:io';

import 'package:sqliteraw_sample_dart/example/open_database.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String databasePath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sqliteraw_open_test_');
    databasePath = '${tempDir.path}/test.db';
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('demonstrateOpenDatabase creates and opens a database file', () {
    expect(File(databasePath).existsSync(), isFalse);

    demonstrateOpenDatabase(databasePath);

    expect(File(databasePath).existsSync(), isTrue);
  });
}
