import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'database_helper.dart';
import 'repositories/product_repository.dart';
import 'repositories/material_repository.dart';
import 'repositories/stock_repository.dart';
import 'notification_service.dart';

class AppState extends ChangeNotifier {
  String userName = 'User';
  String userEmail = '';
  String userPassword = '';
  bool isLoggedIn = false;
  bool rememberMe = false;

  String language = 'EN';
  bool darkMode = false;
  bool offlineSync = true;

  List<Product> products = [];
  List<MaterialItem> materials = [];
  List<NoteItem> notes = [];

  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ProductRepository _productRepo = ProductRepository();
  final MaterialRepository _materialRepo = MaterialRepository();
  final StockRepository _stockRepo = StockRepository();
  
  // Sales helpers
  Future<List<Sale>> getSalesBetween(DateTime start, DateTime end) async {
    return await _dbHelper.getSalesBetween(start, end);
  }

  Future<String> generateSalesCsv(DateTime start, DateTime end) async {
    final sales = await _dbHelper.getSalesBetween(start, end);
    final buffer = StringBuffer();
    buffer.writeln('Tanggal,Produk,Jumlah,Harga,Total');
    for (final s in sales) {
      buffer.writeln('${s.soldAt.toIso8601String()},"${s.productName}",${s.quantity},${s.price.toStringAsFixed(0)},${s.total.toStringAsFixed(0)}');
    }
    // Save to file in app documents directory
    // Note: path_provider must be added; if unavailable, fallback to temp directory
    try {
      // ignore: avoid_dynamic_calls
      // Use conditional import to avoid analyzer errors; simple try-catch for now
      // We'll use getDatabasesPath as a writable directory fallback
      final dir = await getDatabasesPath();
      final path = join(dir, 'sales_${start.toIso8601String()}_${end.toIso8601String()}.csv');
      final file = File(path);
      await file.writeAsString(buffer.toString());
      return path;
    } catch (_) {
      // Fallback to temp
      final path = 'sales_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(buffer.toString());
      return path;
    }
  }

  // ======== Aggregations for charts ========
  Future<List<double>> fetchMonthlyRevenueSeries(int year) async {
    try {
      return await _dbHelper.getRevenueByMonthForYear(year);
    } catch (e) {
      return List<double>.filled(12, 0.0);
    }
  }

  Future<Map<int, double>> fetchYearlyRevenueTotals() async {
    try {
      return await _dbHelper.getRevenueByYearTotals();
    } catch (e) {
      return {};
    }
  }

  // ==================== PRODUCT CRUD METHODS ====================

  Future<void> updateStock(int productId, int change) async {
    try {
      final index = products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        print('[DEBUG] Updating stock for product ID: $productId, change: $change');
        products[index].stock += change;
        if (products[index].stock < 0) products[index].stock = 0;
        print('[DEBUG] New stock: ${products[index].stock}');
        await _productRepo.updateProductStock(productId, products[index].stock);
        print('[DEBUG] Stock updated in database');
        notifyListeners();
      } else {
        print('[ERROR] Product with ID $productId not found');
      }
    } catch (e) {
      print('[ERROR] Error updating stock: $e');
      throw Exception('Error updating stock: $e');
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      print('[DEBUG] Adding product: ${product.name} (ID: ${product.id})');
      await _productRepo.addProduct(product);
      print('[DEBUG] Product saved to database: ${product.name}');
      products.add(product);
      print('[DEBUG] Product added to memory. Total products: ${products.length}');
      notifyListeners();
    } catch (e) {
      print('[ERROR] Error adding product: $e');
      throw Exception('Error adding product: $e');
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      print('[DEBUG] Updating product: ${product.name} (ID: ${product.id})');
      await _productRepo.updateProduct(product);
      print('[DEBUG] Product updated in database: ${product.name}');
      final index = products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        products[index] = product;
        print('[DEBUG] Product updated in memory');
      }
      notifyListeners();
    } catch (e) {
      print('[ERROR] Error updating product: $e');
      throw Exception('Error updating product: $e');
    }
  }

  Future<void> recordProductSold(int productId, int quantity) async {
    try {
      print('[DEBUG] Recording $quantity sold for product ID: $productId');
      final index = products.indexWhere((p) => p.id == productId);
      if (index == -1) {
        print('[ERROR] Product not found for sold recording');
        return;
      }
      // Validation: prevent overselling
      if (quantity <= 0) {
        print('[WARN] Quantity must be > 0');
        return;
      }
      if (quantity > products[index].stock) {
        print('[WARN] Requested sold quantity ($quantity) exceeds stock (${products[index].stock}). Adjusting to available stock.');
        quantity = products[index].stock; // adjust
      }
      // Update sold & stock locally
      products[index].sold += quantity;
      products[index].stock = (products[index].stock - quantity).clamp(0, 1 << 30);
      print('[DEBUG] New sold count: ${products[index].sold}, New stock: ${products[index].stock}');
      // Persist sold increment
      await _dbHelper.updateProductSold(productId, quantity);
      // Persist updated stock separately
      await _productRepo.updateProductStock(productId, products[index].stock);
      // Insert sale record
      final sale = Sale(
        productId: products[index].id,
        productName: products[index].name,
        quantity: quantity,
        price: products[index].price,
        total: products[index].price * quantity,
        soldAt: DateTime.now(),
      );
      await _dbHelper.insertSale(sale);
      notifyListeners();
    } catch (e) {
      print('[ERROR] Error recording sold product: $e');
      throw Exception('Error recording sold product: $e');
    }
  }

  Future<int> getTotalSold() async {
    try {
      return await _dbHelper.getTotalSold();
    } catch (e) {
      print('[ERROR] Error getting total sold: $e');
      return 0;
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      return await _productRepo.searchProducts(query);
    } catch (e) {
      throw Exception('Error searching products: $e');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      print('[DEBUG] Deleting product with ID: $id');
      await _productRepo.deleteProduct(id);
      print('[DEBUG] Product deleted from database');
      products.removeWhere((p) => p.id == id);
      print('[DEBUG] Product removed from memory. Total products: ${products.length}');
      notifyListeners();
    } catch (e) {
      print('[ERROR] Error deleting product: $e');
      throw Exception('Error deleting product: $e');
    }
  }

  Future<List<Product>> getLowStockProducts(int threshold) async {
    try {
      return await _productRepo.getLowStockProducts(threshold);
    } catch (e) {
      throw Exception('Error fetching low stock products: $e');
    }
  }

  Future<int> getProductCount() async {
    try {
      return await _productRepo.getProductCount();
    } catch (e) {
      throw Exception('Error getting product count: $e');
    }
  }

  // ==================== MATERIAL CRUD METHODS ====================

  Future<void> deleteMaterial(int id) async {
    try {
      await _materialRepo.deleteMaterial(id);
      materials.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      throw Exception('Error deleting material: $e');
    }
  }

  Future<void> addMaterial(MaterialItem material) async {
    try {
      await _materialRepo.addMaterial(material);
      materials.add(material);
      notifyListeners();
    } catch (e) {
      throw Exception('Error adding material: $e');
    }
  }

  Future<void> updateMaterial(MaterialItem material) async {
    try {
      await _materialRepo.updateMaterial(material);
      final index = materials.indexWhere((m) => m.id == material.id);
      if (index != -1) {
        materials[index] = material;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error updating material: $e');
    }
  }

  Future<void> clearAllMaterials() async {
    try {
      await _dbHelper.purgeAllMaterials();
      materials.clear();
      notifyListeners();
    } catch (e) {
      throw Exception('Error clearing materials: $e');
    }
  }

  Future<void> updateMaterialImage(int id, String? imagePath) async {
    try {
      final index = materials.indexWhere((m) => m.id == id);
      if (index != -1) {
        materials[index].imageUrl = imagePath;
        await _materialRepo.updateMaterial(materials[index]);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error updating material image: $e');
    }
  }

  Future<List<MaterialItem>> searchMaterials(String query) async {
    try {
      return await _materialRepo.searchMaterials(query);
    } catch (e) {
      throw Exception('Error searching materials: $e');
    }
  }

  Future<List<MaterialItem>> getLowQuantityMaterials(int threshold) async {
    try {
      return await _materialRepo.getLowQuantityMaterials(threshold);
    } catch (e) {
      throw Exception('Error fetching low quantity materials: $e');
    }
  }

  Future<double> getTotalMaterialValue() async {
    try {
      return await _materialRepo.getTotalMaterialValue();
    } catch (e) {
      throw Exception('Error calculating total material value: $e');
    }
  }

  Future<int> getMaterialCount() async {
    try {
      return await _materialRepo.getMaterialCount();
    } catch (e) {
      throw Exception('Error getting material count: $e');
    }
  }

  // ==================== STOCK CRUD METHODS ====================

  Future<List<StockItem>> getRecentStockUpdates({int limit = 10}) async {
    try {
      return await _stockRepo.getRecentStockUpdates(limit: limit);
    } catch (e) {
      throw Exception('Error fetching recent stock updates: $e');
    }
  }

  Future<int> getTotalStockQuantity() async {
    try {
      return await _stockRepo.getTotalStockQuantity();
    } catch (e) {
      throw Exception('Error calculating total stock quantity: $e');
    }
  }

  Future<List<StockItem>> getStockItemsByProductId(String productId) async {
    try {
      return await _stockRepo.getStockItemsByProductId(productId);
    } catch (e) {
      throw Exception('Error fetching stock items: $e');
    }
  }

  Future<int> getStockItemCount() async {
    try {
      return await _stockRepo.getStockItemCount();
    } catch (e) {
      throw Exception('Error getting stock item count: $e');
    }
  }

  void toggleMaterialEdit(int id) {
    final index = materials.indexWhere((m) => m.id == id);
    if (index != -1) {
      materials[index].isEditing = !materials[index].isEditing;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    language = language == 'EN' ? 'ID' : 'EN';
    notifyListeners();
    _saveData();
  }

  void toggleDarkMode() {
    darkMode = !darkMode;
    notifyListeners();
    _saveData();
  }

  void toggleOfflineSync() {
    offlineSync = !offlineSync;
    notifyListeners();
    _saveData();
  }

  // Reset all runtime and persisted data: wipe SQLite, clear lists, clear flags.
  Future<void> resetAllData() async {
    try {
      // Wipe database file
      await _dbHelper.wipeDatabase();
      // Clear in-memory collections
      products.clear();
      materials.clear();
      notes.clear();
      // Clear login/session
      isLoggedIn = false;
      userEmail = '';
      userPassword = '';
      userName = 'User';
      // Clear purge flag so future startup can re-run purge if needed (though DB is empty)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('purge_done');
      await prefs.remove('login_email');
      await prefs.remove('login_password');
      await prefs.remove('remember_me');
      // Recreate fresh database instance and reload structures if needed
      await _dbHelper.database; // triggers init
      notifyListeners();
    } catch (e) {
      throw Exception('Error resetting data: $e');
    }
  }

  // ==================== LOGIN & AUTH METHODS ====================

  Future<bool> login(String email, String password,
      {bool remember = false}) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }

      if (!email.contains('@')) {
        throw Exception('Invalid email format');
      }

      // Check if user is registered in database
      final isValid = await _dbHelper.validateUser(email, password);
      if (!isValid) {
        throw Exception('Invalid email or password. Please check and try again.');
      }

      // Get user data from database
      final userData = await _dbHelper.getUserByEmail(email);
      
      // Save login credentials
      userEmail = email;
      userPassword = password;
      userName = userData?['name'] ?? email.split('@')[0];
      rememberMe = remember;
      isLoggedIn = true;

      // Save to shared preferences
      await _saveLoginData();

      notifyListeners();
      return true;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      userEmail = '';
      userPassword = '';
      userName = 'User';
      isLoggedIn = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userEmail');
      await prefs.remove('userPassword');
      await prefs.remove('rememberMe');

      notifyListeners();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  Future<bool> checkAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail');
      final password = prefs.getString('userPassword');
      final remember = prefs.getBool('rememberMe') ?? false;

      if (email != null && password != null && remember) {
        userEmail = email;
        userPassword = password;
        userName = email.split('@')[0];
        rememberMe = remember;
        isLoggedIn = true;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveLoginData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('userEmail', userEmail);
        await prefs.setString('userPassword', userPassword);
        await prefs.setBool('rememberMe', true);
      } else {
        // Clear saved credentials if not remembering
        await prefs.remove('userEmail');
        await prefs.remove('userPassword');
        await prefs.setBool('rememberMe', false);
      }
    } catch (e) {
      throw Exception('Error saving login data: $e');
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
    await prefs.setString('userEmail', userEmail);
    await prefs.setString('language', language);
    await prefs.setBool('darkMode', darkMode);
    await prefs.setBool('offlineSync', offlineSync);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') ?? 'User';
    userEmail = prefs.getString('userEmail') ?? '';
    language = prefs.getString('language') ?? 'EN';
    darkMode = prefs.getBool('darkMode') ?? false;
    offlineSync = prefs.getBool('offlineSync') ?? true;

    // Load data from database - database already has initial data
    try {
      print('[DEBUG] Loading products and materials from database...');
      products = await _dbHelper.getProducts();
      materials = await _dbHelper.getMaterials();
      print('[DEBUG] Loaded ${products.length} products and ${materials.length} materials');
    } catch (e) {
      print('[ERROR] Error loading data: $e');
      products = [];
      materials = [];
    }

    // Load notes from SharedPreferences
    try {
      final notesJson = prefs.getString('notes');
      if (notesJson != null && notesJson.isNotEmpty) {
        final List list = jsonDecode(notesJson) as List;
        notes = list.map((e) => NoteItem.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        notes = [];
      }
    } catch (e) {
      print('[WARN] Unable to load notes: $e');
      notes = [];
    }

    notifyListeners();
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(notes.map((n) => n.toJson()).toList());
      await prefs.setString('notes', encoded);
    } catch (e) {
      print('[WARN] Unable to save notes: $e');
    }
  }

  // ======== Notes CRUD ========
  void addNote(String title, {String? description}) {
    final id = (notes.isEmpty ? 1 : (notes.map((n) => n.id).reduce((a, b) => a > b ? a : b) + 1));
    final item = NoteItem(id: id, title: title, description: description);
    notes.insert(0, item);
    _saveNotes();
    scheduleNotesReminder();
    notifyListeners();
  }

  void toggleNoteDone(int id, bool done) {
    final idx = notes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notes[idx].done = done;
      _saveNotes();
      scheduleNotesReminder();
      notifyListeners();
    }
  }

  void deleteNote(int id) {
    notes.removeWhere((n) => n.id == id);
    _saveNotes();
    scheduleNotesReminder();
    notifyListeners();
  }

  void updateNote(int id, {String? title, String? description}) {
    final idx = notes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      if (title != null) notes[idx].title = title;
      if (description != null) notes[idx].description = description;
      _saveNotes();
      scheduleNotesReminder();
      notifyListeners();
    }
  }

  // Schedule a reminder notification 3 days ahead with summary of pending notes.
  Future<void> scheduleNotesReminder() async {
    try {
      // Build summary of open notes (max 5 items)
      final pending = notes.where((n) => !n.done).toList();
      if (pending.isEmpty) {
        // No pending notes: cancel existing reminder
        await NotificationService().cancel(9001);
        return;
      }
      final preview = pending.take(5).map((n) => n.title).join(', ');
      final body = pending.length > 5
          ? '$preview, dan lainnya...'
          : preview;
      final scheduleFor = DateTime.now().add(const Duration(days: 3));
      await NotificationService().scheduleNotesReminder(
        id: 9001,
        dateTime: scheduleFor,
        title: 'Pengingat Catatan (${pending.length} belum selesai)',
        body: body,
      );
    } catch (e) {
      print('[WARN] Failed to schedule notes reminder: $e');
    }
  }
}
