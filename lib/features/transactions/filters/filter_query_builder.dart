import 'transaction_filter.dart';

class FilterQueryBuilder {
  static Map<String, dynamic> build(TransactionFilter filter) {
    List<String> whereClauses = ["is_deleted = 0"];
    List<dynamic> arguments = [];

    // 1. Search Query
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      whereClauses.add("(title LIKE ? OR note LIKE ?)");
      arguments.add('%${filter.searchQuery}%');
      arguments.add('%${filter.searchQuery}%');
    }

    // 2. Date Range
    if (filter.dateRange != null) {
      whereClauses.add("date BETWEEN ? AND ?");
      arguments.add(filter.dateRange!.start.toIso8601String());
      arguments.add(filter.dateRange!.end.toIso8601String());
    }

    // 3. Categories
    if (filter.categories.isNotEmpty) {
      String placeholders = List.filled(filter.categories.length, '?').join(',');
      whereClauses.add("category IN ($placeholders)");
      arguments.addAll(filter.categories);
    }

    // 4. Transaction Types
    if (filter.transactionTypes.isNotEmpty) {
      String placeholders = List.filled(filter.transactionTypes.length, '?').join(',');
      whereClauses.add("type IN ($placeholders)");
      arguments.addAll(filter.transactionTypes);
    }

    // 5. Amount Range
    if (filter.amountRange != null) {
      whereClauses.add("amount BETWEEN ? AND ?");
      arguments.add(filter.amountRange!.start);
      arguments.add(filter.amountRange!.end);
    }

    // 6. Sorting
    String sortField = _getSortField(filter.sortBy);
    String sortOrder = filter.sortOrder == SortOrder.ascending ? "ASC" : "DESC";

    String whereClause = whereClauses.join(" AND ");
    String orderBy = "$sortField $sortOrder";

    return {
      'where': whereClause,
      'whereArgs': arguments,
      'orderBy': orderBy,
    };
  }

  static String _getSortField(SortField field) {
    switch (field) {
      case SortField.date: return 'date';
      case SortField.amount: return 'amount';
      case SortField.category: return 'category';
      case SortField.title: return 'title';
    }
  }
}
