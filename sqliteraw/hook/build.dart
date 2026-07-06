import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

List<String> sqliteLibraries(OS targetOS) {
  return switch (targetOS) {
    OS.linux => ['m', 'dl', 'pthread'],
    OS.android => ['m', 'dl'],
    _ => ['m'],
  };
}

void main(List<String> args) async {
  await build(args, (input, output) async {
    await CBuilder.library(
      name: 'sqliteraw',
      assetName: 'sqliteraw.dart',
      sources: ['../sqlite/sqlite3.c'],
      libraries: sqliteLibraries(input.config.code.targetOS),
      defines: {
        'SQLITE_ENABLE_FTS4': null,
        'SQLITE_ENABLE_FTS5': null,
        'SQLITE_ENABLE_RTREE': null,
        'SQLITE_ENABLE_GEOPOLY': null,
      },
    ).run(
      input: input,
      output: output,
      defines: {if (input.config.code.targetOS == OS.windows) 'SQLITE_API': '__declspec(dllexport)'},
    );
  });
}
