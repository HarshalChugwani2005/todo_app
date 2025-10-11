import '../models/todo_model.dart';
import '../utils/database_helper.dart';
import 'notification_service.dart';

class RecurringTaskService {
  static final RecurringTaskService _instance = RecurringTaskService._internal();
  factory RecurringTaskService() => _instance;
  RecurringTaskService._internal();

  final NotificationService _notificationService = NotificationService();

  // Check and create recurring tasks
  Future<void> processRecurringTasks() async {
    final todoBox = DatabaseHelper.getTodoBox();
    final allTodos = todoBox.values.toList();
    
    for (final todo in allTodos) {
      if (todo.shouldRecur()) {
        await _createRecurringInstance(todo);
      }
    }
  }

  Future<void> _createRecurringInstance(Todo originalTodo) async {
    final todoBox = DatabaseHelper.getTodoBox();
    
    // Create new instance
    final newTodo = originalTodo.createRecurringInstance();
    await todoBox.add(newTodo);
    
    // Update last recurrence date
    originalTodo.lastRecurrence = DateTime.now();
    await originalTodo.save();
    
    // Schedule notification for the new task if it has a due date
    if (newTodo.dueDate != null) {
      await _scheduleTaskNotification(newTodo);
    }
  }

  Future<void> _scheduleTaskNotification(Todo todo) async {
    if (todo.dueDate == null) return;
    
    final notificationTime = todo.dueDate!.subtract(const Duration(hours: 1));
    
    if (notificationTime.isAfter(DateTime.now())) {
      await _notificationService.scheduleTaskReminder(
        id: todo.key as int,
        title: 'Task Due Soon',
        body: '${todo.title} is due in 1 hour',
        scheduledDate: notificationTime,
      );
    }
  }

  // Schedule notifications for all tasks with due dates
  Future<void> scheduleAllNotifications() async {
    final todoBox = DatabaseHelper.getTodoBox();
    final allTodos = todoBox.values.where((todo) => 
        !todo.isDone && todo.dueDate != null && todo.dueDate!.isAfter(DateTime.now())).toList();
    
    for (final todo in allTodos) {
      await _scheduleTaskNotification(todo);
    }
  }

  // Cancel notification for a specific task
  Future<void> cancelTaskNotification(Todo todo) async {
    if (todo.key != null) {
      await _notificationService.cancelNotification(todo.key as int);
    }
  }

  // Reschedule notification when task is updated
  Future<void> rescheduleTaskNotification(Todo todo) async {
    await cancelTaskNotification(todo);
    if (!todo.isDone) {
      await _scheduleTaskNotification(todo);
    }
  }
}