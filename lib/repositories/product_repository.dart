import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models.dart';

class ProductRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // CREATE - Add new product
  Future<int> addProduct(Product product) async {
    try {
      Database db = await _dbHelper.database;
      return await db.insert('products', product.toJson());
    } catch (e) {
      throw Exception('Error adding product: $e');
    }
  }

  // READ - Get all products
  Future<List<Product>> getAllProducts() async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query('products');
      return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  // READ - Get product by ID
  Future<Product?> getProductById(int id) async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return Product.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching product: $e');
    }
  }

  // READ - Get products by name (search)
  Future<List<Product>> searchProducts(String query) async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );
      return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

  // UPDATE - Update product
  Future<int> updateProduct(Product product) async {
    try {
      Database db = await _dbHelper.database;
      return await db.update(
        'products',
        product.toJson(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } catch (e) {
      throw Exception('Error updating product: $e');
    }
  }

  // UPDATE - Update product stock
  Future<int> updateProductStock(int productId, int newStock) async {
    try {
      Database db = await _dbHelper.database;
      return await db.update(
        'products',
        {'stock': newStock},
        where: 'id = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      throw Exception('Error updating stock: $e');
    }
  }

  // DELETE - Delete product
  Future<int> deleteProduct(int id) async {
    try {
      Database db = await _dbHelper.database;
      return await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  // DELETE - Delete all products
  Future<int> deleteAllProducts() async {
    try {
      Database db = await _dbHelper.database;
      return await db.delete('products');
    } catch (e) {
      throw Exception('Error deleting all products: $e');
    }
  }

  // COUNT - Get product count
  Future<int> getProductCount() async {
    try {
      Database db = await _dbHelper.database;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM products');
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      throw Exception('Error getting product count: $e');
    }
  }

  // Get products with low stock
  Future<List<Product>> getLowStockProducts(int threshold) async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'stock < ?',
        whereArgs: [threshold],
        orderBy: 'stock ASC',
      );
      return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Error fetching low stock products: $e');
    }
  }

  // Get products sorted by price
  Future<List<Product>> getProductsSortedByPrice(
      {bool ascending = true}) async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query(
        'products',
        orderBy: 'price ${ascending ? 'ASC' : 'DESC'}',
      );
      return List.generate(maps.length, (i) => Product.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Error fetching sorted products: $e');
    }
  }
}
