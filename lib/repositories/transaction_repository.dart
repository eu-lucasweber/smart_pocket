import 'package:flutter/foundation.dart' show debugPrint;
import 'package:smart_pocket/database/database_helper.dart';
import 'package:smart_pocket/models/category.dart';
import 'package:smart_pocket/models/transaction.dart';


class TransactionRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Transaction>> getAll() async {
  final db = await _databaseHelper.database;

  final categories = await db.rawQuery(
    'SELECT * FROM categories',
  );

  final transactions = await db.rawQuery(
    'SELECT * FROM transactions',
  );

  debugPrint('Categorias no banco: ${categories.length}');
  debugPrint('Transações no banco: ${transactions.length}');

  final result = await db.rawQuery('''
    SELECT
      t.id,
      t.description,
      t.date,
      t.value,
      c.id AS category_id,
      c.name AS category_name,
      c.type AS category_type
    FROM transactions t
    INNER JOIN categories c ON t.category_id = c.id
    ORDER BY t.id DESC
  ''');

  return result.map((map) {
    return Transaction(
      id: map['id'] as int,
      description: map['description'] as String,
      date: map['date'] as String,
      value: (map['value'] as num).toDouble(),
      category: Category(
        id: map['category_id'] as int,
        name: map['category_name'] as String,
        type: CategoryType.values.firstWhere(
          (type) => type.name == map['category_type'],
        ),
      ),
    );
  }).toList();
}
}