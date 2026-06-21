enum CartItemType {
  product, // Crops, vegetables, fruits
  supply, // Pesticides, fertilizers, seeds
  transport, // Transport service/truck
  machinery, // Tractor rental etc
  service // General services
}

class CartItem {
  final String id;
  final String title;
  final double price;
  final String unit;
  int quantity;
  final String imageUrl;
  
  // Universal attributes
  final CartItemType itemType;
  final String sellerId;
  final String sellerName;
  final String sellerRole; // 'farmer', 'driver', 'company', etc.

  // Optional attributes based on type
  final Map<String, dynamic> metadata;

  CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.imageUrl,
    required this.itemType,
    required this.sellerId,
    required this.sellerName,
    required this.sellerRole,
    this.metadata = const {},
  });

  double get totalPrice => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'itemType': itemType.toString(),
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerRole': sellerRole,
      'metadata': metadata,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] ?? json['productId'] ?? '', // Support legacy productId
      title: json['title'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      quantity: json['quantity'] ?? 1,
      imageUrl: json['imageUrl'] ?? '',
      itemType: json['itemType'] != null 
          ? CartItemType.values.firstWhere((e) => e.toString() == json['itemType'], orElse: () => CartItemType.product)
          : CartItemType.product,
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      sellerRole: json['sellerRole'] ?? 'unknown',
      metadata: json['metadata'] ?? {},
    );
  }

  CartItem copyWith({
    String? id,
    String? title,
    double? price,
    String? unit,
    int? quantity,
    String? imageUrl,
    CartItemType? itemType,
    String? sellerId,
    String? sellerName,
    String? sellerRole,
    Map<String, dynamic>? metadata,
  }) {
    return CartItem(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      itemType: itemType ?? this.itemType,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerRole: sellerRole ?? this.sellerRole,
      metadata: metadata ?? this.metadata,
    );
  }
}
