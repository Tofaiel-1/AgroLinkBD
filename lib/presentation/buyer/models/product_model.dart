import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String namebn;
  final String variety;
  final String description;
  final String category;
  final double price;
  final double originalPrice;
  final String unit; // kg, piece, dozen, etc
  final int availableStock;
  final List<String> images;
  final String farmerId;
  final String farmerName;
  final double farmerRating;
  final int totalOrders;
  final double averageRating;
  final int reviewCount;
  final DateTime harvestDate;
  final DateTime? expiryDate;
  final bool isOrganic;
  final bool isDiscounted;
  final double discountPercentage;
  final List<String> certifications; // 'organic', 'gi-tag', etc
  final Map<String, double> bulkPricing; // quantity -> price
  final String farmLocation;
  final double distance; // in km from buyer
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.namebn,
    required this.variety,
    required this.description,
    required this.category,
    required this.price,
    required this.originalPrice,
    required this.unit,
    required this.availableStock,
    required this.images,
    required this.farmerId,
    required this.farmerName,
    required this.farmerRating,
    required this.totalOrders,
    required this.averageRating,
    required this.reviewCount,
    required this.harvestDate,
    this.expiryDate,
    this.isOrganic = false,
    this.isDiscounted = false,
    this.discountPercentage = 0,
    this.certifications = const [],
    this.bulkPricing = const {},
    required this.farmLocation,
    this.distance = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'namebn': namebn,
      'variety': variety,
      'description': description,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'unit': unit,
      'availableStock': availableStock,
      'images': images,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerRating': farmerRating,
      'totalOrders': totalOrders,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'harvestDate': harvestDate,
      'expiryDate': expiryDate,
      'isOrganic': isOrganic,
      'isDiscounted': isDiscounted,
      'discountPercentage': discountPercentage,
      'certifications': certifications,
      'bulkPricing': bulkPricing,
      'farmLocation': farmLocation,
      'distance': distance,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      namebn: map['namebn'] as String? ?? '',
      variety: map['variety'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble() ?? 0,
      unit: map['unit'] as String? ?? 'kg',
      availableStock: map['availableStock'] as int? ?? 0,
      images: List<String>.from(map['images'] as List? ?? []),
      farmerId: map['farmerId'] as String? ?? '',
      farmerName: map['farmerName'] as String? ?? '',
      farmerRating: (map['farmerRating'] as num?)?.toDouble() ?? 0,
      totalOrders: map['totalOrders'] as int? ?? 0,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: map['reviewCount'] as int? ?? 0,
      harvestDate:
          (map['harvestDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiryDate: (map['expiryDate'] as Timestamp?)?.toDate(),
      isOrganic: map['isOrganic'] as bool? ?? false,
      isDiscounted: map['isDiscounted'] as bool? ?? false,
      discountPercentage: (map['discountPercentage'] as num?)?.toDouble() ?? 0,
      certifications: List<String>.from(map['certifications'] as List? ?? []),
      bulkPricing: Map<String, double>.from(
        (map['bulkPricing'] as Map?)
                ?.map((k, v) => MapEntry(k as String, (v as num).toDouble())) ??
            {},
      ),
      farmLocation: map['farmLocation'] as String? ?? '',
      distance: (map['distance'] as num?)?.toDouble() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? namebn,
    String? variety,
    String? description,
    String? category,
    double? price,
    double? originalPrice,
    String? unit,
    int? availableStock,
    List<String>? images,
    String? farmerId,
    String? farmerName,
    double? farmerRating,
    int? totalOrders,
    double? averageRating,
    int? reviewCount,
    DateTime? harvestDate,
    DateTime? expiryDate,
    bool? isOrganic,
    bool? isDiscounted,
    double? discountPercentage,
    List<String>? certifications,
    Map<String, double>? bulkPricing,
    String? farmLocation,
    double? distance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      namebn: namebn ?? this.namebn,
      variety: variety ?? this.variety,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      unit: unit ?? this.unit,
      availableStock: availableStock ?? this.availableStock,
      images: images ?? this.images,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerRating: farmerRating ?? this.farmerRating,
      totalOrders: totalOrders ?? this.totalOrders,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      harvestDate: harvestDate ?? this.harvestDate,
      expiryDate: expiryDate ?? this.expiryDate,
      isOrganic: isOrganic ?? this.isOrganic,
      isDiscounted: isDiscounted ?? this.isDiscounted,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      certifications: certifications ?? this.certifications,
      bulkPricing: bulkPricing ?? this.bulkPricing,
      farmLocation: farmLocation ?? this.farmLocation,
      distance: distance ?? this.distance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
