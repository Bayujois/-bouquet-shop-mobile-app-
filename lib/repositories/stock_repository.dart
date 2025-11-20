import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models.dart';

class StockRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // CREATE - Add new stock item
  Future<int> addStockItem(StockItem stockItem) async {
    try {
      Database db = await _dbHelper.database;
      return await db.insert('stock_items', stockItem.toJson());
    } catch (e) {
      throw Exception('Error adding stock item: $e');
    }
  }

  // READ - Get all stock items
  Future<List<StockItem>> getAllStockItems() async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query('stock_items');
      return List.generate(maps.length, (i) => StockItem.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Error fetching stock items: $e');
    }
  }

  // READ - Get stock item by ID
  Future<StockItem?> getStockItemById(String id) async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query(
        'stock_items',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return StockItem.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching stock item: $e');
    }
  }

  // READ - Get stock items by product ID
  Future<List<StockItem>> getStockItemsByProductId(String productId) async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query(
        'stock_items',
        where: 'productId = ?',
        whereArgs: [productId],
        orderBy: 'lastUpdated DESC',
      );
      return List.generate(maps.length, (i) => StockItem.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Error fetching stock items by product: $e');
    }
  }

  // UPDATE - Update stock item
  Future<int> updateStockItem(StockItem stockItem) async {
    try {
      Database db = await _dbHelper.database;
      return await db.update(
        'stock_items',
        stockItem.toJson(),
        where: 'id = ?',
        whereArgs: [stockItem.id],
      );
    } catch (e) {
      throw Exception('Error updating stock item: $e');
    }
  }

  // UPDATE - Update stock quantity
  Future<int> updateStockQuantity(String stockId, int newQuantity) async {
    try {
      Database db = await _dbHelper.database;
      return await db.update(
        'stock_items',
        {
          'quantity': newQuantity,
          'lastUpdated': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [stockId],
      );
    } catch (e) {
      throw Exception('Error updating stock quantity: $e');
    }
  }

  // DELETE - Delete stock item
  Future<int> deleteStockItem(String id) async {
    try {
      Database db = await _dbHelper.database;
      return await db.delete(
        'stock_items',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting stock item: $e');
    }
  }

  // DELETE - Delete stock items by product ID
  Future<int> deleteStockItemsByProductId(String productId) async {
    try {
      Database db = await _dbHelper.database;
      return await db.delete(
        'stock_items',
        where: 'productId = ?',
        whereArgs: [productId],
      );
    } catch (e) {
      throw Exception('Error deleting stock items: $e');
    }
  }

  // DELETE - Delete all stock items
  Future<int> deleteAllStockItems() async {
    try {
      Database db = await _dbHelper.database;
      return await db.delete('stock_items');
    } catch (e) {
      throw Exception('Error deleting all stock items: $e');
    }
  }

  // COUNT - Get stock item count
  Future<int> getStockItemCount() async {
    try {
      Database db = await _dbHelper.database;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM stock_items');
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      throw Exception('Error getting stock item count: $e');
    }
  }

  // Get recent stock updates
  Future<List<StockItem>> getRecentStockUpdates({int limit = 10}) async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query(
        'stock_items',
        orderBy: 'lastUpdated DESC',
        limit: limit,
      );
      return List.generate(maps.length, (i) => StockItem.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Error fetching recent stock updates: $e');
    }
  }

  // Get total stock quantity
  Future<int> getTotalStockQuantity() async {
    try {
      Database db = await _dbHelper.database;
      final result =
          await db.rawQuery('SELECT SUM(quantity) as total FROM stock_items');
      final total = result.first['total'] as int?;
      return total ?? 0;
    } catch (e) {
      throw Exception('Error calculating total stock quantity: $e');
    }
  }
}
