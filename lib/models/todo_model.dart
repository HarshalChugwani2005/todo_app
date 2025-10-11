import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'subtask_model.dart';

part 'todo_model.g.dart'; // generated adapter file

enum Priority { high, medium, low }
enum RecurrenceType { none, daily, weekly, monthly }

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

  @HiveField(4)
  int? _priority; // 0 = high, 1 = medium, 2 = low

  @HiveField(5)
  List<Subtask> subtasks;

  @HiveField(6)
  int recurrenceType; // 0 = none, 1 = daily, 2 = weekly, 3 = monthly

  @HiveField(7)
  DateTime? lastRecurrence;

  @HiveField(8)
  bool isRecurring;

  Todo({
    required this.title,
    this.isDone = false,
    this.category = 'Personal',
    this.dueDate,
    int? priority,
    List<Subtask>? subtasks,
    this.recurrenceType = 0,
    this.lastRecurrence,
    this.isRecurring = false,
  }) : _priority = priority ?? 1,
       subtasks = subtasks ?? [];

  int get priority => _priority ?? 1; // Always return a valid priority
  set priority(int value) => _priority = value;

  Priority get priorityEnum => Priority.values[priority];
  
  Color get priorityColor {
    switch (priorityEnum) {
      case Priority.high:
        return Colors.red;
      case Priority.medium:
        return Colors.orange;
      case Priority.low:
        return Colors.green;
    }
  }

  String get priorityText {
    switch (priorityEnum) {
      case Priority.high:
        return 'High';
      case Priority.medium:
        return 'Medium';
      case Priority.low:
        return 'Low';
    }
  }

  RecurrenceType get recurrenceEnum => RecurrenceType.values[recurrenceType];

  String get recurrenceText {
    switch (recurrenceEnum) {
      case RecurrenceType.none:
        return 'No repeat';
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
    }
  }

  // Subtask helpers
  int get completedSubtasks => subtasks.where((s) => s.isDone).length;
  int get totalSubtasks => subtasks.length;
  double get subtaskProgress => totalSubtasks == 0 ? 0.0 : completedSubtasks / totalSubtasks;
  bool get hasSubtasks => subtasks.isNotEmpty;

  void addSubtask(String title) {
    subtasks.add(Subtask(title: title));
    save();
  }

  void removeSubtask(int index) {
    if (index >= 0 && index < subtasks.length) {
      subtasks.removeAt(index);
      save();
    }
  }

  void toggleSubtask(int index) {
    if (index >= 0 && index < subtasks.length) {
      subtasks[index].isDone = !subtasks[index].isDone;
      save();
    }
  }

  // Recurrence helpers
  bool shouldRecur() {
    if (!isRecurring || recurrenceType == 0) return false;
    if (lastRecurrence == null) return false;

    final now = DateTime.now();
    final last = lastRecurrence!;

    switch (recurrenceEnum) {
      case RecurrenceType.daily:
        return now.difference(last).inDays >= 1;
      case RecurrenceType.weekly:
        return now.difference(last).inDays >= 7;
      case RecurrenceType.monthly:
        return now.month != last.month || now.year != last.year;
      case RecurrenceType.none:
        return false;
    }
  }

  Todo createRecurringInstance() {
    final newDueDate = dueDate != null ? _getNextRecurrenceDate(dueDate!) : null;
    
    return Todo(
      title: title,
      category: category,
      priority: priority,
      dueDate: newDueDate,
      recurrenceType: recurrenceType,
      isRecurring: isRecurring,
      lastRecurrence: DateTime.now(),
    );
  }

  DateTime _getNextRecurrenceDate(DateTime date) {
    switch (recurrenceEnum) {
      case RecurrenceType.daily:
        return date.add(const Duration(days: 1));
      case RecurrenceType.weekly:
        return date.add(const Duration(days: 7));
      case RecurrenceType.monthly:
        return DateTime(date.year, date.month + 1, date.day);
      case RecurrenceType.none:
        return date;
    }
  }
}
