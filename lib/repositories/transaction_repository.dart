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

  Future<List<Transaction>> getAllByMonth({
    required int month,
    required int year,
  }) async {
    final db = await _databaseHelper.database;

    final monthFormatted = month.toString().padLeft(2, '0');

    final result = await db.rawQuery(
      '''
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
    WHERE substr(t.date, 4, 2) = ?
      AND substr(t.date, 7, 4) = ?
    ORDER BY t.id DESC
  ''',
      [monthFormatted, year.toString()],
    );

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

  Future<int> insert({
    required String description,
    required int categoryId,
    required String date,
    required double value,
  }) async {
    final db = await _databaseHelper.database;

    return await db.insert('transactions', {
      'description': description,
      'category_id': categoryId,
      'date': date,
      'value': value,
    });
  }

  Future<int> update({
    required int id,
    required String description,
    required int categoryId,
    required String date,
    required double value,
  }) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'transactions',
      {
        'description': description,
        'category_id': categoryId,
        'date': date,
        'value': value,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
