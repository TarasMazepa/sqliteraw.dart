import 'dart:io';

import 'package:sqliteraw_sample_dart/crud/create_and_crud.dart';
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

  test('demonstrateCreateAndCrud inserts, lists, updates, and deletes todos', () {
    final result = demonstrateCreateAndCrud(databasePath);

    expect(result.afterInsert, hasLength(2));
    expect(result.afterInsert.first.title, 'Buy milk');
    expect(result.afterInsert.first.done, isFalse);
    expect(result.afterInsert.last.title, 'Write samples');

    expect(result.afterUpdate, hasLength(2));
    expect(result.afterUpdate.first.title, 'Buy milk');
    expect(result.afterUpdate.first.done, isFalse);
    expect(result.afterUpdate.last.title, 'Write samples Updated');
    expect(result.afterUpdate.last.done, isTrue);

    expect(result.afterDelete, hasLength(1));
    expect(result.afterDelete.first.title, 'Buy milk');
    expect(result.afterDelete.first.done, isFalse);
  });
}
