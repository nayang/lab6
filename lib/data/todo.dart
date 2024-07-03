import 'package:floor/floor.dart';

@entity
class Todo {
  @PrimaryKey(autoGenerate: true)
  final int? id;
  final String task;

  Todo({
    this.id,
    required this.task,
  });
}
