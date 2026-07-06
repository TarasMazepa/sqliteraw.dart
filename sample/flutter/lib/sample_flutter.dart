import 'package:sample_flutter/models/crud_demonstration_result.dart';
import 'package:sample_flutter/models/example_results.dart';
import 'package:sample_flutter/utils/database_paths.dart';
import 'package:sample_flutter/example/backup.dart';
import 'package:sample_flutter/example/create_and_crud.dart';
import 'package:sample_flutter/example/open_database.dart';
import 'package:sqliteraw/sqliteraw.dart';

String version() {
  return SQLITE_VERSION;
}

Future<FlutterExampleResults> runAllExamples({String? directoryPath}) async {
  final String openPath = await _databasePath(directoryPath: directoryPath, fileName: 'open_example.db');
  demonstrateOpenDatabase(openPath);

  final String crudPath = await _databasePath(directoryPath: directoryPath, fileName: 'crud_example.db');
  final CrudDemonstrationResult crudResult = demonstrateCreateAndCrud(crudPath);

  final String sourcePath = await _databasePath(directoryPath: directoryPath, fileName: 'backup_source.db');
  final String backupPath = await _databasePath(directoryPath: directoryPath, fileName: 'backup_copy.db');
  demonstrateCreateAndCrud(sourcePath);
  backupDatabase(sourcePath: sourcePath, destinationPath: backupPath);

  return FlutterExampleResults(
    openDatabasePath: openPath,
    crudResult: crudResult,
    backupDatabasePath: backupPath,
  );
}

Future<String> _databasePath({required String? directoryPath, required String fileName}) async {
  if (directoryPath != null) {
    return databasePathInDirectory(directoryPath, fileName);
  }
  return applicationDatabasePath(fileName);
}
