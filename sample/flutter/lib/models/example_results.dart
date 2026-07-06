import 'package:sample_flutter/models/crud_demonstration_result.dart';

class FlutterExampleResults {
  const FlutterExampleResults({
    required this.openDatabasePath,
    required this.crudResult,
    required this.backupDatabasePath,
  });

  final String openDatabasePath;
  final CrudDemonstrationResult crudResult;
  final String backupDatabasePath;
}
