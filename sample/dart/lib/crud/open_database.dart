import 'dart:ffi';

import 'package:sqliteraw/sqliteraw.dart' as sr;
import 'package:sqliteraw_sample_dart/utils/sqlite_helpers.dart';

/// Opens a SQLite database at [path], creating it if it does not exist.
///
/// Caller must call [closeDatabase] when done.
Pointer<sr.sqlite3> openDatabaseFile(String path) {
  return openDatabase(path);
}

/// Demonstrates opening and closing a database file.
void demonstrateOpenDatabase(String path) {
  final Pointer<sr.sqlite3> db = openDatabaseFile(path);
  try {
    executeSql(db, 'PRAGMA user_version;');
  } finally {
    closeDatabase(db);
  }
}
