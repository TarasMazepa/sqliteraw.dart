import 'dart:io';

import 'package:sqliteraw_sample_dart/example/create_and_crud.dart';
import 'package:sqliteraw_sample_dart/todo_item.dart';

void main(List<String> arguments) {
  final String path = arguments.isNotEmpty
      ? arguments.first
      : '${Directory.systemTemp.path}/sqliteraw_crud_example.db';

  final List<TodoItem> todos = demonstrateCreateAndCrud(path);
  stdout.writeln('Database at $path contains ${todos.length} todo(s):');
  for (final TodoItem todo in todos) {
    stdout.writeln('  [${todo.done ? 'x' : ' '}] ${todo.id}: ${todo.title}');
  }
}
