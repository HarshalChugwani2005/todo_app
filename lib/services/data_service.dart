import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/todo_model.dart';
import '../models/subtask_model.dart';
import '../utils/database_helper.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Get the todo box using the database helper
  Box<Todo> _getTodoBox() => DatabaseHelper.getTodoBox();

  // Export data to JSON
  Future<String?> exportData() async {
    try {
      final todoBox = _getTodoBox();
      final todos = todoBox.values.toList();
      
      final List<Map<String, dynamic>> exportData = todos.map((todo) => {
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

      final jsonData = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0',
        'totalTasks': todos.length,
        'tasks': exportData,
      };

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'todo_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');
      
      await file.writeAsString(jsonEncode(jsonData));
      return file.path;
    } catch (e) {
      debugPrint('Export error: $e');
      return null;
    }
  }

  // Import data from JSON
  Future<bool> importData() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final file = File(result.files.first.path!);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      if (!jsonData.containsKey('tasks')) {
        throw Exception('Invalid backup file format');
      }

      final todoBox = _getTodoBox();
      
      // Clear existing data (with user confirmation in UI)
      await todoBox.clear();

      final tasksData = jsonData['tasks'] as List<dynamic>;
      
      for (final taskData in tasksData) {
        final subtasksData = taskData['subtasks'] as List<dynamic>? ?? [];
        final subtasks = subtasksData.map((subtaskData) => Subtask(
          title: subtaskData['title'] as String,
          isDone: subtaskData['isDone'] as bool? ?? false,
          createdAt: subtaskData['createdAt'] != null 
              ? DateTime.parse(subtaskData['createdAt'] as String)
              : null,
        )).toList();

        final todo = Todo(
          title: taskData['title'] as String,
          isDone: taskData['isDone'] as bool? ?? false,
          category: taskData['category'] as String? ?? 'Personal',
          dueDate: taskData['dueDate'] != null 
              ? DateTime.parse(taskData['dueDate'] as String)
              : null,
          priority: taskData['priority'] as int? ?? 1,
          isRecurring: taskData['isRecurring'] as bool? ?? false,
          recurrenceType: taskData['recurrenceType'] as int? ?? 0,
          subtasks: subtasks,
        );

        if (taskData['lastRecurrence'] != null) {
          todo.lastRecurrence = DateTime.parse(taskData['lastRecurrence'] as String);
        }

        await todoBox.add(todo);
      }

      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }

  // Get backup file info
  Future<Map<String, dynamic>?> getBackupInfo(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      
      return {
        'exportDate': jsonData['exportDate'],
        'version': jsonData['version'],
        'totalTasks': jsonData['totalTasks'],
      };
    } catch (e) {
      return null;
    }
  }
}