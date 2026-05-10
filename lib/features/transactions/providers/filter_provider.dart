import 'package:flutter/material.dart';
import '../filters/transaction_filter.dart';

/// A provider that manages the active [TransactionFilter] for the transaction list.
/// 
/// This class provides methods to update specific filter criteria such as
/// date ranges, search queries, and category selections, notifying listeners
/// to trigger a refresh of the transaction data.
class FilterProvider with ChangeNotifier {
  TransactionFilter _filter = TransactionFilter();

  /// The currently active filter criteria.
  TransactionFilter get filter => _filter;

  /// Replaces the current filter with a new [TransactionFilter].
  void updateFilter(TransactionFilter newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  /// Resets all filter criteria to their default (empty) values.
  void resetFilter() {
    _filter = TransactionFilter();
    notifyListeners();
  }

  /// Updates the text search query in the filter.
  void setSearchQuery(String? query) {
    _filter = _filter.copyWith(searchQuery: query);
    notifyListeners();
  }

  /// Updates the date range and its associated preset.
  void setDateRange(DateTimeRange? range, DatePreset? preset) {
    _filter = _filter.copyWith(dateRange: range, datePreset: preset);
    notifyListeners();
  }

  /// Adds or removes a category ID from the active filter.
  void toggleCategory(String categoryId) {
    List<String> newCategories = List.from(_filter.categories);
    if (newCategories.contains(categoryId)) {
      newCategories.remove(categoryId);
    } else {
      newCategories.add(categoryId);
    }
    _filter = _filter.copyWith(categories: newCategories);
    notifyListeners();
  }

  /// Explicitly removes a category ID from the filter.
  void clearCategory(String categoryId) {
    List<String> newCategories = List.from(_filter.categories);
    newCategories.remove(categoryId);
    _filter = _filter.copyWith(categories: newCategories);
    notifyListeners();
  }
}
