import 'dart:io';

import 'package:sqliteraw/sqliteraw.dart';
import 'package:sqliteraw_sample_dart/crud/backup.dart';
import 'package:sqliteraw_sample_dart/crud/create_and_crud.dart';
import 'package:sqliteraw_sample_dart/crud/open_database.dart';
import 'package:sqliteraw_sample_dart/models/todo_item.dart';

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
  final List<TodoItem> todos = demonstrateCreateAndCrud(crudPath);
  stdout.writeln('Database at $crudPath contains ${todos.length} todo(s):');
  for (final TodoItem todo in todos) {
    stdout.writeln('  [${todo.done ? 'x' : ' '}] ${todo.id}: ${todo.title}');
  }
  stdout.writeln();

  final String sourcePath = '$baseDirectory/sqliteraw_backup_source.db';
  final String destinationPath = '$baseDirectory/sqliteraw_backup_copy.db';
  stdout.writeln('> dart run example/backup.dart $sourcePath $destinationPath');
  demonstrateCreateAndCrud(sourcePath);
  backupDatabase(sourcePath: sourcePath, destinationPath: destinationPath);
  stdout.writeln('Backed up $sourcePath to $destinationPath');
}
