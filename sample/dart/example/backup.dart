import 'dart:io';

import 'package:sqliteraw_sample_dart/crud/backup.dart';
import 'package:sqliteraw_sample_dart/crud/create_and_crud.dart';

void main(List<String> arguments) {
  final String sourcePath = arguments.isNotEmpty
      ? arguments.first
      : '${Directory.systemTemp.path}/sqliteraw_backup_source.db';
  final String destinationPath = arguments.length > 1
      ? arguments[1]
      : '${Directory.systemTemp.path}/sqliteraw_backup_copy.db';

  demonstrateCreateAndCrud(sourcePath);
  backupDatabase(sourcePath: sourcePath, destinationPath: destinationPath);

  stdout.writeln('Backed up $sourcePath to $destinationPath');
}
