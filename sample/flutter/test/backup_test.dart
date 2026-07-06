import 'dart:ffi';
import 'dart:io';

import 'package:sample_flutter/example/backup.dart';
import 'package:sample_flutter/example/create_and_crud.dart';
import 'package:sample_flutter/utils/sqlite_helpers.dart';
import 'package:sqliteraw/sqliteraw.dart' as sr;
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tempDir;
  late String sourcePath;
  late String destinationPath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sqliteraw_flutter_backup_test_');
    sourcePath = '${tempDir.path}/source.db';
    destinationPath = '${tempDir.path}/backup.db';
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('backupDatabase copies data to a new file', () {
    demonstrateCreateAndCrud(sourcePath);
    backupDatabase(sourcePath: sourcePath, destinationPath: destinationPath);

    expect(File(destinationPath).existsSync(), isTrue);

    final Pointer<sr.sqlite3> backupDb = openDatabase(destinationPath, create: false);
    try {
      final todos = selectTodos(backupDb);
      expect(todos, hasLength(1));
      expect(todos.first.title, 'Buy milk');
      expect(todos.first.done, isFalse);
    } finally {
      closeDatabase(backupDb);
    }
  });
}
