import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:sample_flutter/utils/sqlite_exception.dart';
import 'package:sqliteraw/sqliteraw.dart' as sr;

typedef SqliteDestructor = Void Function(Pointer<Void>);

final Pointer<NativeFunction<SqliteDestructor>> sqliteTransient =
    Pointer.fromAddress(-1);

Pointer<sr.sqlite3> openDatabase(
  String path, {
  bool create = true,
}) {
  final pathNative = path.toNativeUtf8();
  final dbOut = calloc<Pointer<sr.sqlite3>>();
  try {
    final flags = create
        ? sr.SQLITE_OPEN_READWRITE | sr.SQLITE_OPEN_CREATE
        : sr.SQLITE_OPEN_READONLY;
    final resultCode = sr.sqlite3_open_v2(
      pathNative.cast(),
      dbOut,
      flags,
      nullptr,
    );
    checkSqliteResult(resultCode, dbOut.value, 'open database');
    return dbOut.value;
  } finally {
    calloc.free(pathNative);
    calloc.free(dbOut);
  }
}

void closeDatabase(Pointer<sr.sqlite3> db) {
  final resultCode = sr.sqlite3_close_v2(db);
  checkSqliteResult(resultCode, db, 'close database');
}

void executeSql(Pointer<sr.sqlite3> db, String sql) {
  final sqlNative = sql.toNativeUtf8();
  final errMsgOut = calloc<Pointer<Char>>();
  try {
    final resultCode = sr.sqlite3_exec(
      db,
      sqlNative.cast(),
      nullptr,
      nullptr,
      errMsgOut,
    );
    if (resultCode != sr.SQLITE_OK) {
      final message = errMsgOut.value != nullptr
          ? errMsgOut.value.cast<Utf8>().toDartString()
          : sr.sqlite3_errmsg(db).cast<Utf8>().toDartString();
      throw SqliteException(resultCode, 'execute SQL failed: $message');
    }
  } finally {
    calloc.free(sqlNative);
    if (errMsgOut.value != nullptr) {
      sr.sqlite3_free(errMsgOut.value.cast());
    }
    calloc.free(errMsgOut);
  }
}

Pointer<sr.sqlite3_stmt> prepareStatement(
  Pointer<sr.sqlite3> db,
  String sql,
) {
  final sqlNative = sql.toNativeUtf8();
  final stmtOut = calloc<Pointer<sr.sqlite3_stmt>>();
  try {
    final resultCode = sr.sqlite3_prepare_v2(
      db,
      sqlNative.cast(),
      -1,
      stmtOut,
      nullptr,
    );
    checkSqliteResult(resultCode, db, 'prepare statement');
    return stmtOut.value;
  } finally {
    calloc.free(sqlNative);
    calloc.free(stmtOut);
  }
}

void bindText(Pointer<sr.sqlite3_stmt> stmt, int index, String value) {
  final valueNative = value.toNativeUtf8();
  try {
    final resultCode = sr.sqlite3_bind_text(
      stmt,
      index,
      valueNative.cast(),
      -1,
      sqliteTransient,
    );
    checkSqliteResult(resultCode, null, 'bind text');
  } finally {
    calloc.free(valueNative);
  }
}

void bindInt(Pointer<sr.sqlite3_stmt> stmt, int index, int value) {
  final resultCode = sr.sqlite3_bind_int(stmt, index, value);
  checkSqliteResult(resultCode, null, 'bind int');
}

void finalizeStatement(Pointer<sr.sqlite3_stmt> stmt) {
  final resultCode = sr.sqlite3_finalize(stmt);
  checkSqliteResult(resultCode, null, 'finalize statement');
}

void checkSqliteResult(
  int resultCode,
  Pointer<sr.sqlite3>? db,
  String operation,
) {
  if (resultCode == sr.SQLITE_OK ||
      resultCode == sr.SQLITE_ROW ||
      resultCode == sr.SQLITE_DONE) {
    return;
  }

  final String message;
  if (db != null && db != nullptr) {
    message = sr.sqlite3_errmsg(db).cast<Utf8>().toDartString();
  } else {
    message = sr.sqlite3_errstr(resultCode).cast<Utf8>().toDartString();
  }
  throw SqliteException(resultCode, '$operation failed: $message');
}
