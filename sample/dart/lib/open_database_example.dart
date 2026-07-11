import 'open_database_example_web.dart' if (dart.library.ffi) 'open_database_example_native.dart' as platform;

Future<List<String>> runOpenDatabaseExample() => platform.runOpenDatabaseExample();
