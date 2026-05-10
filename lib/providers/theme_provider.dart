import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A provider that manages the application's theme mode (light, dark, or system).
/// 
/// This provider persists the user's theme preference using [SharedPreferences]
/// to ensure the selected theme is applied consistently across app launches.
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  static const String _themeKey = 'theme_mode';

  ThemeProvider() {
    _loadTheme();
  }

  /// The currently active [ThemeMode].
  ThemeMode get themeMode => _themeMode;

  /// Returns true if the application is currently in dark mode.
  /// 
  /// If set to [ThemeMode.system], it resolves against the device's system brightness.
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  /// Updates the application's theme mode and persists it to local storage.
  /// 
  /// [mode] is the new [ThemeMode] to apply.
  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString());
  }

  /// Loads the persisted theme mode from [SharedPreferences].
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeStr = prefs.getString(_themeKey);
    if (themeStr != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeStr,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }
}
