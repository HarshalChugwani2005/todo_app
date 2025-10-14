import 'dart:convert' show jsonEncode, jsonDecode;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_model.dart';
import '../models/subtask_model.dart';

/// Mock Firebase service for development
/// This provides the same interface as the real Firebase service
/// but uses local storage for testing
class MockFirebaseService {
  static final MockFirebaseService _instance = MockFirebaseService._internal();
  factory MockFirebaseService() => _instance;
  MockFirebaseService._internal();

  static const String _userIdKey = 'mock_user_id';
  static const String _syncDataKey = 'mock_cloud_sync_data';
  static const String _lastSyncKey = 'mock_last_sync_timestamp';

  // Mock Authentication
  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey) != null;
  }

  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Simulate Firebase auth with a mock user ID
      final userId = 'mock_user_${email.hashCode.abs()}';
      await prefs.setString(_userIdKey, userId);
      debugPrint('Mock Firebase: Signed in user $userId');
      return true;
    } catch (e) {
      debugPrint('Mock Firebase: Sign in failed - $e');
      return false;
    }
  }

  Future<bool> signUp(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Simulate Firebase auth with a mock user ID
      final userId = 'mock_user_${email.hashCode.abs()}';
      await prefs.setString(_userIdKey, userId);
      debugPrint('Mock Firebase: Signed up user $userId');
      return true;
    } catch (e) {
      debugPrint('Mock Firebase: Sign up failed - $e');
      return false;
    }
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_syncDataKey);
    await prefs.remove(_lastSyncKey);
    debugPrint('Mock Firebase: User signed out');
  }

  // Mock Firestore operations
  Future<bool> syncToCloud(List<Todo> todos) async {
    if (!await isSignedIn()) return false;
    final userId = await getCurrentUserId();
    if (userId == null) return false;

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

      // Store in SharedPreferences (simulating Firestore)
      final syncData = {
        'userId': userId,
        'todos': todosData,
        'lastSync': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(_syncDataKey, jsonEncode(syncData));
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
      
      debugPrint('Mock Firebase: Synced ${todos.length} todos to cloud');
      return true;
    } catch (e) {
      debugPrint('Mock Firebase: Sync to cloud failed - $e');
      return false;
    }
  }

  Future<List<Todo>?> syncFromCloud() async {
    if (!await isSignedIn()) return null;
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final syncDataString = prefs.getString(_syncDataKey);
      
      if (syncDataString == null) return null;
      
      final syncData = jsonDecode(syncDataString) as Map<String, dynamic>;
      
      // Check if this data belongs to the current user
      if (syncData['userId'] != userId) return null;
      
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

      debugPrint('Mock Firebase: Retrieved ${todos.length} todos from cloud');
      return todos;
    } catch (e) {
      debugPrint('Mock Firebase: Sync from cloud failed - $e');
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
    // Mock: assume no conflicts for simplicity
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
      'isMock': true, // Indicates this is mock data
    };
  }
}

