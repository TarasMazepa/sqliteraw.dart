import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:sqliteraw/sqliteraw.dart' as sr;
import 'package:sqliteraw_sample_dart/sqlite_helpers.dart';

/// Copies all data from [sourcePath] into [destinationPath] using the
/// sqlite3 online backup API.
void backupDatabase({
  required String sourcePath,
  required String destinationPath,
}) {
  final Pointer<sr.sqlite3> sourceDb = openDatabase(sourcePath, create: false);
  Pointer<sr.sqlite3>? destinationDb;
  try {
    destinationDb = openDatabase(destinationPath);

    final Pointer<Utf8> destinationName = 'main'.toNativeUtf8();
    final Pointer<Utf8> sourceName = 'main'.toNativeUtf8();
    try {
      final Pointer<sr.sqlite3_backup> backup = sr.sqlite3_backup_init(
        destinationDb,
        destinationName.cast(),
        sourceDb,
        sourceName.cast(),
      );
      if (backup == nullptr) {
        checkSqliteResult(sr.sqlite3_errcode(destinationDb), destinationDb, 'backup init');
      }

      try {
        final int stepResult = sr.sqlite3_backup_step(backup, -1);
        if (stepResult != sr.SQLITE_DONE) {
          checkSqliteResult(stepResult, destinationDb, 'backup step');
        }

        final int finishResult = sr.sqlite3_backup_finish(backup);
        checkSqliteResult(finishResult, destinationDb, 'backup finish');
      } catch (error) {
        sr.sqlite3_backup_finish(backup);
        rethrow;
      }
    } finally {
      calloc.free(destinationName);
      calloc.free(sourceName);
    }
  } finally {
    closeDatabase(sourceDb);
    if (destinationDb != null) {
      closeDatabase(destinationDb);
    }
  }
}
