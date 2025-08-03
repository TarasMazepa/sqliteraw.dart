import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:sqliteraw.dart/sqliteraw.dart';

String version() {
  return SQLITE_VERSION;
}

String versionFromLibrary() {
  final library = Platform.isLinux
      ? DynamicLibrary.open('assets/libsqlite3.so')
      : Platform.isWindows
          ? DynamicLibrary.open('assets/sqlite3.dll')
          : DynamicLibrary.open('assets/libsqlite3.dylib');
  
  final sqlite = NativeLibrary(library);
  return sqlite.sqlite3_libversion().cast<Utf8>().toDartString();
}

String versionFromSqlQuery() {
  final library = Platform.isLinux
      ? DynamicLibrary.open('assets/libsqlite3.so')
      : Platform.isWindows
          ? DynamicLibrary.open('assets/sqlite3.dll')
          : DynamicLibrary.open('assets/libsqlite3.dylib');
  
  final sqlite = NativeLibrary(library);
  
  // Open an in-memory database
  final dbPtr = calloc<Pointer<sqlite3>>();
  final result = sqlite.sqlite3_open(":memory:".toNativeUtf8().cast(), dbPtr);
  
  if (result != SQLITE_OK) {
    calloc.free(dbPtr);
    throw Exception('Failed to open database: $result');
  }
  
  final db = dbPtr.value;
  
  try {
    // Prepare the SQL statement
    final stmtPtr = calloc<Pointer<sqlite3_stmt>>();
    final prepareResult = sqlite.sqlite3_prepare_v2(
      db,
      "SELECT sqlite_version();".toNativeUtf8().cast(),
      -1,
      stmtPtr,
      nullptr,
    );
    
    if (prepareResult != SQLITE_OK) {
      throw Exception('Failed to prepare statement: $prepareResult');
    }
    
    final stmt = stmtPtr.value;
    
    try {
      // Execute the statement
      final stepResult = sqlite.sqlite3_step(stmt);
      
      if (stepResult == SQLITE_ROW) {
        // Get the result
        final versionPtr = sqlite.sqlite3_column_text(stmt, 0);
        final version = versionPtr.cast<Utf8>().toDartString();
        return version;
      } else {
        throw Exception('Failed to execute query: $stepResult');
      }
    } finally {
      sqlite.sqlite3_finalize(stmt);
      calloc.free(stmtPtr);
    }
  } finally {
    sqlite.sqlite3_close(db);
    calloc.free(dbPtr);
  }
}
