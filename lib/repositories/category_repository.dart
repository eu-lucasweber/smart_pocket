
import 'package:smart_pocket/database/database_helper.dart';
import 'package:smart_pocket/models/category.dart';

class CategoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Category>> getAll() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'categories',
      orderBy: 'name ASC',
    );

    return result.map((map) {
      return Category(
        id: map['id'] as int,
        name: map['name'] as String,
        type: map['type'] == 'income'
            ? CategoryType.income
            : CategoryType.expense,
      );
    }).toList();
  }

  Future<Category?> getByNameAndType({
    required String name,
    required CategoryType type,
  }) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'categories',
      where: 'name = ? AND type = ?',
      whereArgs: [name, type.name],
      limit: 1,
    );

    if (result.isEmpty) return null;

    final map = result.first;

    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] == 'income'
          ? CategoryType.income
          : CategoryType.expense,
    );
  }
}
