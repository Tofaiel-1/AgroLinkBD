import 'package:cloud_firestore/cloud_firestore.dart';

class BuyerInventoryModel {
  final String id;
  final String buyerId;
  final String productId; // Reference to the original product
  final String productName;
  final String category;
  final String? variety;
  final String? quality;
  final double quantity;
  final String unit;
  final double purchasePrice; // Price paid per unit
  final double currentMarketPrice; // Updated from MarketPriceService
  final String location;
  final String status;
  final String? image;
  final DateTime purchaseDate;
  final DateTime updatedAt;
  final String? supplierId;
  final String? supplierName;

  BuyerInventoryModel({
    required this.id,
    required this.buyerId,
    required this.productId,
    required this.productName,
    required this.category,
    this.variety,
    this.quality,
    required this.quantity,
    required this.unit,
    required this.purchasePrice,
    required this.currentMarketPrice,
    required this.location,
    required this.status,
    this.image,
    required this.purchaseDate,
    required this.updatedAt,
    this.supplierId,
    this.supplierName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'buyerId': buyerId,
      'productId': productId,
      'productName': productName,
      'category': category,
      'variety': variety,
      'quality': quality,
      'quantity': quantity,
      'unit': unit,
      'purchasePrice': purchasePrice,
      'currentMarketPrice': currentMarketPrice,
      'location': location,
      'status': status,
      'image': image,
      'purchaseDate': purchaseDate.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'supplierId': supplierId,
      'supplierName': supplierName,
    };
  }

  factory BuyerInventoryModel.fromMap(Map<String, dynamic> map, String documentId) {
    return BuyerInventoryModel(
      id: documentId,
      buyerId: map['buyerId'] ?? '',
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      category: map['category'] ?? '',
      variety: map['variety'],
      quality: map['quality'],
      quantity: (map['quantity'] ?? 0.0).toDouble(),
      unit: map['unit'] ?? 'kg',
      purchasePrice: (map['purchasePrice'] ?? 0.0).toDouble(),
      currentMarketPrice: (map['currentMarketPrice'] ?? 0.0).toDouble(),
      location: map['location'] ?? '',
      status: map['status'] ?? 'In Stock',
      image: map['image'],
      purchaseDate: map['purchaseDate'] != null
          ? DateTime.parse(map['purchaseDate'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
      supplierId: map['supplierId'],
      supplierName: map['supplierName'],
    );
  }

  // Calculate estimated total value
  double get estimatedValue => quantity * currentMarketPrice;

  // Calculate estimated gain
  double get estimatedGain => (currentMarketPrice - purchasePrice) * quantity;
}
