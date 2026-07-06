import 'dart:io';

import 'package:sqliteraw_sample_dart/example/create_and_crud.dart';
import 'package:sqliteraw_sample_dart/todo_item.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String databasePath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sqliteraw_crud_test_');
    databasePath = '${tempDir.path}/test.db';
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('demonstrateCreateAndCrud inserts, updates, and deletes todos', () {
    final List<TodoItem> todos = demonstrateCreateAndCrud(databasePath);

    expect(todos, hasLength(1));
    expect(todos.first.title, 'Buy milk');
    expect(todos.first.done, isTrue);
  });
}
