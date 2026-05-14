import 'dart:math';
import 'package:uuid/uuid.dart';

/// Represents a secure link between a student and a parent.
class ParentLink {
  final String id;
  final String accessCode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime expiresAt;

  ParentLink({
    required this.id,
    required this.accessCode,
    required this.isActive,
    required this.createdAt,
    required this.expiresAt,
  });

  /// Generates a new ParentLink with a random 6-digit code and 30-day expiration.
  factory ParentLink.generate() {
    final random = Random();
    final code = (random.nextInt(900000) + 100000).toString();
    final now = DateTime.now();
    
    return ParentLink(
      id: const Uuid().v4(),
      accessCode: code,
      isActive: true,
      createdAt: now,
      expiresAt: now.add(const Duration(days: 30)),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accessCode': accessCode,
      'isActive': isActive ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory ParentLink.fromMap(Map<String, dynamic> map) {
    return ParentLink(
      id: map['id'] as String,
      accessCode: map['accessCode'] as String,
      isActive: (map['isActive'] is int) 
          ? map['isActive'] == 1 
          : map['isActive'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      expiresAt: DateTime.parse(map['expiresAt'] as String),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
