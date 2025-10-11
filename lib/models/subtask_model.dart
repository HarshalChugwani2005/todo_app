import 'package:hive/hive.dart';

part 'subtask_model.g.dart';

@HiveType(typeId: 1)
class Subtask extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  DateTime? createdAt;

  Subtask({
    required this.title,
    this.isDone = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}