import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'filter_provider.g.dart';

class FilterState {
  final DateTimeRange? dateRange;
  final String? category;
  final String searchQuery;
  final String? transactionType; // 'income', 'expense' or null for all

  FilterState({
    this.dateRange,
    this.category,
    this.searchQuery = '',
    this.transactionType,
  });

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

@riverpod
class FilterNotifier extends _$FilterNotifier {
  @override
  FilterState build() {
    return FilterState();
  }

  void setDateRange(DateTimeRange? range) {
    state = state.copyWith(dateRange: range);
  }

  void setCategory(String? category) {
    state = state.copyWith(category: category);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setTransactionType(String? type) {
    state = state.copyWith(transactionType: type);
  }

  void clearFilters() {
    state = FilterState();
  }
}
