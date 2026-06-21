import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String productNamebn;
  final double price;
  final int quantity;
  final String unit;
  final String farmerId;
  final String farmerName;
  final List<String> productImages;
  final DateTime addedAt;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productNamebn,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.farmerId,
    required this.farmerName,
    required this.productImages,
    required this.addedAt,
  });

  double getTotalPrice() => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productNamebn': productNamebn,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'productImages': productImages,
      'addedAt': addedAt,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      id: map['id'] as String? ?? '',
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      productNamebn: map['productNamebn'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      quantity: map['quantity'] as int? ?? 1,
      unit: map['unit'] as String? ?? 'kg',
      farmerId: map['farmerId'] as String? ?? '',
      farmerName: map['farmerName'] as String? ?? '',
      productImages: List<String>.from(map['productImages'] as List? ?? []),
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productNamebn,
    double? price,
    int? quantity,
    String? unit,
    String? farmerId,
    String? farmerName,
    List<String>? productImages,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productNamebn: productNamebn ?? this.productNamebn,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      productImages: productImages ?? this.productImages,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class CartModel {
  final String id;
  final String buyerId;
  final List<CartItemModel> items;
  final String? couponCode;
  final double discountAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartModel({
    required this.id,
    required this.buyerId,
    required this.items,
    this.couponCode,
    this.discountAmount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  double getSubtotal() =>
      items.fold(0, (sum, item) => sum + item.getTotalPrice());

  double getDeliveryFee() => getSubtotal() > 5000 ? 0 : 100;

  double getTaxAmount() => getSubtotal() * 0.05;

  double getTotal() =>
      getSubtotal() + getDeliveryFee() + getTaxAmount() - discountAmount;

  int getItemCount() => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'items': items.map((item) => item.toMap()).toList(),
      'couponCode': couponCode,
      'discountAmount': discountAmount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CartModel.fromMap(Map<String, dynamic> map) {
    return CartModel(
      id: map['id'] as String? ?? '',
      buyerId: map['buyerId'] as String? ?? '',
      items: (map['items'] as List?)
              ?.map(
                  (item) => CartItemModel.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      couponCode: map['couponCode'] as String?,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  CartModel copyWith({
    String? id,
    String? buyerId,
    List<CartItemModel>? items,
    String? couponCode,
    double? discountAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      items: items ?? this.items,
      couponCode: couponCode ?? this.couponCode,
      discountAmount: discountAmount ?? this.discountAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
