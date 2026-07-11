import 'package:sqliteraw/sqliteraw_web.dart';

/// Runs the open database sample and returns the printed lines.
Future<List<String>> runOpenDatabaseExample() async {
  final lines = <String>[];
  final sqliteraw = await SqliterawWeb.open();

  lines.add('SQLite ${sqliteraw.sqlite3Libversion()}');

  const databasePath = 'file:sqliteraw?mode=memory&vfs=memdb';
  const db = 0;

  final openResult = sqliteraw.sqlite3OpenMemdb();
  if (openResult != sqliteOk) {
    throw StateError(
      'sqliteraw_open_memdb failed: $openResult ${sqliteraw.sqlite3Errmsg(db)}',
    );
  }
  lines.add('\nOpen database: path=$databasePath, result=$openResult');

  const tableName = 'todos';
  const createTableStatement = '''
    create table todos (
      id integer primary key,
      title text not null
    )
  ''';
  final createTableResult = sqliteraw.sqlite3Exec(db, createTableStatement);
  if (createTableResult != sqliteOk) {
    throw StateError(
      'sqlite3_exec failed: $createTableResult ${sqliteraw.sqlite3Errmsg(db)}',
    );
  }
  lines.add(
    '\nCreate table: table=$tableName, columns=(id integer primary key, title text not null), result=$createTableResult',
  );

  const firstRecordId = 1;
  const firstRecordTitle = 'Learn sqliteraw';
  final insertResult = sqliteraw.sqlite3Exec(
    db,
    "insert into todos (id, title) values ($firstRecordId, '$firstRecordTitle')",
  );
  if (insertResult != sqliteOk) {
    throw StateError(
      'sqlite3_exec failed: $insertResult ${sqliteraw.sqlite3Errmsg(db)}',
    );
  }
  lines.add(
    '\nInsert record: id=$firstRecordId, title=$firstRecordTitle, rowsChanged=${sqliteraw.sqlite3Changes(db)}, result=$insertResult',
  );

  const secondRecordId = 2;
  const secondRecordTitle = 'Write more samples';
  final insertSecondResult = sqliteraw.sqlite3Exec(
    db,
    "insert into todos (id, title) values ($secondRecordId, '$secondRecordTitle')",
  );
  if (insertSecondResult != sqliteOk) {
    throw StateError(
      'sqlite3_exec failed: $insertSecondResult ${sqliteraw.sqlite3Errmsg(db)}',
    );
  }
  lines.add(
    '\nInsert record: id=$secondRecordId, title=$secondRecordTitle, rowsChanged=${sqliteraw.sqlite3Changes(db)}, result=$insertSecondResult',
  );

  const updateRecordId = 1;
  const updatedTitle = 'Learn sqliteraw basics';
  final updateResult = sqliteraw.sqlite3Exec(
    db,
    "update todos set title = '$updatedTitle' where id = $updateRecordId",
  );
  if (updateResult != sqliteOk) {
    throw StateError(
      'sqlite3_exec failed: $updateResult ${sqliteraw.sqlite3Errmsg(db)}',
    );
  }
  lines.add(
    '\nUpdate record: id=$updateRecordId, title=$updatedTitle, rowsChanged=${sqliteraw.sqlite3Changes(db)}, result=$updateResult',
  );

  const deleteRecordId = 2;
  final deleteResult = sqliteraw.sqlite3Exec(
    db,
    'delete from todos where id = $deleteRecordId',
  );
  if (deleteResult != sqliteOk) {
    throw StateError(
      'sqlite3_exec failed: $deleteResult ${sqliteraw.sqlite3Errmsg(db)}',
    );
  }
  lines.add('\nDelete record: id=$deleteRecordId, rowsChanged=${sqliteraw.sqlite3Changes(db)}, result=$deleteResult');

  const stmt = 0;
  final prepareResult = sqliteraw.sqlite3PrepareV2(db, 'select id, title from todos');
  if (prepareResult != sqliteOk) {
    throw StateError(
      'sqlite3_prepare_v2 failed: $prepareResult ${sqliteraw.sqlite3Errmsg(db)}',
    );
  }

  while (sqliteraw.sqlite3Step(stmt) == sqliteRow) {
    final id = sqliteraw.sqlite3ColumnInt(stmt, 0);
    final title = sqliteraw.sqlite3ColumnText(stmt, 1);
    lines.add('\n$id: $title');
  }

  sqliteraw.sqlite3Finalize(stmt);

  final closeResult = sqliteraw.sqlite3Close(db);
  if (closeResult != sqliteOk) {
    throw StateError('sqlite3_close failed: $closeResult');
  }
  lines.add('\nClose database: path=$databasePath, result=$closeResult');

  return lines;
}
