import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';
import '../models/subtask_model.dart';

class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  static const String _syncDataKey = 'local_sync_data';
  static const String _lastSyncKey = 'local_last_sync_timestamp';

  // Local backup and restore methods

  Future<bool> syncToCloud(List<Todo> todos) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert todos to JSON format
      final todosData = todos.map((todo) => {
        'title': todo.title,
        'isDone': todo.isDone,
        'category': todo.category,
        'dueDate': todo.dueDate?.toIso8601String(),
        'priority': todo.priority,
        'isRecurring': todo.isRecurring,
        'recurrenceType': todo.recurrenceType,
        'lastRecurrence': todo.lastRecurrence?.toIso8601String(),
        'subtasks': todo.subtasks.map((subtask) => {
          'title': subtask.title,
          'isDone': subtask.isDone,
          'createdAt': subtask.createdAt?.toIso8601String(),
        }).toList(),
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      }).toList();

      // Store in SharedPreferences (local backup)
      final syncData = {
        'todos': todosData,
        'lastSync': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(_syncDataKey, jsonEncode(syncData));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      
      debugPrint('Local Sync: Backed up ${todos.length} todos locally');
      return true;
    } catch (e) {
      debugPrint('Local Sync: Backup failed - $e');
      return false;
    }
  }

  Future<List<Todo>?> syncFromCloud() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final syncDataString = prefs.getString(_syncDataKey);
      
      if (syncDataString == null) return null;
      
      final syncData = jsonDecode(syncDataString) as Map<String, dynamic>;
      final todosData = syncData['todos'] as List<dynamic>;

      final todos = todosData.map((todoData) {
        final subtasksData = todoData['subtasks'] as List<dynamic>? ?? [];
        final subtasks = subtasksData.map((subtaskData) => Subtask(
          title: subtaskData['title'] as String,
          isDone: subtaskData['isDone'] as bool? ?? false,
          createdAt: subtaskData['createdAt'] != null 
              ? DateTime.parse(subtaskData['createdAt'] as String)
              : null,
        )).toList();

        final todo = Todo(
          title: todoData['title'] as String,
          isDone: todoData['isDone'] as bool? ?? false,
          category: todoData['category'] as String? ?? 'Personal',
          dueDate: todoData['dueDate'] != null 
              ? DateTime.parse(todoData['dueDate'] as String)
              : null,
          priority: todoData['priority'] as int? ?? 1,
          isRecurring: todoData['isRecurring'] as bool? ?? false,
          recurrenceType: todoData['recurrenceType'] as int? ?? 0,
          subtasks: subtasks,
        );

        if (todoData['lastRecurrence'] != null) {
          todo.lastRecurrence = DateTime.parse(todoData['lastRecurrence'] as String);
        }

        return todo;
      }).toList();

      debugPrint('Local Sync: Restored ${todos.length} todos from local backup');
      return todos;
    } catch (e) {
      debugPrint('Local Sync: Restore failed - $e');
      return null;
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSyncString = prefs.getString(_lastSyncKey);
    if (lastSyncString != null) {
      return DateTime.parse(lastSyncString);
    }
    return null;
  }

  Future<bool> hasConflicts() async {
    // No conflicts in local sync
    return false;
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    final lastSync = await getLastSyncTime();
    final hasConflicts = await this.hasConflicts();
    
    return {
      'lastSync': lastSync,
      'hasConflicts': hasConflicts,
      'canSync': !hasConflicts,
      'isLocal': true, // Indicates this is local-only sync
    };
  }
}