import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('smart_pocket.db');

    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabela de categorias
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
        UNIQUE(name, type)
      )
    ''');

    // Tabela de transações
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        category_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        value REAL NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id)
          ON UPDATE CASCADE
          ON DELETE RESTRICT
      )
    ''');

    // Tabela de orçamentos
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL CHECK(amount > 0),
        description TEXT,
        FOREIGN KEY (category_id) REFERENCES categories(id)
          ON UPDATE CASCADE
          ON DELETE RESTRICT,
        UNIQUE(category_id)
      )
    ''');

    // Tabela de perfil
    await db.execute('''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        currency TEXT NOT NULL DEFAULT 'BRL',
        monthly_spending_limit REAL NOT NULL DEFAULT 3000
      )
    ''');

    // Categorias iniciais
    await _insertInitialCategories(db);

    // Perfil inicial
    await db.insert('user_profile', {
      'name': 'Usuário',
      'email': 'usuario@email.com',
      'currency': 'BRL',
      'monthly_spending_limit': 3000.00,
    });
  }

  Future<void> _insertInitialCategories(Database db) async {
    final categories = [
      {'name': 'Alimentação', 'type': 'expense'},
      {'name': 'Transporte', 'type': 'expense'},
      {'name': 'Moradia', 'type': 'expense'},
      {'name': 'Lazer', 'type': 'expense'},
      {'name': 'Saúde', 'type': 'expense'},
      {'name': 'Trabalho', 'type': 'income'},
      {'name': 'Salário', 'type': 'income'},
      {'name': 'Freelance', 'type': 'income'},
    ];

    final batch = db.batch();

    for (final category in categories) {
      batch.insert('categories', category);
    }

    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
    _database = null;
  }
}