import 'dart:io';

import 'package:test/test.dart';

import '../bin/sqliteraw_sample_dart.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('sqliteraw_run_examples_test_');
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('runAllExamples creates open, crud, and backup database files', () {
    runAllExamples(directoryPath: tempDir.path);

    expect(File('${tempDir.path}/sqliteraw_open_example.db').existsSync(), isTrue);
    expect(File('${tempDir.path}/sqliteraw_crud_example.db').existsSync(), isTrue);
    expect(File('${tempDir.path}/sqliteraw_backup_source.db').existsSync(), isTrue);
    expect(File('${tempDir.path}/sqliteraw_backup_copy.db').existsSync(), isTrue);
  });
}
