/// Defines the classification for transactions (e.g., Food, Transport).
enum CategoryType { 
  /// Only available for income transactions.
  income, 
  /// Only available for expense transactions.
  expense, 
  /// Available for both income and expense transactions.
  both 
}

/// A model representing a transaction category.
/// 
/// Categories help organize expenses and income for better reporting 
/// and budgeting. Each category has a unique identifier, a display name, 
/// an icon (emoji), and a color.
class CategoryModel {
  /// Unique identifier for the category (UUID).
  final String id;
  
  /// The display name of the category (e.g., "Groceries").
  final String name;
  
  /// The emoji or icon string representing the category visually.
  final String icon;
  
  /// The integer value of the category's primary color.
  final int color;
  
  /// The type of transactions this category can be applied to.
  final CategoryType type;
  
  /// Whether this is a system-provided default category.
  final bool isDefault;
  
  /// Whether the category is currently available for use.
  final bool isActive;
  
  /// The preferred display order in lists.
  final int sortOrder;
  
  /// Timestamp of when the category was created.
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
    this.isActive = true,
    this.sortOrder = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Creates a copy of this [CategoryModel] with the given fields replaced.
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    CategoryType? type,
    bool? isDefault,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Converts the [CategoryModel] instance into a map for database storage.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type.name,
      'is_default': isDefault ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a [CategoryModel] instance from a database map.
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      color: map['color'],
      type: CategoryType.values.byName(map['type']),
      isDefault: map['is_default'] == 1,
      isActive: map['is_active'] == 1,
      sortOrder: map['sort_order'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
