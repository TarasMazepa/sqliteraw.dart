import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:sqliteraw/sqliteraw.dart' as sr;
import 'package:sqliteraw_sample_dart/example/open_database.dart';
import 'package:sqliteraw_sample_dart/sqlite_helpers.dart';
import 'package:sqliteraw_sample_dart/todo_item.dart';

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
  final Pointer<sr.sqlite3_stmt> stmt = prepareStatement(
    db,
    'insert into todos (title) values (?);',
  );
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
  final Pointer<sr.sqlite3_stmt> stmt = prepareStatement(
    db,
    'select id, title, done from todos order by id;',
  );
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

void updateTodoDone(Pointer<sr.sqlite3> db, int id, bool done) {
  final Pointer<sr.sqlite3_stmt> stmt = prepareStatement(
    db,
    'update todos set done = ? where id = ?;',
  );
  try {
    bindInt(stmt, 1, done ? 1 : 0);
    bindInt(stmt, 2, id);
    final stepResult = sr.sqlite3_step(stmt);
    checkSqliteResult(stepResult, db, 'update todo');
  } finally {
    finalizeStatement(stmt);
  }
}

void deleteTodo(Pointer<sr.sqlite3> db, int id) {
  final Pointer<sr.sqlite3_stmt> stmt = prepareStatement(
    db,
    'delete from todos where id = ?;',
  );
  try {
    bindInt(stmt, 1, id);
    final stepResult = sr.sqlite3_step(stmt);
    checkSqliteResult(stepResult, db, 'delete todo');
  } finally {
    finalizeStatement(stmt);
  }
}

/// Demonstrates creating a table and performing insert, read, update, delete.
List<TodoItem> demonstrateCreateAndCrud(String path) {
  final Pointer<sr.sqlite3> db = openDatabaseFile(path);
  try {
    createTodosTable(db);

    final int firstId = insertTodo(db, 'Buy milk');
    final int secondId = insertTodo(db, 'Write samples');
    updateTodoDone(db, firstId, true);
    deleteTodo(db, secondId);

    return selectTodos(db);
  } finally {
    closeDatabase(db);
  }
}
