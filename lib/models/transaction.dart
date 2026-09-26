import 'category.dart';

class Transaction {
  final int id;
  final String description;
  final Category category;
  final String date;
  final double value;
  final CategoryType type;

  const Transaction({
    required this.id,
    required this.description,
    required this.category,
    required this.date,
    required this.value,
    required this.type,
  });
}