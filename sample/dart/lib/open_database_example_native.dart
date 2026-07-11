import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:sqliteraw/sqliteraw_native.dart';

/// Runs the open database sample and returns the printed lines.
Future<List<String>> runOpenDatabaseExample() async {
  final lines = <String>[];

  lines.add('SQLite ${sqlite3_libversion().cast<Utf8>().toDartString()}');

  final database = calloc<Pointer<sqlite3>>();
  try {
    const databasePath = ':memory:';
    final path = databasePath.toNativeUtf8();
    try {
      final openResult = sqlite3_open(path.cast(), database);
      if (openResult != SQLITE_OK) {
        throw StateError('sqlite3_open failed: $openResult');
      }
      lines.add('\nOpen database: path=$databasePath, result=$openResult');
    } finally {
      calloc.free(path);
    }

    final db = database.value;

    const tableName = 'todos';
    const createTableStatement = '''
      create table todos (
        id integer primary key,
        title text not null
      )
    ''';
    final createTableSql = createTableStatement.toNativeUtf8();
    try {
      final createTableResult = sqlite3_exec(db, createTableSql.cast(), nullptr, nullptr, nullptr);
      if (createTableResult != SQLITE_OK) {
        throw StateError(
          'sqlite3_exec failed: $createTableResult '
          '${sqlite3_errmsg(db).cast<Utf8>().toDartString()}',
        );
      }
      lines.add(
        '\nCreate table: table=$tableName, columns=(id integer primary key, title text not null), result=$createTableResult',
      );
    } finally {
      calloc.free(createTableSql);
    }

    const firstRecordId = 1;
    const firstRecordTitle = 'Learn sqliteraw';
    final insertSql = "insert into todos (id, title) values ($firstRecordId, '$firstRecordTitle')".toNativeUtf8();
    try {
      final insertResult = sqlite3_exec(db, insertSql.cast(), nullptr, nullptr, nullptr);
      if (insertResult != SQLITE_OK) {
        throw StateError(
          'sqlite3_exec failed: $insertResult '
          '${sqlite3_errmsg(db).cast<Utf8>().toDartString()}',
        );
      }
      lines.add(
        '\nInsert record: id=$firstRecordId, title=$firstRecordTitle, rowsChanged=${sqlite3_changes(db)}, result=$insertResult',
      );
    } finally {
      calloc.free(insertSql);
    }

    const secondRecordId = 2;
    const secondRecordTitle = 'Write more samples';
    final insertSecondSql = "insert into todos (id, title) values ($secondRecordId, '$secondRecordTitle')"
        .toNativeUtf8();
    try {
      final insertSecondResult = sqlite3_exec(db, insertSecondSql.cast(), nullptr, nullptr, nullptr);
      if (insertSecondResult != SQLITE_OK) {
        throw StateError(
          'sqlite3_exec failed: $insertSecondResult '
          '${sqlite3_errmsg(db).cast<Utf8>().toDartString()}',
        );
      }
      lines.add(
        '\nInsert record: id=$secondRecordId, title=$secondRecordTitle, rowsChanged=${sqlite3_changes(db)}, result=$insertSecondResult',
      );
    } finally {
      calloc.free(insertSecondSql);
    }

    const updateRecordId = 1;
    const updatedTitle = 'Learn sqliteraw basics';
    final updateSql = "update todos set title = '$updatedTitle' where id = $updateRecordId".toNativeUtf8();
    try {
      final updateResult = sqlite3_exec(db, updateSql.cast(), nullptr, nullptr, nullptr);
      if (updateResult != SQLITE_OK) {
        throw StateError(
          'sqlite3_exec failed: $updateResult '
          '${sqlite3_errmsg(db).cast<Utf8>().toDartString()}',
        );
      }
      lines.add(
        '\nUpdate record: id=$updateRecordId, title=$updatedTitle, rowsChanged=${sqlite3_changes(db)}, result=$updateResult',
      );
    } finally {
      calloc.free(updateSql);
    }

    const deleteRecordId = 2;
    final deleteSql = 'delete from todos where id = $deleteRecordId'.toNativeUtf8();
    try {
      final deleteResult = sqlite3_exec(db, deleteSql.cast(), nullptr, nullptr, nullptr);
      if (deleteResult != SQLITE_OK) {
        throw StateError(
          'sqlite3_exec failed: $deleteResult '
          '${sqlite3_errmsg(db).cast<Utf8>().toDartString()}',
        );
      }
      lines.add('\nDelete record: id=$deleteRecordId, rowsChanged=${sqlite3_changes(db)}, result=$deleteResult');
    } finally {
      calloc.free(deleteSql);
    }

    final statement = calloc<Pointer<sqlite3_stmt>>();
    try {
      final selectSql = 'select id, title from todos'.toNativeUtf8();
      try {
        final prepareResult = sqlite3_prepare_v2(db, selectSql.cast(), -1, statement, nullptr);
        if (prepareResult != SQLITE_OK) {
          throw StateError(
            'sqlite3_prepare_v2 failed: $prepareResult '
            '${sqlite3_errmsg(db).cast<Utf8>().toDartString()}',
          );
        }

        final stmt = statement.value;
        while (sqlite3_step(stmt) == SQLITE_ROW) {
          final id = sqlite3_column_int(stmt, 0);
          final title = sqlite3_column_text(stmt, 1).cast<Utf8>().toDartString();
          lines.add('\n$id: $title');
        }
      } finally {
        calloc.free(selectSql);
      }

      sqlite3_finalize(statement.value);
    } finally {
      calloc.free(statement);
    }

    final closeResult = sqlite3_close(db);
    if (closeResult != SQLITE_OK) {
      throw StateError('sqlite3_close failed: $closeResult');
    }
    lines.add('\nClose database: path=$databasePath, result=$closeResult');
    database.value = nullptr;
  } finally {
    calloc.free(database);
  }

  return lines;
}
