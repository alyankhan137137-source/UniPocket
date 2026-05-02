import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../models/notification_payload.dart';
import '../../../models/budget_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // FIX: Using named parameter 'settings' and 'onDidReceiveNotificationResponse'
    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null) {
          final payload = NotificationPayload.fromJson(details.payload!);
          _handleNotificationTap(payload);
        }
      },
    );

    _createChannels();
  }

  static void _createChannels() async {
    const budgetChannel = AndroidNotificationChannel(
      'budget_alerts',
      'Budget Alerts',
      description: 'Warnings when you approach your budget limits',
      importance: Importance.high,
    );

    const insightChannel = AndroidNotificationChannel(
      'spending_insights',
      'Spending Insights',
      description: 'Daily and weekly spending summaries',
      importance: Importance.defaultImportance,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(budgetChannel);
    
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(insightChannel);
  }

  static Future<void> showBudgetAlert(Budget budget, double percentage) async {
    String title = "Budget Alert";
    String body = "You've reached ${percentage.toStringAsFixed(0)}% of your budget.";

    if (percentage >= 110) {
      title = "💸 Budget Exceeded!";
      body = "You've overspent on your budget. Time to cut back!";
    } else if (percentage >= 100) {
      title = "❌ Budget Reached!";
      body = "You've hit your limit for this category.";
    } else if (percentage >= 90) {
      title = "🔴 Almost Out!";
      body = "Only 10% remaining in your budget.";
    }

    final payload = NotificationPayload(type: NotificationType.budget, id: budget.id.toString());

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      importance: Importance.high,
      priority: Priority.high,
      color: Colors.red,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    // FIX: Using named parameters 'id', 'title', 'body', 'notificationDetails', 'payload'
    await _plugin.show(
      id: budget.id ?? 0,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload.toJson(),
    );
  }

  static void _handleNotificationTap(NotificationPayload payload) {
    debugPrint("Tapped notification of type: ${payload.type}");
  }
}
