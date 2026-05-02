import 'package:flutter/material.dart';
import '../models/user_settings_model.dart';
import '../database/database_helper.dart';

class SettingsProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  UserSettings _settings = UserSettings.defaultSettings();
  bool _isLoading = true;

  SettingsProvider() { _load(); }

  UserSettings get settings => _settings;
  bool get isLoading => _isLoading;

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

  Future<void> updateSettings(UserSettings s) async {
    _settings = s;
    notifyListeners();
    try { await _db.saveSettings(s); } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  void toggleTheme(String t) => updateSettings(_settings.copyWith(theme: t));
  void setCurrency(String c) => updateSettings(_settings.copyWith(currency: c));
}
