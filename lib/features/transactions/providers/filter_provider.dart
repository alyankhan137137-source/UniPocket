import 'package:flutter/material.dart';
import '../filters/transaction_filter.dart';

class FilterProvider with ChangeNotifier {
  TransactionFilter _filter = TransactionFilter();

  TransactionFilter get filter => _filter;

  void updateFilter(TransactionFilter newFilter) {
    _filter = newFilter;
    notifyListeners();
  }

  void resetFilter() {
    _filter = TransactionFilter();
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _filter = _filter.copyWith(searchQuery: query);
    notifyListeners();
  }

  void setDateRange(DateTimeRange? range, DatePreset? preset) {
    _filter = _filter.copyWith(dateRange: range, datePreset: preset);
    notifyListeners();
  }

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

  void clearCategory(String categoryId) {
    List<String> newCategories = List.from(_filter.categories);
    newCategories.remove(categoryId);
    _filter = _filter.copyWith(categories: newCategories);
    notifyListeners();
  }
}
