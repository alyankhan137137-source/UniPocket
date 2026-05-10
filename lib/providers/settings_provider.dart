import 'package:flutter/material.dart';
import '../models/user_settings_model.dart';
import '../database/database_helper.dart';

/// A provider that manages the user's application-wide settings and preferences.
/// 
/// This class handles loading settings from the database, updating them in memory,
/// and persisting changes back to storage. It notifies listeners whenever a
/// setting is modified to keep the UI in sync.
class SettingsProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  UserSettings _settings = UserSettings.defaultSettings();
  bool _isLoading = true;

  SettingsProvider() { _load(); }

  /// The current user settings.
  UserSettings get settings => _settings;
  
  /// Whether the settings are currently being loaded from storage.
  bool get isLoading => _isLoading;

  /// Loads the persisted settings from the database.
  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _settings = await _db.getSettings();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the entire settings object and persists the changes.
  Future<void> updateSettings(UserSettings s) async {
    _settings = s;
    notifyListeners();
    try { 
      await _db.saveSettings(s); 
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// A convenience method to update the application theme.
  void toggleTheme(String t) => updateSettings(_settings.copyWith(theme: t));
  
  /// A convenience method to update the preferred currency.
  void setCurrency(String c) => updateSettings(_settings.copyWith(currency: c));
}
