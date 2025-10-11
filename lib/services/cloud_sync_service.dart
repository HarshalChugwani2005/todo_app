import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';
import '../models/subtask_model.dart';

class CloudSyncService {
  static final CloudSyncService _instance = CloudSyncService._internal();
  factory CloudSyncService() => _instance;
  CloudSyncService._internal();

  static const String _syncDataKey = 'cloud_sync_data';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _userIdKey = 'user_id';

  // Simulated cloud sync - in real implementation, this would use Firebase
  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey) != null;
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<bool> signIn(String email, String password) async {
    // Simulated sign-in - in real implementation, this would use Firebase Auth
    try {
      final prefs = await SharedPreferences.getInstance();
      // Generate a mock user ID
      final userId = 'user_${email.hashCode.abs()}';
      await prefs.setString(_userIdKey, userId);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_syncDataKey);
    await prefs.remove(_lastSyncKey);
  }

  Future<bool> syncToCloud(List<Todo> todos) async {
    if (!await isSignedIn()) return false;

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert todos to JSON
      final todosJson = todos.map((todo) => {
        'id': todo.key.toString(),
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
      }).toList();

      final syncData = {
        'todos': todosJson,
        'syncTimestamp': DateTime.now().toIso8601String(),
        'userId': await getCurrentUserId(),
      };

      // Save to SharedPreferences (simulating cloud storage)
      await prefs.setString(_syncDataKey, jsonEncode(syncData));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      
      return true;
    } catch (e) {
      debugPrint('Sync to cloud failed: $e');
      return false;
    }
  }

  Future<List<Todo>?> syncFromCloud() async {
    if (!await isSignedIn()) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final syncDataString = prefs.getString(_syncDataKey);
      
      if (syncDataString == null) return null;

      final syncData = jsonDecode(syncDataString) as Map<String, dynamic>;
      final todosJson = syncData['todos'] as List<dynamic>;

      final todos = todosJson.map((todoJson) {
        final subtasksJson = todoJson['subtasks'] as List<dynamic>? ?? [];
        final subtasks = subtasksJson.map((subtaskJson) => Subtask(
          title: subtaskJson['title'] as String,
          isDone: subtaskJson['isDone'] as bool? ?? false,
          createdAt: subtaskJson['createdAt'] != null 
              ? DateTime.parse(subtaskJson['createdAt'] as String)
              : null,
        )).toList();

        final todo = Todo(
          title: todoJson['title'] as String,
          isDone: todoJson['isDone'] as bool? ?? false,
          category: todoJson['category'] as String? ?? 'Personal',
          dueDate: todoJson['dueDate'] != null 
              ? DateTime.parse(todoJson['dueDate'] as String)
              : null,
          priority: todoJson['priority'] as int? ?? 1,
          isRecurring: todoJson['isRecurring'] as bool? ?? false,
          recurrenceType: todoJson['recurrenceType'] as int? ?? 0,
          subtasks: subtasks,
        );

        if (todoJson['lastRecurrence'] != null) {
          todo.lastRecurrence = DateTime.parse(todoJson['lastRecurrence'] as String);
        }

        return todo;
      }).toList();

      return todos;
    } catch (e) {
      debugPrint('Sync from cloud failed: $e');
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
    // In a real implementation, this would check for conflicts between local and remote data
    return false;
  }

  Future<Map<String, dynamic>> getSyncStatus() async {
    final isSignedIn = await this.isSignedIn();
    final lastSync = await getLastSyncTime();
    final hasConflicts = await this.hasConflicts();
    
    return {
      'isSignedIn': isSignedIn,
      'userId': await getCurrentUserId(),
      'lastSync': lastSync,
      'hasConflicts': hasConflicts,
      'canSync': isSignedIn && !hasConflicts,
    };
  }
}