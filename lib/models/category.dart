enum CategoryType {
  income,
  expense,
}

class Category {
  final int id;
  final String name;
  final CategoryType type;

  const Category({
    required this.id,
    required this.name,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}