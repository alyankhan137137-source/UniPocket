import 'recurrence_frequency.dart';

/// A template for transactions that repeat over time.
/// 
/// This class stores the configuration for generating actual transactions
/// on a schedule (e.g., monthly rent, weekly groceries). It tracks the 
/// schedule, the next due date, and whether the recurrence is currently active.
class RecurringTransaction {
  /// Unique identifier for the recurring transaction template.
  final String id;
  
  /// The title that will be used for generated transactions.
  final String templateTitle;
  
  /// The monetary amount in minor units (cents).
  final int amount; 
  
  /// The identifier of the category this transaction belongs to.
  final String categoryId;
  
  /// The type of transaction: 'income' or 'expense'.
  final String type; 
  
  /// How often the transaction repeats.
  final RecurrenceFrequency frequency;
  
  /// The multiplier for the frequency (e.g., interval 2 with frequency 'weekly' means bi-weekly).
  final int interval;
  
  /// The date when the recurrence schedule begins.
  final DateTime startDate;
  
  /// Optional date when the recurrence should stop.
  final DateTime? endDate;
  
  /// The specific day of the month for monthly/yearly recurrences.
  final int? dayOfMonth;
  
  /// The specific day of the week (1-7) for weekly recurrences.
  final int? dayOfWeek;
  
  /// The specific month of the year for yearly recurrences.
  final int? monthOfYear;
  
  /// The date when the last transaction was successfully generated from this template.
  final DateTime? lastGeneratedDate;
  
  /// The calculated date for the next transaction generation.
  final DateTime nextDueDate;
  
  /// Whether the recurrence is active in the system.
  final bool isActive;
  
  /// Whether the user has temporarily paused the recurrence.
  final bool isPaused;
  
  /// Specific dates where transaction generation should be skipped.
  final List<DateTime> skipDates;
  
  /// Total number of transactions generated from this template so far.
  final int totalGenerated;
  
  /// Optional note or description for generated transactions.
  final String? note;
  
  /// Timestamp when the template was created.
  final DateTime createdAt;

  RecurringTransaction({
    required this.id,
    required this.templateTitle,
    required this.amount,
    required this.categoryId,
    required this.type,
    required this.frequency,
    this.interval = 1,
    required this.startDate,
    this.endDate,
    this.dayOfMonth,
    this.dayOfWeek,
    this.monthOfYear,
    this.lastGeneratedDate,
    required this.nextDueDate,
    this.isActive = true,
    this.isPaused = false,
    this.skipDates = const [],
    this.totalGenerated = 0,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Converts the [RecurringTransaction] instance into a [Map] for storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'templateTitle': templateTitle,
      'amount': amount,
      'categoryId': categoryId,
      'type': type,
      'frequency': frequency.index,
      'interval': interval,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'dayOfMonth': dayOfMonth,
      'dayOfWeek': dayOfWeek,
      'monthOfYear': monthOfYear,
      'lastGeneratedDate': lastGeneratedDate?.toIso8601String(),
      'nextDueDate': nextDueDate.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'isPaused': isPaused ? 1 : 0,
      'skipDates': skipDates.map((d) => d.toIso8601String()).join(','),
      'totalGenerated': totalGenerated,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a [RecurringTransaction] instance from a [Map].
  factory RecurringTransaction.fromMap(Map<String, dynamic> map) {
    return RecurringTransaction(
      id: map['id'],
      templateTitle: map['templateTitle'],
      amount: map['amount'],
      categoryId: map['categoryId'],
      type: map['type'],
      frequency: RecurrenceFrequency.values[map['frequency']],
      interval: map['interval'],
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      dayOfMonth: map['dayOfMonth'],
      dayOfWeek: map['dayOfWeek'],
      monthOfYear: map['monthOfYear'],
      lastGeneratedDate: map['lastGeneratedDate'] != null ? DateTime.parse(map['lastGeneratedDate']) : null,
      nextDueDate: DateTime.parse(map['nextDueDate']),
      isActive: map['isActive'] == 1,
      isPaused: map['isPaused'] == 1,
      skipDates: map['skipDates'] != null && map['skipDates'].toString().isNotEmpty
          ? map['skipDates'].toString().split(',').map((d) => DateTime.parse(d)).toList()
          : [],
      totalGenerated: map['totalGenerated'],
      note: map['note'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  /// Creates a copy of this [RecurringTransaction] with the given fields replaced.
  RecurringTransaction copyWith({
    String? templateTitle,
    int? amount,
    String? categoryId,
    RecurrenceFrequency? frequency,
    int? interval,
    DateTime? endDate,
    int? dayOfMonth,
    int? dayOfWeek,
    int? monthOfYear,
    DateTime? lastGeneratedDate,
    DateTime? nextDueDate,
    bool? isActive,
    bool? isPaused,
    List<DateTime>? skipDates,
    int? totalGenerated,
    String? note,
  }) {
    return RecurringTransaction(
      id: id,
      templateTitle: templateTitle ?? this.templateTitle,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      type: type,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      startDate: startDate,
      endDate: endDate ?? this.endDate,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      monthOfYear: monthOfYear ?? this.monthOfYear,
      lastGeneratedDate: lastGeneratedDate ?? this.lastGeneratedDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      skipDates: skipDates ?? this.skipDates,
      totalGenerated: totalGenerated ?? this.totalGenerated,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }
}
