import 'package:flutter/material.dart';
import '../models/notification_settings.dart';

class NotificationProvider with ChangeNotifier {
  NotificationSettings _settings = NotificationSettings();

  NotificationSettings get settings => _settings;

  Future<void> updateSettings(NotificationSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    // Logic to persist settings to DB or SharedPreferences
  }

  void toggleMaster(bool value) {
    updateSettings(_settings.copyWith(masterEnabled: value));
  }

  void toggleBudgetAlerts(bool value) {
    updateSettings(_settings.copyWith(budgetAlertsEnabled: value));
  }
}
