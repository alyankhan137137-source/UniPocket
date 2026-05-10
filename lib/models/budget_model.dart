import 'dart:convert';

/// Represents a budget configuration set by the user for a specific category.
/// 
/// Budgets track spending over a defined [period] (e.g., monthly) and help
/// users stay within their financial limits.
class Budget {
  /// Unique identifier for the budget record.
  final int? id;
  
  /// The ID of the category this budget applies to. 
  /// References [CategoryModel.id].
  final String categoryId; 
  
  /// The total allowed budget amount stored in minor units (e.g., cents).
  final int amount; 
  
  /// The frequency of the budget cycle: 'daily', 'weekly', 'monthly', or 'yearly'.
  final String period; 
  
  /// The start date of the current budget cycle.
  final DateTime startDate;
  
  /// The end date of the current budget cycle.
  final DateTime endDate;
  
  /// Whether the budget is currently being tracked.
  final bool isActive;
  
  /// The total amount spent in this category during the budget period.
  /// Note: This is a calculated field used in the UI and not stored in the database.
  final int spent; 

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

  /// Creates a copy of this [Budget] with the given fields replaced.
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

  /// Creates a [Budget] instance from a database map.
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

  /// Converts the [Budget] instance into a map for database storage.
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

  /// Serializes the [Budget] instance to a JSON string.
  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'Budget(id: $id, categoryId: $categoryId, amount: $amount, period: $period)';
  }

  /// Returns the percentage of the budget that has been consumed.
  double get percentSpent => amount > 0 ? (spent / amount) * 100 : 0.0;

  /// Returns true if the current spending exceeds the budget amount.
  bool get isExceeded => spent > amount;
}
