import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:sample_flutter/example/open_database.dart';
import 'package:sample_flutter/utils/sqlite_helpers.dart';
import 'package:sample_flutter/models/crud_demonstration_result.dart';
import 'package:sample_flutter/models/todo_item.dart';
import 'package:sqliteraw/sqliteraw.dart' as sr;

const String createTodosTableSql = '''
create table if not exists todos (
  id integer primary key autoincrement,
  title text not null,
  done integer not null default 0
);
''';

void createTodosTable(Pointer<sr.sqlite3> db) {
  executeSql(db, createTodosTableSql);
}

int insertTodo(Pointer<sr.sqlite3> db, String title) {
  final Pointer<sr.sqlite3_stmt> stmt = prepareStatement(db, 'insert into todos (title) values (?);');
  try {
    bindText(stmt, 1, title);
    final stepResult = sr.sqlite3_step(stmt);
    checkSqliteResult(stepResult, db, 'insert todo');
    return sr.sqlite3_last_insert_rowid(db);
  } finally {
    finalizeStatement(stmt);
  }
}

List<TodoItem> selectTodos(Pointer<sr.sqlite3> db) {
  final Pointer<sr.sqlite3_stmt> stmt = prepareStatement(db, 'select id, title, done from todos order by id;');
  final List<TodoItem> todos = [];
  try {
    while (true) {
      final stepResult = sr.sqlite3_step(stmt);
      if (stepResult == sr.SQLITE_DONE) {
        break;
      }
      checkSqliteResult(stepResult, db, 'select todos');
      todos.add(
        TodoItem(
          id: sr.sqlite3_column_int(stmt, 0),
          title: sr.sqlite3_column_text(stmt, 1).cast<Utf8>().toDartString(),
          done: sr.sqlite3_column_int(stmt, 2) != 0,
        ),
      );
    }
    return todos;
  } finally {
    finalizeStatement(stmt);
  }
}

void updateTodo(Pointer<sr.sqlite3> db, int id, {required bool done, required String title}) {
  final Pointer<sr.sqlite3_stmt> stmt = prepareStatement(db, 'update todos set done = ?, title = ? where id = ?;');
  try {
    bindInt(stmt, 1, done ? 1 : 0);
    bindText(stmt, 2, title);
    bindInt(stmt, 3, id);
    final stepResult = sr.sqlite3_step(stmt);
    checkSqliteResult(stepResult, db, 'update todo');
  } finally {
    finalizeStatement(stmt);
  }
}

void deleteTodo(Pointer<sr.sqlite3> db, int id) {
  final Pointer<sr.sqlite3_stmt> stmt = prepareStatement(db, 'delete from todos where id = ?;');
  try {
    bindInt(stmt, 1, id);
    final stepResult = sr.sqlite3_step(stmt);
    checkSqliteResult(stepResult, db, 'delete todo');
  } finally {
    finalizeStatement(stmt);
  }
}

String formatTodoList(List<TodoItem> todos) {
  if (todos.isEmpty) {
    return '  (no todos)';
  }
  return todos.map((todo) => '  [${todo.done ? '✅' : ' '}] ${todo.id}: ${todo.title}').join('\n');
}

/// Demonstrates creating a table, inserting todos, listing, updating, and deleting.
CrudDemonstrationResult demonstrateCreateAndCrud(String path) {
  final Pointer<sr.sqlite3> db = openDatabaseFile(path);
  try {
    createTodosTable(db);

    insertTodo(db, 'Buy milk');
    insertTodo(db, 'Write samples');
    final List<TodoItem> afterInsert = selectTodos(db);

    final TodoItem todoToUpdate = afterInsert.last;
    updateTodo(db, todoToUpdate.id, done: true, title: '${todoToUpdate.title} Updated');
    final List<TodoItem> afterUpdate = selectTodos(db);

    final int deleteId = afterInsert.last.id;
    deleteTodo(db, deleteId);
    final List<TodoItem> afterDelete = selectTodos(db);

    return CrudDemonstrationResult(afterInsert: afterInsert, afterUpdate: afterUpdate, afterDelete: afterDelete);
  } finally {
    closeDatabase(db);
  }
}
