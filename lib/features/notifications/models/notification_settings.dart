import 'package:flutter/material.dart';

class NotificationSettings {
  final bool masterEnabled;
  final bool budgetAlertsEnabled;
  final List<double> alertThresholds;
  final bool dailySummaryEnabled;
  final TimeOfDay dailySummaryTime;
  final bool weeklyInsightsEnabled;
  final bool billRemindersEnabled;
  final int billReminderAdvanceDays;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;

  NotificationSettings({
    this.masterEnabled = true,
    this.budgetAlertsEnabled = true,
    this.alertThresholds = const [0.5, 0.75, 0.8, 0.9, 1.0, 1.1],
    this.dailySummaryEnabled = true,
    this.dailySummaryTime = const TimeOfDay(hour: 20, minute: 0),
    this.weeklyInsightsEnabled = true,
    this.billRemindersEnabled = true,
    this.billReminderAdvanceDays = 1,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  NotificationSettings copyWith({
    bool? masterEnabled,
    bool? budgetAlertsEnabled,
    List<double>? alertThresholds,
    bool? dailySummaryEnabled,
    TimeOfDay? dailySummaryTime,
    bool? weeklyInsightsEnabled,
    bool? billRemindersEnabled,
    int? billReminderAdvanceDays,
    TimeOfDay? quietHoursStart,
    TimeOfDay? quietHoursEnd,
  }) {
    return NotificationSettings(
      masterEnabled: masterEnabled ?? this.masterEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      alertThresholds: alertThresholds ?? this.alertThresholds,
      dailySummaryEnabled: dailySummaryEnabled ?? this.dailySummaryEnabled,
      dailySummaryTime: dailySummaryTime ?? this.dailySummaryTime,
      weeklyInsightsEnabled: weeklyInsightsEnabled ?? this.weeklyInsightsEnabled,
      billRemindersEnabled: billRemindersEnabled ?? this.billRemindersEnabled,
      billReminderAdvanceDays: billReminderAdvanceDays ?? this.billReminderAdvanceDays,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'masterEnabled': masterEnabled,
      'budgetAlertsEnabled': budgetAlertsEnabled,
      'alertThresholds': alertThresholds,
      'dailySummaryEnabled': dailySummaryEnabled,
      'dailySummaryHour': dailySummaryTime.hour,
      'dailySummaryMinute': dailySummaryTime.minute,
      'weeklyInsightsEnabled': weeklyInsightsEnabled,
      'billRemindersEnabled': billRemindersEnabled,
      'billReminderAdvanceDays': billReminderAdvanceDays,
    };
  }
}
