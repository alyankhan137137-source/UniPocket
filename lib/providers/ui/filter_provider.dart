import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filter_provider.g.dart';

/// Represents the current state of transaction filters in the UI.
/// 
/// This class encapsulates all the criteria used to filter the transaction list,
/// such as date range, category, search query, and transaction type.
class FilterState {
  /// The selected date range for filtering transactions.
  final DateTimeRange? dateRange;
  
  /// The selected category name for filtering.
  final String? category;
  
  /// The text string used to search transaction titles or notes.
  final String searchQuery;
  
  /// The type of transaction to filter by ('income', 'expense', or null for all).
  final String? transactionType;

  FilterState({
    this.dateRange,
    this.category,
    this.searchQuery = '',
    this.transactionType,
  });

  /// Creates a copy of this [FilterState] with the given fields replaced.
  FilterState copyWith({
    DateTimeRange? dateRange,
    String? category,
    String? searchQuery,
    String? transactionType,
  }) {
    return FilterState(
      dateRange: dateRange ?? this.dateRange,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
      transactionType: transactionType ?? this.transactionType,
    );
  }
}

/// A notifier that manages the [FilterState] for the transaction list.
/// 
/// This provider allows the UI to update filter criteria and ensures that 
/// any components listening to the filter state are updated accordingly.
@riverpod
class FilterNotifier extends _$FilterNotifier {
  @override
  FilterState build() {
    return FilterState();
  }

  /// Updates the date range filter.
  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  /// Updates the category filter.
  void setCategory(String? category) {
    state = state.copyWith(category: category);
  }

  /// Updates the search query filter.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Updates the transaction type filter (e.g., 'income' or 'expense').
  void setTransactionType(String? type) {
    state = state.copyWith(transactionType: type);
  }

  /// Resets all filters to their default values.
  void clearFilters() {
    state = FilterState();
  }
}
