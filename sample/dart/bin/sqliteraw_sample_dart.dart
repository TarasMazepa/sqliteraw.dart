import 'dart:io';

import 'package:sqliteraw/sqliteraw.dart';
import 'package:sqliteraw_sample_dart/crud/backup.dart';
import 'package:sqliteraw_sample_dart/crud/create_and_crud.dart';
import 'package:sqliteraw_sample_dart/crud/open_database.dart';
import 'package:sqliteraw_sample_dart/models/crud_demonstration_result.dart';

void main(List<String> arguments) {
  runAllExamples(directoryPath: arguments.isNotEmpty ? arguments.first : null);
}

void runAllExamples({String? directoryPath}) {
  final String baseDirectory = directoryPath ?? Directory.systemTemp.path;

  stdout.writeln('sqliteraw $SQLITE_VERSION');
  stdout.writeln();

  final String openPath = '$baseDirectory/sqliteraw_open_example.db';
  stdout.writeln('> dart run example/open_database.dart $openPath');
  demonstrateOpenDatabase(openPath);
  stdout.writeln('Opened and closed database at $openPath');
  stdout.writeln();

  final String crudPath = '$baseDirectory/sqliteraw_crud_example.db';
  stdout.writeln('> dart run example/create_and_crud.dart $crudPath');
  final CrudDemonstrationResult crudResult = demonstrateCreateAndCrud(crudPath);
  stdout.writeln('After insert:');
  stdout.writeln(formatTodoList(crudResult.afterInsert));
  stdout.writeln('After update:');
  stdout.writeln(formatTodoList(crudResult.afterUpdate));
  stdout.writeln('After delete:');
  stdout.writeln(formatTodoList(crudResult.afterDelete));
  stdout.writeln();

  final String sourcePath = '$baseDirectory/sqliteraw_backup_source.db';
  final String destinationPath = '$baseDirectory/sqliteraw_backup_copy.db';
  stdout.writeln('> dart run example/backup.dart $sourcePath $destinationPath');
  demonstrateCreateAndCrud(sourcePath);
  backupDatabase(sourcePath: sourcePath, destinationPath: destinationPath);
  stdout.writeln('Backed up $sourcePath to $destinationPath');
}
