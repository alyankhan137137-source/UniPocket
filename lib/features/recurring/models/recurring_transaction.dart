import 'recurrence_frequency.dart';

class RecurringTransaction {
  final String id;
  final String templateTitle;
  final int amount; // in cents
  final String categoryId;
  final String type; // 'income' or 'expense'
  final RecurrenceFrequency frequency;
  final int interval;
  final DateTime startDate;
  final DateTime? endDate;
  final int? dayOfMonth;
  final int? dayOfWeek;
  final int? monthOfYear;
  final DateTime? lastGeneratedDate;
  final DateTime nextDueDate;
  final bool isActive;
  final bool isPaused;
  final List<DateTime> skipDates;
  final int totalGenerated;
  final String? note;
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
