import 'dart:convert';

/// Represents a budget set by the user for a specific category.
class Budget {
  final int? id;
  final String categoryId; // References CategoryModel.id (String UUID)
  final int amount; // Stored as integer minor units (cents)
  final String period; // 'daily', 'weekly', 'monthly', 'yearly'
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final int spent; // Calculated field (not stored in DB directly but used in UI)

  Budget({
    this.id,
    required this.categoryId,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.spent = 0,
  });

  /// Creates a copy of Budget with updated fields.
  Budget copyWith({
    int? id,
    String? categoryId,
    int? amount,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? spent,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      spent: spent ?? this.spent,
    );
  }

  /// Converts Map from SQLite to Budget object.
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'],
      categoryId: map['categoryId'] ?? '',
      amount: (map['amount'] as num).toInt(),
      period: map['period'] ?? 'monthly',
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      isActive: map['isActive'] == 1,
      spent: map['spent'] != null ? (map['spent'] as num).toInt() : 0,
    );
  }

  /// Converts Budget object to Map for SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'period': period,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
    };
  }

  /// JSON serialization
  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Budget(id: $id, categoryId: $categoryId, amount: $amount, period: $period)';
  }

  /// Calculates percentage of budget spent.
  double get percentSpent => amount > 0 ? (spent / amount) * 100 : 0.0;

  /// Returns true if budget is exceeded.
  bool get isExceeded => spent > amount;
}
