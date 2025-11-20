import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models.dart';

class MaterialRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // CREATE - Add new material
  Future<int> addMaterial(MaterialItem material) async {
    try {
      Database db = await _dbHelper.database;
      return await db.insert('materials', material.toJson());
    } catch (e) {
      throw Exception('Error adding material: $e');
    }
  }

  // READ - Get all materials
  Future<List<MaterialItem>> getAllMaterials() async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query('materials');
      return List.generate(maps.length, (i) => MaterialItem.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Error fetching materials: $e');
    }
  }

  // READ - Get material by ID
  Future<MaterialItem?> getMaterialById(int id) async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query(
        'materials',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (maps.isNotEmpty) {
        return MaterialItem.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching material: $e');
    }
  }

  // READ - Search materials by name
  Future<List<MaterialItem>> searchMaterials(String query) async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query(
        'materials',
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
      );
      return List.generate(maps.length, (i) => MaterialItem.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Error searching materials: $e');
    }
  }

  // UPDATE - Update material
  Future<int> updateMaterial(MaterialItem material) async {
    try {
      Database db = await _dbHelper.database;
      return await db.update(
        'materials',
        material.toJson(),
        where: 'id = ?',
        whereArgs: [material.id],
      );
    } catch (e) {
      throw Exception('Error updating material: $e');
    }
  }

  // UPDATE - Update material quantity
  Future<int> updateMaterialQuantity(int materialId, int newQuantity) async {
    try {
      Database db = await _dbHelper.database;
      return await db.update(
        'materials',
        {'quantity': newQuantity},
        where: 'id = ?',
        whereArgs: [materialId],
      );
    } catch (e) {
      throw Exception('Error updating quantity: $e');
    }
  }

  // UPDATE - Update material price
  Future<int> updateMaterialPrice(int materialId, double newPrice) async {
    try {
      Database db = await _dbHelper.database;
      return await db.update(
        'materials',
        {'unitPrice': newPrice},
        where: 'id = ?',
        whereArgs: [materialId],
      );
    } catch (e) {
      throw Exception('Error updating price: $e');
    }
  }

  // DELETE - Delete material
  Future<int> deleteMaterial(int id) async {
    try {
      Database db = await _dbHelper.database;
      return await db.delete(
        'materials',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Error deleting material: $e');
    }
  }

  // DELETE - Delete all materials
  Future<int> deleteAllMaterials() async {
    try {
      Database db = await _dbHelper.database;
      return await db.delete('materials');
    } catch (e) {
      throw Exception('Error deleting all materials: $e');
    }
  }

  // COUNT - Get material count
  Future<int> getMaterialCount() async {
    try {
      Database db = await _dbHelper.database;
      final result =
          await db.rawQuery('SELECT COUNT(*) as count FROM materials');
      return (result.first['count'] as int?) ?? 0;
    } catch (e) {
      throw Exception('Error getting material count: $e');
    }
  }

  // Get materials with low quantity
  Future<List<MaterialItem>> getLowQuantityMaterials(int threshold) async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query(
        'materials',
        where: 'quantity < ?',
        whereArgs: [threshold],
        orderBy: 'quantity ASC',
      );
      return List.generate(maps.length, (i) => MaterialItem.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Error fetching low quantity materials: $e');
    }
  }

  // Get materials sorted by price
  Future<List<MaterialItem>> getMaterialsSortedByPrice(
      {bool ascending = true}) async {
    try {
      Database db = await _dbHelper.database;
      List<Map<String, dynamic>> maps = await db.query(
        'materials',
        orderBy: 'unitPrice ${ascending ? 'ASC' : 'DESC'}',
      );
      return List.generate(maps.length, (i) => MaterialItem.fromJson(maps[i]));
    } catch (e) {
      throw Exception('Error fetching sorted materials: $e');
    }
  }

  // Get total material value (quantity * price)
  Future<double> getTotalMaterialValue() async {
    try {
      Database db = await _dbHelper.database;
      final result = await db
          .rawQuery('SELECT SUM(quantity * unitPrice) as total FROM materials');
      final total = result.first['total'] as double?;
      return total ?? 0.0;
    } catch (e) {
      throw Exception('Error calculating total material value: $e');
    }
  }
}
