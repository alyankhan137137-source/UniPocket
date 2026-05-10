import 'package:flutter/material.dart';

/// Preset options for quickly selecting common date ranges.
enum DatePreset { today, thisWeek, thisMonth, lastMonth, thisYear, custom }

/// Available fields for sorting transactions.
enum SortField { date, amount, category, title }

/// The direction of the sort.
enum SortOrder { ascending, descending }

/// A model representing the filtering and sorting criteria for transactions.
/// 
/// This class encapsulates all possible filter parameters, including date ranges,
/// categories, transaction types, and search queries. It is used to refine
/// the list of transactions displayed in the UI.
class TransactionFilter {
  /// The specific start and end dates for the filter.
  final DateTimeRange? dateRange;
  
  /// A preset date range selection.
  final DatePreset? datePreset;
  
  /// A list of category IDs to include in the results.
  final List<String> categories;
  
  /// The types of transactions to include ('income', 'expense').
  final List<String> transactionTypes; 
  
  /// The minimum and maximum monetary amounts to include.
  final RangeValues? amountRange;
  
  /// A text string to search for in titles and notes.
  final String? searchQuery;
  
  /// A list of tags to filter by.
  final List<String> tags;
  
  /// Filter by whether the transaction is recurring or not.
  final bool? isRecurring;
  
  /// The field by which to sort the results.
  final SortField sortBy;
  
  /// The order in which to sort the results.
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

  /// Returns true if any filter criteria (excluding sorting) are currently applied.
  bool get isActive =>
      dateRange != null ||
      categories.isNotEmpty ||
      transactionTypes.isNotEmpty ||
      amountRange != null ||
      (searchQuery != null && searchQuery!.isNotEmpty) ||
      tags.isNotEmpty ||
      isRecurring != null;

  /// Creates a copy of this [TransactionFilter] with the given fields replaced.
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
