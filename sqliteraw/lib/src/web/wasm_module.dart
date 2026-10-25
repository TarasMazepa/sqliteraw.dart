import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Loads and instantiates the sqliteraw WebAssembly module.
final class SqliterawWasmModule {
  SqliterawWasmModule._(this._instance);

  static const nullPointer = 0;

  final web.Instance _instance;

  static Future<SqliterawWasmModule> loadFromUrl(String url) async {
    final jsUri = web.URL(url, (globalContext['location'] as web.URL).href);
    final module = await web.WebAssembly.instantiateStreaming(
      web.window.fetch(jsUri),
      JSObject(),
    ).toDart;

    return _fromInstantiatedSource(module);
  }

  static Future<SqliterawWasmModule> loadFromBytes(Uint8List bytes, String debugName) async {
    final module = await web.WebAssembly.instantiate(
      bytes.toJS,
      JSObject(),
    ).toDart;

    return _fromInstantiatedSource(module as web.WebAssemblyInstantiatedSource);
  }

  static SqliterawWasmModule _fromInstantiatedSource(web.WebAssemblyInstantiatedSource module) {
    final instance = module.instance;
    final exports = instance.exports;
    if (exports.has('_initialize')) {
      (exports['_initialize'] as JSFunction).callAsFunction();
    }

    return SqliterawWasmModule._(instance);
  }

  void sendSql(String sql) {
    callVoid('sqliteraw_sql_clear');
    for (final byte in utf8.encode(sql)) {
      callVoid('sqliteraw_sql_append_byte', [byte]);
    }
  }

  int callReturningInt(String exportName, [List<Object?> args = const []]) {
    return _toDartInt(_call(exportName, args));
  }

  int callReturningPointer(String exportName, [List<Object?> args = const []]) {
    return callReturningInt(exportName, args);
  }

  void callVoid(String exportName, [List<Object?> args = const []]) {
    _call(exportName, args);
  }

  Object? _call(String exportName, List<Object?> args) {
    final exportValue = _instance.exports[exportName];
    if (exportValue == null) {
      throw StateError('sqliteraw.wasm is missing export: $exportName');
    }

    final function = exportValue as JSFunction;
    return switch (args.length) {
      0 => function.callAsFunction(),
      1 => function.callAsFunction(_toJs(args[0])),
      2 => function.callAsFunction(_toJs(args[0]), _toJs(args[1])),
      3 => function.callAsFunction(_toJs(args[0]), _toJs(args[1]), _toJs(args[2])),
      4 => function.callAsFunction(
        _toJs(args[0]),
        _toJs(args[1]),
        _toJs(args[2]),
        _toJs(args[3]),
      ),
      5 => function.callAsFunction(
        _toJs(args[0]),
        _toJs(args[1]),
        _toJs(args[2]),
        _toJs(args[3]),
        _toJs(args[4]),
      ),
      _ => throw ArgumentError('Unsupported argument count: ${args.length}'),
    };
  }

  JSAny? _toJs(Object? value) {
    return switch (value) {
      null => nullPointer.toJS,
      final int i => (i & 0xFFFFFFFF).toJS,
      final double d => d.toJS,
      final String s => s.toJS,
      _ => throw ArgumentError('Unsupported wasm argument: $value'),
    };
  }

  int _toDartInt(Object? value) {
    if (value == null) {
      return 0;
    }
    final dart = (value as JSAny).dartify();
    return switch (dart) {
      final int i => i,
      final num n => n.toInt(),
      _ => throw StateError('Expected numeric wasm return, got $dart'),
    };
  }

  String readCString(int address) {
    if (address == nullPointer) {
      return '';
    }

    final bytes = <int>[];
    while (true) {
      final byte = callReturningInt('sqliteraw_memory_read', [address + bytes.length]);
      if (byte == 0) {
        break;
      }
      bytes.add(byte);
    }
    return utf8.decode(bytes);
  }
}
