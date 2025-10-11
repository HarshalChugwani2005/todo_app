import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/todo_model.dart';
import 'models/subtask_model.dart';
import 'navigation/bottom_nav_bar.dart';
import 'services/notification_service.dart';
import 'services/recurring_task_service.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(TodoAdapter());
  Hive.registerAdapter(SubtaskAdapter());
  
  // Try to open the database, if it fails due to schema changes, start fresh
  try {
    await Hive.openBox<Todo>('todos');
  } catch (e) {
    debugPrint('Database migration needed due to schema changes.');
    debugPrint('Starting with fresh database...');
    
    // Close all existing boxes to release locks
    await Hive.close();
    
    // Re-register adapters
    Hive.registerAdapter(TodoAdapter());
    Hive.registerAdapter(SubtaskAdapter());
    
    // Try to delete the corrupted database
    try {
      await Hive.deleteBoxFromDisk('todos');
      debugPrint('Old database cleared successfully.');
    } catch (deleteError) {
      debugPrint('Could not delete old database file. It may be locked by another process.');
      debugPrint('The app will continue with a clean database.');
    }
    
    // Open a fresh database
    await Hive.openBox<Todo>('todos');
  }

  // Initialize services
  await NotificationService().initialize();
  await RecurringTaskService().processRecurringTasks();
  await RecurringTaskService().scheduleAllNotifications();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Advanced To-Do App',
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
