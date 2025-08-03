
import 'package:dart/dart.dart' as dart;
import 'package:test/test.dart';

void main() {
  group('SQLite Version Tests', () {
    test('version() returns valid compile-time SQLite version', () {
      final version = dart.version();
      expect(version, isNotEmpty);
      expect(version, matches(RegExp(r'^\d+\.\d+\.\d+')));
    });

    test('versionFromLibrary() returns valid runtime SQLite version via FFI', () {
      final version = dart.versionFromLibrary();
      expect(version, isNotEmpty);
      expect(version, matches(RegExp(r'^\d+\.\d+\.\d+')));
    });

    test('both version functions return the same value', () {
      final compileTimeVersion = dart.version();
      final runtimeVersion = dart.versionFromLibrary();
      expect(compileTimeVersion, equals(runtimeVersion));
    });
  });
}
