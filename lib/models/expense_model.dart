import 'dart:convert';

/// Represents a single financial transaction, which can be either an income or an expense.
/// 
/// This model stores core transaction data such as amount, title, category, and date,
/// as well as optional metadata like notes and payment methods.
class Expense {
  /// Unique identifier for the transaction record.
  final int? id;
  
  /// A short descriptive title for the transaction.
  final String title;
  
  /// The monetary amount stored in minor units (e.g., cents).
  final int amount; 
  
  /// The category name associated with this transaction.
  final String category;
  
  /// The date and time when the transaction occurred.
  final DateTime date;
  
  /// The type of transaction: 'income' or 'expense'.
  final String type; 
  
  /// An optional descriptive note.
  final String? note;
  
  /// The method used for payment (e.g., 'Cash', 'Card').
  final String? paymentMethod;
  
  /// An optional path or reference to a digital receipt.
  final String? receipt;
  
  /// Timestamp of when the record was created.
  final DateTime createdAt;
  
  /// Timestamp of the last update to this record.
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

  /// Creates a copy of this [Expense] with the given fields replaced.
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

  /// Creates an [Expense] instance from a database map.
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

  /// Converts the [Expense] instance into a map for database storage.
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

  /// Serializes the [Expense] instance to a JSON string.
  String toJson() => json.encode(toMap());

  /// Deserializes an [Expense] instance from a JSON string.
  factory Expense.fromJson(String source) => Expense.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, type: $type, category: $category, date: $date)';
  }

  /// Returns true if this transaction is an income.
  bool get isIncome => type == 'income';
  
  /// Returns true if this transaction is an expense.
  bool get isExpense => type == 'expense';
}
