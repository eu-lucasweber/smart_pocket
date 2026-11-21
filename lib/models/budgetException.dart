class BudgetException implements Exception {
  final String message;

  const BudgetException(this.message);

  @override
  String toString() => message;
}