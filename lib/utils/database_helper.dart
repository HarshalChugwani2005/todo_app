import 'package:hive/hive.dart';
import '../models/todo_model.dart';

class DatabaseHelper {
  static Box<Todo> getTodoBox() {
    return Hive.box<Todo>('todos');
  }
}