class Product {
  final int id;
  final String name;
  final int quantity;
  final String? unit;
  final double price;
  final String? imagePath;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit,
    required this.price,
    this.imagePath,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
      unit: map['unit'] ?? 'units',
      price: map['price'].toDouble(),
      imagePath: map['imagePath'],
      createdAt: map['createdAt'],
      updatedAt: map['updatedAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'price': price,
      'imagePath': imagePath,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}