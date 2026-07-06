import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<String> applicationDatabasePath(String fileName) async {
  final directory = await getApplicationDocumentsDirectory();
  return p.join(directory.path, fileName);
}

String databasePathInDirectory(String directoryPath, String fileName) {
  return p.join(directoryPath, fileName);
}
