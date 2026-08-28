import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'wasm_module.dart';

const int sqliteOk = 0;
const int sqliteRow = 100;

/// WebAssembly-backed access to the sqliteraw C API.
final class SqliterawWeb {
  SqliterawWeb._(this._module);

  final SqliterawWasmModule _module;
  static SqliterawWeb? _instance;

  static const wasmAssetPath = 'assets/packages/sqliteraw/wasm/out/sqliteraw.wasm';

  static Future<SqliterawWeb> open({String? wasmUrl}) async {
    if (_instance != null) {
      return _instance!;
    }

    final resolvedUrl = wasmUrl ?? sqliterawWasmUrlFromBase();
    final module = await SqliterawWasmModule.loadFromUrl(resolvedUrl);
    final initResult = module.callReturningInt('sqlite3_initialize');
    if (initResult != sqliteOk) {
      throw StateError('sqlite3_initialize failed: $initResult');
    }
    _instance = SqliterawWeb._(module);
    return _instance!;
  }

  String sqlite3Libversion() {
    final pointer = _module.callReturningPointer('sqlite3_libversion');
    return _module.readCString(pointer);
  }

  int sqlite3OpenMemdb() {
    final openResult = _module.callReturningInt('sqliteraw_open_memdb', [
      SqliterawWasmModule.nullPointer,
    ]);
    if (openResult != sqliteOk) {
      return openResult;
    }
    if (activeDatabaseHandle() == SqliterawWasmModule.nullPointer) {
      throw StateError('sqliteraw_open_memdb returned ok but active db handle is null');
    }
    return openResult;
  }

  int sqlite3Exec(int database, String sql) {
    _module.sendSql(sql);
    return _module.callReturningInt('sqliteraw_exec_buffered');
  }

  String sqlite3Errmsg(int database) {
    final pointer = _module.callReturningPointer('sqliteraw_errmsg_ptr');
    return _module.readCString(pointer);
  }

  int sqlite3Changes(int database) {
    return _module.callReturningInt('sqliteraw_changes');
  }

  int sqlite3PrepareV2(int database, String sql, {int statementOutPointer = 0}) {
    _module.sendSql(sql);
    return _module.callReturningInt('sqliteraw_prepare_buffered');
  }

  int sqlite3Step(int statement) {
    return _module.callReturningInt('sqliteraw_step');
  }

  int sqlite3ColumnInt(int statement, int index) {
    return _module.callReturningInt('sqliteraw_column_int', [index]);
  }

  String sqlite3ColumnText(int statement, int index) {
    final pointer = _module.callReturningPointer('sqliteraw_column_text_ptr', [index]);
    return _module.readCString(pointer);
  }

  int sqlite3Finalize(int statement) {
    return _module.callReturningInt('sqliteraw_finalize');
  }

  int sqlite3Close(int database) {
    return _module.callReturningInt('sqliteraw_close');
  }

  int activeDatabaseHandle() {
    return _module.callReturningInt('sqliteraw_db_handle');
  }
}

/// Resolves a wasm URL relative to the current web page.
String sqliterawWasmUrlFromBase({String assetPath = SqliterawWeb.wasmAssetPath}) {
  return web.URL(assetPath, (globalContext['location'] as web.URL).href).href;
}
