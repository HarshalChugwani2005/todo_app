import 'package:hive/hive.dart';

part 'todo_model.g.dart'; // generated adapter file

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  String category;

  @HiveField(3)
  DateTime? dueDate;

  Todo({
    required this.title,
    this.isDone = false,
    this.category = 'Personal',
    this.dueDate,
  });
}
