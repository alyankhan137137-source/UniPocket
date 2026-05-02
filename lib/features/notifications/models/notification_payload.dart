import 'dart:convert';

enum NotificationType { budget, summary, weekly, bill }

class NotificationPayload {
  final NotificationType type;
  final String? id; // Related ID (Budget ID, Transaction ID, etc.)

  NotificationPayload({required this.type, this.id});

  Map<String, dynamic> toMap() => {
    'type': type.index,
    'id': id,
  };

  factory NotificationPayload.fromMap(Map<String, dynamic> map) => NotificationPayload(
    type: NotificationType.values[map['type']],
    id: map['id'],
  );

  String toJson() => json.encode(toMap());

  factory NotificationPayload.fromJson(String source) => 
      NotificationPayload.fromMap(json.decode(source));
}
