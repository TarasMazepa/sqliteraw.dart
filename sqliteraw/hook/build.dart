import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final builder = CBuilder.library(
      name: 'sqliteraw',
      assetName: 'sqliteraw.dart',
      sources: [
        '../sqlite/sqlite3.c',
      ],
      defines: {
        'SQLITE_THREADSAFE': '1',
        'SQLITE_ENABLE_FTS5': '1',
        'SQLITE_ENABLE_JSON1': '1',
      },
    );
    await builder.run(
      input: input,
      output: output,
    );
  });
}
