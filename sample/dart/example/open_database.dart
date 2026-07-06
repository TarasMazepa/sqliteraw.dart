import 'dart:io';

import 'package:sqliteraw_sample_dart/crud/open_database.dart';

void main(List<String> arguments) {
  final String path = arguments.isNotEmpty
      ? arguments.first
      : '${Directory.systemTemp.path}/sqliteraw_open_example.db';

  demonstrateOpenDatabase(path);
  stdout.writeln('Opened and closed database at $path');
}
