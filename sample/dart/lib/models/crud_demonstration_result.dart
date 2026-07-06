import 'package:sqliteraw_sample_dart/models/todo_item.dart';

class CrudDemonstrationResult {
  const CrudDemonstrationResult({
    required this.afterInsert,
    required this.afterUpdate,
    required this.afterDelete,
  });

  final List<TodoItem> afterInsert;
  final List<TodoItem> afterUpdate;
  final List<TodoItem> afterDelete;
}
