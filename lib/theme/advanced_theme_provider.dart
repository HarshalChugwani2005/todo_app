import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  static const String _fontSizeKey = 'font_size';
  
  ThemeMode _themeMode = ThemeMode.system;
  Color _accentColor = Colors.blue;
  double _fontSize = 1.0; // Scale factor
  
  ThemeMode get themeMode => _themeMode;
  Color get accentColor => _accentColor;
  double get fontSize => _fontSize;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  AdvancedThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Predefined color schemes
  static const List<Color> availableColors = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  static const List<String> colorNames = [
    'Ocean Blue',
    'Royal Purple',
    'Nature Green',
    'Sunset Orange',
    'Passion Red',
    'Aqua Teal',
    'Deep Indigo',
    'Rose Pink',
  ];

  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _accentColor,
      brightness: Brightness.light,
    ),
    textTheme: _getTextTheme(Brightness.light),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _accentColor,
      brightness: Brightness.dark,
    ),
    textTheme: _getTextTheme(Brightness.dark),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  TextTheme _getTextTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.light 
        ? ThemeData.light().textTheme 
        : ThemeData.dark().textTheme;
    
    return baseTheme.copyWith(
      displayLarge: baseTheme.displayLarge?.copyWith(fontSize: baseTheme.displayLarge!.fontSize! * _fontSize),
      displayMedium: baseTheme.displayMedium?.copyWith(fontSize: baseTheme.displayMedium!.fontSize! * _fontSize),
      displaySmall: baseTheme.displaySmall?.copyWith(fontSize: baseTheme.displaySmall!.fontSize! * _fontSize),
      headlineLarge: baseTheme.headlineLarge?.copyWith(fontSize: baseTheme.headlineLarge!.fontSize! * _fontSize),
      headlineMedium: baseTheme.headlineMedium?.copyWith(fontSize: baseTheme.headlineMedium!.fontSize! * _fontSize),
      headlineSmall: baseTheme.headlineSmall?.copyWith(fontSize: baseTheme.headlineSmall!.fontSize! * _fontSize),
      titleLarge: baseTheme.titleLarge?.copyWith(fontSize: baseTheme.titleLarge!.fontSize! * _fontSize),
      titleMedium: baseTheme.titleMedium?.copyWith(fontSize: baseTheme.titleMedium!.fontSize! * _fontSize),
      titleSmall: baseTheme.titleSmall?.copyWith(fontSize: baseTheme.titleSmall!.fontSize! * _fontSize),
      bodyLarge: baseTheme.bodyLarge?.copyWith(fontSize: baseTheme.bodyLarge!.fontSize! * _fontSize),
      bodyMedium: baseTheme.bodyMedium?.copyWith(fontSize: baseTheme.bodyMedium!.fontSize! * _fontSize),
      bodySmall: baseTheme.bodySmall?.copyWith(fontSize: baseTheme.bodySmall!.fontSize! * _fontSize),
      labelLarge: baseTheme.labelLarge?.copyWith(fontSize: baseTheme.labelLarge!.fontSize! * _fontSize),
      labelMedium: baseTheme.labelMedium?.copyWith(fontSize: baseTheme.labelMedium!.fontSize! * _fontSize),
      labelSmall: baseTheme.labelSmall?.copyWith(fontSize: baseTheme.labelSmall!.fontSize! * _fontSize),
    );
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  void setAccentColor(Color color) async {
    _accentColor = color;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.value);
  }

  void setFontSize(double size) async {
    _fontSize = size;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
  }

  void _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    final themeIndex = prefs.getInt(_themeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeIndex];
    
    final colorValue = prefs.getInt(_accentColorKey) ?? Colors.blue.value;
    _accentColor = Color(colorValue);
    
    _fontSize = prefs.getDouble(_fontSizeKey) ?? 1.0;
    
    notifyListeners();
  }

  String get currentColorName {
    final index = availableColors.indexOf(_accentColor);
    return index >= 0 ? colorNames[index] : 'Custom';
  }
}