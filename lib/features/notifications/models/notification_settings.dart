import 'package:flutter/material.dart';

/// Configuration for the application's notification system.
/// 
/// This class defines user preferences for different types of alerts, 
/// delivery schedules, and quiet hours.
class NotificationSettings {
  /// Global toggle for all notifications.
  final bool masterEnabled;
  
  /// Whether to receive alerts when budget limits are approached or exceeded.
  final bool budgetAlertsEnabled;
  
  /// A list of percentage thresholds (0.0 to 1.0+) at which budget alerts are triggered.
  final List<double> alertThresholds;
  
  /// Whether to receive a daily end-of-day financial summary.
  final bool dailySummaryEnabled;
  
  /// The time of day when the daily summary should be delivered.
  final TimeOfDay dailySummaryTime;
  
  /// Whether to receive weekly financial insights and reports.
  final bool weeklyInsightsEnabled;
  
  /// Whether to receive reminders for upcoming bills or recurring payments.
  final bool billRemindersEnabled;
  
  /// Number of days in advance to send bill reminders.
  final int billReminderAdvanceDays;
  
  /// The start of the period during which notifications should be silenced.
  final TimeOfDay? quietHoursStart;
  
  /// The end of the period during which notifications should be silenced.
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

  /// Creates a copy of this [NotificationSettings] with the given fields replaced.
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

  /// Converts the [NotificationSettings] instance into a [Map] for storage.
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
