import 'dart:math';

class ParentLink {
  final String id;
  final String accessCode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  ParentLink({
    required this.id,
    required this.accessCode,
    required this.isActive,
    required this.createdAt,
    required this.expiresAt,
  });

  factory ParentLink.generate() {
    final random = Random();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final accessCode = (100000 + random.nextInt(900000)).toString();
    final createdAt = DateTime.now();
    final expiresAt = createdAt.add(const Duration(days: 30));

    return ParentLink(
      id: id,
      accessCode: accessCode,
      isActive: true,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'accessCode': accessCode,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  factory ParentLink.fromMap(Map<String, dynamic> map) {
    return ParentLink(
      id: map['id'] as String,
      accessCode: map['accessCode'] as String,
      isActive: map['isActive'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      expiresAt: DateTime.parse(map['expiresAt'] as String),
    );
  }
}
