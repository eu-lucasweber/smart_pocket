import 'package:smart_pocket/models/category.dart';

class Budget {
  final int id;
  final Category category;
  final double amount;
  final String? description;

  const Budget({
    required this.id,
    required this.category,
    required this.amount,
    this.description,
  });

  Budget copyWith({
    int? id,
    Category? category,
    double? amount,
    int? month,
    int? year,
    String? description,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
    );
  }
}