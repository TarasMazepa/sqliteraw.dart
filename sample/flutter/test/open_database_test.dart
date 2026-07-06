import 'dart:io';

import 'package:sample_flutter/example/open_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late String databasePath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sqliteraw_flutter_open_test_');
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
