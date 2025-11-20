import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'bloom_manager.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Migration from version 1 to version 2: Add users table
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          name TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      ''');
    }

    // Migration from version 2 to version 3: Add imageUrl column to materials table
    if (oldVersion < 3) {
      try {
        await db.execute('ALTER TABLE materials ADD COLUMN imageUrl TEXT');
      } catch (e) {
        print('[DEBUG] Column imageUrl might already exist: $e');
      }
    }

    // Migration from version 3 to version 4: Add sold column to products table
    if (oldVersion < 4) {
      try {
        await db
            .execute('ALTER TABLE products ADD COLUMN sold INTEGER DEFAULT 0');
      } catch (e) {
        print('[DEBUG] Column sold might already exist: $e');
      }
    }

    // Migration from version 4 to version 5: Create sales table
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS sales(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER NOT NULL,
          productName TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          price REAL NOT NULL,
          total REAL NOT NULL,
          soldAt TEXT NOT NULL
        )
      ''');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_sales_soldAt ON sales(soldAt)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_sales_productId ON sales(productId)');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        imageUrl TEXT NOT NULL,
        materials TEXT NOT NULL,
        sold INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE materials(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        unitPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        unit TEXT NOT NULL,
        imageUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE stock_items(
        id TEXT PRIMARY KEY,
        productId TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        lastUpdated TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        productId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        price REAL NOT NULL,
        total REAL NOT NULL,
        soldAt TEXT NOT NULL
      )
    ''');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sales_soldAt ON sales(soldAt)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_sales_productId ON sales(productId)');

    // No initial data inserted - clean database for production
  }

  // CRUD operations for Products - FIXED with explicit type casting
  Future<List<Product>> getProducts() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        price: (maps[i]['price'] as num).toDouble(),
        stock: maps[i]['stock'] as int,
        sold: maps[i]['sold'] as int? ?? 0,
        imageUrl: maps[i]['imageUrl'] as String,
        materials: maps[i]['materials'] as String,
      );
    });
  }

  Future<int> insertProduct(Product product) async {
    Database db = await database;
    return await db.insert('products', product.toJson());
  }

  Future<int> updateProduct(Product product) async {
    Database db = await database;
    return await db.update(
      'products',
      product.toJson(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    Database db = await database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateProductSold(int id, int quantity) async {
    Database db = await database;
    return await db.rawUpdate(
      'UPDATE products SET sold = sold + ? WHERE id = ?',
      [quantity, id],
    );
  }

  Future<int> getTotalSold() async {
    Database db = await database;
    final result = await db.rawQuery('SELECT SUM(sold) as total FROM products');
    return (result.first['total'] as int?) ?? 0;
  }

  // Sales CRUD
  Future<int> insertSale(Sale sale) async {
    final db = await database;
    return await db.insert('sales', sale.toJson());
  }

  Future<List<Sale>> getSalesBetween(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'sales',
      where: 'soldAt BETWEEN ? AND ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
      orderBy: 'soldAt DESC',
    );
    return maps.map((m) => Sale.fromJson(m)).toList();
  }

  Future<double> getMonthlyRevenue(int year, int month) async {
    final db = await database;
    final start = DateTime(year, month, 1);
    final end =
        DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1));
    final result = await db.rawQuery(
      'SELECT SUM(total) as revenue FROM sales WHERE soldAt BETWEEN ? AND ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    final val = result.first['revenue'];
    if (val == null) return 0.0;
    return (val as num).toDouble();
  }

  // Revenue per month for a given year (Jan..Dec)
  Future<List<double>> getRevenueByMonthForYear(int year) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT strftime('%m', soldAt) as m, SUM(total) as revenue
      FROM sales
      WHERE strftime('%Y', soldAt) = ?
      GROUP BY m
      ORDER BY m ASC
      ''', [year.toString()]);
    final List<double> series = List<double>.filled(12, 0.0);
    for (final row in rows) {
      final mStr = row['m'] as String?;
      final rev = row['revenue'];
      if (mStr != null) {
        final idx = int.tryParse(mStr) ?? 0;
        if (idx >= 1 && idx <= 12) {
          series[idx - 1] = (rev as num?)?.toDouble() ?? 0.0;
        }
      }
    }
    return series;
  }

  // Revenue totals grouped by year (sorted ascending by year)
  Future<Map<int, double>> getRevenueByYearTotals() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT strftime('%Y', soldAt) as y, SUM(total) as revenue
      FROM sales
      GROUP BY y
      ORDER BY y ASC
      ''');
    final Map<int, double> result = {};
    for (final row in rows) {
      final yStr = row['y'] as String?;
      final rev = row['revenue'];
      if (yStr != null) {
        final y = int.tryParse(yStr);
        if (y != null) {
          result[y] = (rev as num?)?.toDouble() ?? 0.0;
        }
      }
    }
    return result;
  }

  // CRUD operations for Materials - FIXED with explicit type casting
  Future<List<MaterialItem>> getMaterials() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('materials');
    return List.generate(maps.length, (i) {
      return MaterialItem(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        unitPrice: (maps[i]['unitPrice'] as num).toDouble(),
        quantity: maps[i]['quantity'] as int,
        unit: maps[i]['unit'] as String,
      );
    });
  }

  Future<int> insertMaterial(MaterialItem material) async {
    Database db = await database;
    return await db.insert('materials', material.toJson());
  }

  Future<int> updateMaterial(MaterialItem material) async {
    Database db = await database;
    return await db.update(
      'materials',
      material.toJson(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }

  Future<int> deleteMaterial(int id) async {
    Database db = await database;
    return await db.delete(
      'materials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Stock Items
  Future<List<StockItem>> getStockItems() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('stock_items');
    return List.generate(maps.length, (i) {
      return StockItem(
        id: maps[i]['id'] as String,
        productId: maps[i]['productId'] as String,
        quantity: maps[i]['quantity'] as int,
        lastUpdated: DateTime.parse(maps[i]['lastUpdated'] as String),
      );
    });
  }

  Future<int> insertStockItem(StockItem stockItem) async {
    Database db = await database;
    return await db.insert('stock_items', stockItem.toJson());
  }

  Future<int> updateStockItem(StockItem stockItem) async {
    Database db = await database;
    return await db.update(
      'stock_items',
      stockItem.toJson(),
      where: 'id = ?',
      whereArgs: [stockItem.id],
    );
  }

  Future<int> deleteStockItem(String id) async {
    Database db = await database;
    return await db.delete(
      'stock_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD operations for Users
  Future<int> registerUser(String email, String password, String name) async {
    Database db = await database;
    return await db.insert('users', {
      'email': email,
      'password': password,
      'name': name,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null;
  }

  Future<bool> emailExists(String email) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return maps.isNotEmpty;
  }

  Future<bool> validateUser(String email, String password) async {
    final user = await getUserByEmail(email);
    if (user == null) return false;
    return user['password'] == password;
  }

  // Get database file path for backup and access
  Future<String> getDatabaseFilePath() async {
    String path = join(await getDatabasesPath(), 'bloom_manager.db');
    return path;
  }

  // Get database directory path
  Future<String> getDatabaseDirectory() async {
    return await getDatabasesPath();
  }

  // Close database
  Future<void> close() async {
    Database db = await database;
    db.close();
  }

  // Purge legacy sample seed data (run once before release). Uses explicit name/email matching.
  Future<void> purgeSampleData() async {
    final db = await database;
    // Sample product names that should be removed
    const sampleProducts = [
      'Rose Romance Bouquet',
      'Lavender Dream',
      'Sunflower Delight',
      'Tulip Elegance',
      'Orchid Paradise',
      'Wildflower Mix'
    ];
    // Remove products by name
    for (final name in sampleProducts) {
      await db.delete('products', where: 'name = ?', whereArgs: [name]);
    }
    // Sample materials
    const sampleMaterials = [
      'Red Roses',
      'Lavender',
      'Sunflowers',
      'Tulips (Mixed)',
      'Orchids',
      'Silk Ribbon',
      'Decorative Paper',
      'Green Ribbon'
    ];
    for (final name in sampleMaterials) {
      await db.delete('materials', where: 'name = ?', whereArgs: [name]);
    }
    // Sample users
    const sampleEmails = [
      'admin@bayujois.com',
      'user@bayujois.com',
      'john@bayujois.com',
      'manager@bayujois.com'
    ];
    for (final email in sampleEmails) {
      await db.delete('users', where: 'email = ?', whereArgs: [email]);
    }
    // Remove sales referencing those product names
    for (final name in sampleProducts) {
      await db.delete('sales', where: 'productName = ?', whereArgs: [name]);
    }
  }

  // Completely delete the SQLite file and reset in-memory database instance.
  Future<void> wipeDatabase() async {
    final path = join(await getDatabasesPath(), 'bloom_manager.db');
    try {
      await _database?.close();
    } catch (_) {}
    _database = null;
    await deleteDatabase(path);
  }

  // Delete all materials rows (keeps table schema intact)
  Future<int> purgeAllMaterials() async {
    final db = await database;
    return await db.delete('materials');
  }
}
