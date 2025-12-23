import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/subscription.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('bibill.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const textNullable = 'TEXT';
    // New columns default: category 'Lainnya', free_trial_days 0

    await db.execute('''
CREATE TABLE subscriptions ( 
  id $idType, 
  name $textType,
  price $doubleType,
  period $intType,
  first_bill_date $textType,
  reminders $textType,
  category $textType DEFAULT 'Lainnya',
  free_trial_days $intType DEFAULT 0,
  icon_path $textNullable
  )
''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add category and free_trial_days columns
      await db.execute(
        "ALTER TABLE subscriptions ADD COLUMN category TEXT DEFAULT 'Lainnya'",
      );
      await db.execute(
        "ALTER TABLE subscriptions ADD COLUMN free_trial_days INTEGER DEFAULT 0",
      );
    }
    if (oldVersion < 3) {
      await db.execute("ALTER TABLE subscriptions ADD COLUMN icon_path TEXT");
    }
  }

  Future<void> create(Subscription subscription) async {
    final db = await instance.database;
    await db.insert(
      'subscriptions',
      subscription.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Subscription>> readAllSubscriptions() async {
    final db = await instance.database;
    final orderBy = 'first_bill_date ASC';
    final result = await db.query('subscriptions', orderBy: orderBy);

    return result.map((json) => Subscription.fromMap(json)).toList();
  }

  Future<int> update(Subscription subscription) async {
    final db = await instance.database;
    return db.update(
      'subscriptions',
      subscription.toMap(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await instance.database;
    return await db.delete('subscriptions', where: 'id = ?', whereArgs: [id]);
  }
}
