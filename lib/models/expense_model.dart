import 'dart:convert';

/// Represents a single financial transaction (Income or Expense).
class Expense {
  final int? id;
  final String title;
  final int amount; // Stored as integer minor units (cents)
  final String category;
  final DateTime date;
  final String type; // 'income' or 'expense'
  final String? note;
  final String? paymentMethod;
  final String? receipt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.type,
    this.note,
    this.paymentMethod,
    this.receipt,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Creates a copy of Expense with updated fields.
  Expense copyWith({
    int? id,
    String? title,
    int? amount,
    String? category,
    DateTime? date,
    String? type,
    String? note,
    String? paymentMethod,
    String? receipt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      type: type ?? this.type,
      note: note ?? this.note,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receipt: receipt ?? this.receipt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Converts Map from SQLite to Expense object.
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'] ?? '',
      amount: (map['amount'] as num).toInt(),
      category: map['category'] ?? 'Other',
      date: DateTime.parse(map['date']),
      type: map['type'] ?? 'expense',
      note: map['note'],
      paymentMethod: map['paymentMethod'],
      receipt: map['receipt'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  /// Converts Expense object to Map for SQLite.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'type': type,
      'note': note,
      'paymentMethod': paymentMethod,
      'receipt': receipt,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// JSON serialization for API/Export
  String toJson() => json.encode(toMap());

  /// JSON deserialization
  factory Expense.fromJson(String source) => Expense.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, type: $type, category: $category, date: $date)';
  }

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';
}
