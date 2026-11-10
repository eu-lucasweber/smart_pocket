import 'package:smart_pocket/database/database_helper.dart';
import 'package:smart_pocket/models/category.dart';
import 'package:smart_pocket/models/transaction.dart';

class TransactionRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Transaction>> getAll() async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT
        t.id,
        t.description,
        c.name AS category,
        t.date,
        t.value,
        t.type
      FROM transactions t
      INNER JOIN categories c ON c.id = t.category_id
      ORDER BY t.id DESC
    ''');

    return result.map((map) {
      return Transaction(
        id: map['id'] as int,
        description: map['description'] as String,
        category: map['category'] as String,
        date: map['date'] as String,
        value: (map['value'] as num).toDouble(),
        type: map['type'] == 'income'
            ? CategoryType.income
            : CategoryType.expense,
      );
    }).toList();
  }
}