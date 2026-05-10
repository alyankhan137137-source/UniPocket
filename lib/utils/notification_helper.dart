import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

/// A utility class to manage local notifications for the application.
/// 
/// This class handles the initialization of the notification plugin, 
/// scheduling recurring notifications (like daily summaries), 
/// and displaying immediate alerts (like budget warnings).
class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the notification settings for Android and iOS.
  /// 
  /// Also initializes the timezone database required for scheduled notifications.
  static Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  /// Displays an immediate budget alert notification.
  /// 
  /// [category] is the name of the budget category.
  /// [percentage] is the current spending percentage relative to the budget limit.
  static Future<void> showBudgetAlert({
    required String category,
    required double percentage,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Notifications for budget thresholds',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.red,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _notificationsPlugin.show(
      id: 0,
      title: 'Budget Alert: $category',
      body: 'You have reached ${percentage.toStringAsFixed(0)}% of your budget!',
      notificationDetails: platformChannelSpecifics,
    );
  }

  /// Schedules a recurring daily notification to remind the user to check their spending.
  /// 
  /// [time] is the time of day when the notification should be triggered.
  static Future<void> scheduleDailySummary({required TimeOfDay time}) async {
    await _notificationsPlugin.zonedSchedule(
      id: 1,
      title: 'Daily Summary',
      body: 'Check your spending for today!',
      scheduledDate: _nextInstanceOfTime(time),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Daily Summary',
          channelDescription: 'Daily spending summary reminder',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Calculates the next [tz.TZDateTime] occurrence for a given [TimeOfDay].
  /// 
  /// If the time has already passed today, it schedules it for tomorrow.
  static tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Cancels all active and scheduled notifications.
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
