import 'package:flutter/material.dart';

enum DatePreset { today, thisWeek, thisMonth, lastMonth, thisYear, custom }

enum SortField { date, amount, category, title }

enum SortOrder { ascending, descending }

class TransactionFilter {
  final DateTimeRange? dateRange;
  final DatePreset? datePreset;
  final List<String> categories;
  final List<String> transactionTypes; // 'income', 'expense'
  final RangeValues? amountRange;
  final String? searchQuery;
  final List<String> tags;
  final bool? isRecurring;
  final SortField sortBy;
  final SortOrder sortOrder;

  TransactionFilter({
    this.dateRange,
    this.datePreset,
    this.categories = const [],
    this.transactionTypes = const [],
    this.amountRange,
    this.searchQuery,
    this.tags = const [],
    this.isRecurring,
    this.sortBy = SortField.date,
    this.sortOrder = SortOrder.descending,
  });

  bool get isActive =>
      dateRange != null ||
      categories.isNotEmpty ||
      transactionTypes.isNotEmpty ||
      amountRange != null ||
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      tags.isNotEmpty ||
      isRecurring != null;

  TransactionFilter copyWith({
    DateTimeRange? dateRange,
    DatePreset? datePreset,
    List<String>? categories,
    List<String>? transactionTypes,
    RangeValues? amountRange,
    String? searchQuery,
    List<String>? tags,
    bool? isRecurring,
    SortField? sortBy,
    SortOrder? sortOrder,
  }) {
    return TransactionFilter(
      dateRange: dateRange ?? this.dateRange,
      datePreset: datePreset ?? this.datePreset,
      categories: categories ?? this.categories,
      transactionTypes: transactionTypes ?? this.transactionTypes,
      amountRange: amountRange ?? this.amountRange,
      searchQuery: searchQuery ?? this.searchQuery,
      tags: tags ?? this.tags,
      isRecurring: isRecurring ?? this.isRecurring,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
