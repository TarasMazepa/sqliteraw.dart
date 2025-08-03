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
