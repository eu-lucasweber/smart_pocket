import 'package:smart_pocket/database/database_helper.dart';
import 'package:smart_pocket/models/category.dart';

class CategoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Category _fromMap(Map<String, Object?> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      type: map['type'] == 'income'
          ? CategoryType.income
          : CategoryType.expense,
    );
  }

  Future<List<Category>> getAll() async {
    final db = await _databaseHelper.database;

    final result = await db.query('categories', orderBy: 'name ASC');

    return result.map(_fromMap).toList();
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

    return _fromMap(result.first);
  }

  Future<Category> insert({
    required String name,
    required CategoryType type,
  }) async {
    final db = await _databaseHelper.database;

    final id = await db.insert('categories', {
      'name': name,
      'type': type.name,
    });

    return Category(id: id, name: name, type: type);
  }
}