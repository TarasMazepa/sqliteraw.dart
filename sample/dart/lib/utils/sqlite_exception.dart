class SqliteException implements Exception {
  SqliteException(this.resultCode, this.message);

  final int resultCode;
  final String message;

  @override
  String toString() => 'SqliteException($resultCode): $message';
}
