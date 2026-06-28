import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    await CBuilder.library(
      name: 'sqliteraw',
      assetName: 'sqliteraw.dart',
      sources: ['../sqlite/sqlite3.c'],
      defines: {
        'SQLITE_ENABLE_FTS4': null,
        'SQLITE_ENABLE_FTS5': null,
        'SQLITE_ENABLE_RTREE': null,
        'SQLITE_ENABLE_GEOPOLY': null,
      },
    ).run(input: input, output: output);
  });
}
