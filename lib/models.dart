class Product {
  final int id;
  final String name;
  final double price;
  int stock;
  int sold;
  final String imageUrl;
  final String materials;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.sold = 0,
    required this.imageUrl,
    required this.materials,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      stock: json['stock'],
      sold: json['sold'] ?? 0,
      imageUrl: json['imageUrl'],
      materials: json['materials'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock,
      'sold': sold,
      'imageUrl': imageUrl,
      'materials': materials,
    };
  }
}

class MaterialItem {
  final int id;
  final String name;
  double unitPrice;
  int quantity;
  final String unit;
  bool isEditing;
  String? imageUrl;

  MaterialItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.unit,
    this.isEditing = false,
    this.imageUrl,
  });

  factory MaterialItem.fromJson(Map<String, dynamic> json) {
    return MaterialItem(
      id: json['id'],
      name: json['name'],
      unitPrice: json['unitPrice'],
      quantity: json['quantity'],
      unit: json['unit'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'unit': unit,
      'imageUrl': imageUrl,
    };
  }
}

class StockItem {
  final String id;
  final String productId;
  final int quantity;
  final DateTime lastUpdated;

  StockItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.lastUpdated,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'],
      productId: json['productId'],
      quantity: json['quantity'],
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}

class Sale {
  final int? id;
  final int productId;
  final String productName;
  final int quantity;
  final double price; // unit price
  final double total; // quantity * price
  final DateTime soldAt;

  Sale({
    this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.total,
    required this.soldAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as int?,
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      soldAt: DateTime.parse(json['soldAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'total': total,
      'soldAt': soldAt.toIso8601String(),
    };
  }
}

class NoteItem {
  int id;
  String title;
  String? description;
  bool done;
  DateTime createdAt;

  NoteItem({
    required this.id,
    required this.title,
    this.description,
    this.done = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      done: (json['done'] as bool?) ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'done': done,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
