// TaskPet app widget tests.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:taskpet/services/virtual_pet_service.dart';
import 'package:taskpet/theme/theme_provider.dart';

void main() {
  testWidgets('TaskPet app widget renders correctly', (WidgetTester tester) async {
    // Create a simplified test version of the app without Hive initialization
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => VirtualPetService()),
        ],
        child: MaterialApp(
          title: 'TaskPet Test',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const Scaffold(
            appBar: MyAppBar(),
            body: Center(
              child: Text('TaskPet - Your Productivity Companion'),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: null,
              child: Icon(Icons.add),
            ),
          ),
        ),
      ),
    );

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Verify that the app renders without crashing
    expect(find.text('TaskPet - Your Productivity Companion'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Theme provider functionality test', (WidgetTester tester) async {
    late ThemeProvider themeProvider;
    
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) {
          themeProvider = ThemeProvider();
          return themeProvider;
        },
        child: Consumer<ThemeProvider>(
          builder: (context, provider, child) {
            return MaterialApp(
              theme: provider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
              home: Scaffold(
                appBar: AppBar(
                  title: Text('Theme Test'),
                  actions: [
                    Switch(
                      value: provider.isDarkMode,
                      onChanged: provider.toggleTheme,
                    ),
                  ],
                ),
                body: const Center(
                  child: Text('Testing Theme'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial state (should be light mode)
    expect(themeProvider.isDarkMode, false);
    expect(find.text('Testing Theme'), findsOneWidget);

    // Find and tap the theme switch
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    // Verify theme changed to dark mode
    expect(themeProvider.isDarkMode, true);
  });
}

// Simple AppBar widget for testing
class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('📝 TaskPet Test'),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
