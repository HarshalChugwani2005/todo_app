import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'models/todo_model.dart';
import 'models/subtask_model.dart';
import 'models/virtual_pet_model.dart';
import 'navigation/bottom_nav_bar.dart';
import 'services/notification_service.dart';
import 'services/recurring_task_service.dart';
import 'services/virtual_pet_service.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase (Temporarily disabled for development)
  // TODO: Uncomment when Firebase is properly configured
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  await Hive.initFlutter();

  // Register adapters only once
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TodoAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(SubtaskAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(VirtualPetAdapter());
  }
  
  // Try to open the database, if it fails due to schema changes, start fresh
  try {
    await Hive.openBox<Todo>('todos');
  } catch (e) {
    debugPrint('Database migration needed due to schema changes.');
    debugPrint('Starting with fresh database...');
    
    // Close all existing boxes to release locks
    await Hive.close();
    
    // Try to delete all existing boxes to force a clean start
    try {
      await Hive.deleteBoxFromDisk('todos');
      await Hive.deleteBoxFromDisk('virtualPets');
      debugPrint('Old databases cleared successfully.');
    } catch (deleteError) {
      debugPrint('Could not delete old database files: $deleteError');
      debugPrint('The app will continue with a clean database.');
    }
    
    // Re-initialize Hive with fresh adapters
    await Hive.initFlutter();
    
    // Re-register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TodoAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(SubtaskAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(VirtualPetAdapter());
    }
    
    // Open fresh databases
    await Hive.openBox<Todo>('todos');
    debugPrint('Fresh database initialized successfully.');
  }

  // Initialize services
  await NotificationService().initialize();
  await VirtualPetService().initialize();
  await RecurringTaskService().processRecurringTasks();
  await RecurringTaskService().scheduleAllNotifications();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VirtualPetService()),
      ],
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
      title: 'TaskPet - Your Productivity Companion',
      themeMode: themeProvider.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
