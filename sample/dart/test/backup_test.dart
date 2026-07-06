import 'dart:ffi';
import 'dart:io';

import 'package:sqliteraw/sqliteraw.dart' as sr;
import 'package:sqliteraw_sample_dart/example/backup.dart';
import 'package:sqliteraw_sample_dart/example/create_and_crud.dart';
import 'package:sqliteraw_sample_dart/sqlite_helpers.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String sourcePath;
  late String destinationPath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sqliteraw_backup_test_');
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
      expect(todos.first.done, isTrue);
    } finally {
      closeDatabase(backupDb);
    }
  });
}
