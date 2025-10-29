import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'storekeeper.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Table
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        imagePath TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  // CREATE - Add new product
  Future<int> addProduct({
    required String name,
    required int quantity,
    required double price,
    String? imagePath,
  }) async {
    final db = await database;
    return await db.insert('products', {
      'name': name,
      'quantity': quantity,
      'price': price,
      'imagePath': imagePath,
      'createdAt': DateTime.now().toString(),
    });
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;
    return await db.query('products');
  }

  Future<int> updateProduct({
    required int id,
    required String name,
    required int quantity,
    required double price,
    String? imagePath,
  }) async {
    final db = await database;
    return await db.update(
      'products',
      {
        'name': name,
        'quantity': quantity,
        'price': price,
        'imagePath': imagePath,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Remove product not needed
  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}