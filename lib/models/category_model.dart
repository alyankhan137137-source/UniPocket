enum CategoryType { income, expense, both }

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int color;
  final CategoryType type;
  final bool isDefault;
  final bool isActive;
  final int sortOrder;
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
