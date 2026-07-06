import 'dart:io';

import 'package:sqliteraw_sample_dart/crud/create_and_crud.dart';

void main(List<String> arguments) {
  final String path = arguments.isNotEmpty
      ? arguments.first
      : '${Directory.systemTemp.path}/sqliteraw_crud_example.db';

  final result = demonstrateCreateAndCrud(path);
  stdout.writeln('After insert:');
  stdout.writeln(formatTodoList(result.afterInsert));
  stdout.writeln('After update:');
  stdout.writeln(formatTodoList(result.afterUpdate));
  stdout.writeln('After delete:');
  stdout.writeln(formatTodoList(result.afterDelete));
}
