import 'dart:convert';

/// Defines the category or intent of a system notification.
enum NotificationType { 
  /// Alerts related to budget limits or status.
  budget, 
  /// Daily or periodic financial summaries.
  summary, 
  /// Weekly performance and spending reports.
  weekly, 
  /// Reminders for upcoming bills or recurring payments.
  bill 
}

/// Represents the data payload attached to a notification.
/// 
/// This payload is used to handle deep linking and contextual actions
/// when a user interacts with a notification.
class NotificationPayload {
  /// The type of notification.
  final NotificationType type;
  
  /// The unique identifier of the related entity (e.g., Budget ID, Transaction ID).
  final String? id;

  NotificationPayload({required this.type, this.id});

  /// Converts the payload to a [Map] for serialization.
  Map<String, dynamic> toMap() => {
    'type': type.index,
    'id': id,
  };

  /// Creates a [NotificationPayload] from a [Map].
  factory NotificationPayload.fromMap(Map<String, dynamic> map) => NotificationPayload(
    type: NotificationType.values[map['type']],
    id: map['id'],
  );

  /// Serializes the payload to a JSON string.
  String toJson() => json.encode(toMap());

  /// Deserializes a [NotificationPayload] from a JSON string.
  factory NotificationPayload.fromJson(String source) => 
      NotificationPayload.fromMap(json.decode(source));
}
