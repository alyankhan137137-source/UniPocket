import 'package:flutter/material.dart';
import '../models/notification_settings.dart';

/// A provider that manages and persists notification preferences.
/// 
/// This class acts as a state container for [NotificationSettings] and 
/// provides methods to update specific settings while ensuring the UI 
/// stays in sync.
class NotificationProvider with ChangeNotifier {
  NotificationSettings _settings = NotificationSettings();

  /// The current user notification settings.
  NotificationSettings get settings => _settings;

  /// Updates the entire settings object and notifies listeners.
  /// 
  /// This method should also handle persistence to local storage 
  /// (e.g., SQLite or SharedPreferences).
  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    // TODO: Implement logic to persist settings to DB or SharedPreferences
  }

  /// Toggles the global notification switch.
  void toggleMaster(bool value) {
    updateSettings(_settings.copyWith(masterEnabled: value));
  }

  /// Toggles budget-specific alerts.
  void toggleBudgetAlerts(bool value) {
    updateSettings(_settings.copyWith(budgetAlertsEnabled: value));
  }
}
