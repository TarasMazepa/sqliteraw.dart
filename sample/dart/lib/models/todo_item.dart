class TodoItem {
  const TodoItem({
    required this.id,
    required this.title,
    required this.done,
  });

  final int id;
  final String title;
  final bool done;
}
