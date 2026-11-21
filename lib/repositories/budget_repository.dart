import 'package:smart_pocket/database/database_helper.dart';
import 'package:smart_pocket/models/budget.dart';
import 'package:smart_pocket/models/category.dart';

class BudgetRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Budget>> getAll() async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery('''
      SELECT b.id, b.amount, b.description,
             c.id AS category_id, c.name AS category_name, c.type AS category_type
      FROM budgets b
      INNER JOIN categories c ON c.id = b.category_id
      ORDER BY c.name ASC
    ''');

    return result.map((map) {
      return Budget(
        id: map['id'] as int,
        amount: (map['amount'] as num).toDouble(),
        description: map['description'] as String?,
        category: Category(
          id: map['category_id'] as int,
          name: map['category_name'] as String,
          type: map['category_type'] == 'income'
              ? CategoryType.income
              : CategoryType.expense,
        ),
      );
    }).toList();
  }

  Future<int> insert(Budget budget) async {
    final db = await _databaseHelper.database;

    return db.insert('budgets', {
      'category_id': budget.category.id,
      'amount': budget.amount,
      'description': budget.description,
    });
  }

  Future<void> update(Budget budget) async {
    final db = await _databaseHelper.database;

    await db.update(
      'budgets',
      {
        'category_id': budget.category.id,
        'amount': budget.amount,
        'description': budget.description,
      },
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;
    await db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}