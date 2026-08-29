import '../utils/masked_identity_helper.dart';

enum ProductCategory {
  vegetables,
  fruits,
  grains,
  seeds,
  fertilizers,
  pesticides,
  tools,
  fish,
  meat,
  dairy,
  other,
}

enum ProductStatus { available, sold, reserved, expired }

class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String? maskedSellerName;
  final String title;
  final String description;
  final ProductCategory category;
  final double price;
  final String unit; // kg, quintal, ton, piece
  final double quantity;
  final List<String> images;
  final String? location;
  final String? district;
  final String? upazila;
  final double? latitude;
  final double? longitude;
  final ProductStatus status;
  final bool isFeatured;
  final bool isOrganic;
  final String qualityGrade; // Grade A, Grade B, Grade C
  final String batchCode;
  final double minOrderQuantity;
  final bool escrowProtected;
  final DateTime? harvestDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int views;
  final int favorites;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    String? maskedSellerName,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.unit,
    required this.quantity,
    required this.images,
    this.location,
    this.district,
    this.upazila,
    this.latitude,
    this.longitude,
    this.status = ProductStatus.available,
    this.isFeatured = false,
    this.isOrganic = false,
    this.qualityGrade = 'Grade A (প্রিমিয়াম)',
    String? batchCode,
    this.minOrderQuantity = 1.0,
    this.escrowProtected = true,
    this.harvestDate,
    required this.createdAt,
    this.updatedAt,
    this.views = 0,
    this.favorites = 0,
  })  : maskedSellerName = maskedSellerName ??
            MaskedIdentityHelper.getMaskedFarmerName(
              userId: sellerId,
              district: district,
              upazila: upazila,
              fallbackName: sellerName,
            ),
        batchCode = batchCode ?? MaskedIdentityHelper.generateBatchCode();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'maskedSellerName': maskedSellerName,
      'title': title,
      'description': description,
      'category': category.toString(),
      'price': price,
      'unit': unit,
      'quantity': quantity,
      'images': images,
      'location': location,
      'district': district,
      'upazila': upazila,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.toString(),
      'isFeatured': isFeatured,
      'isOrganic': isOrganic,
      'qualityGrade': qualityGrade,
      'batchCode': batchCode,
      'minOrderQuantity': minOrderQuantity,
      'escrowProtected': escrowProtected,
      'harvestDate': harvestDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'views': views,
      'favorites': favorites,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    ProductCategory cat = ProductCategory.other;
    try {
      cat = ProductCategory.values.firstWhere(
        (e) => e.toString() == json['category'] || e.name == json['category'],
      );
    } catch (_) {
      cat = ProductCategory.other;
    }

    ProductStatus stat = ProductStatus.available;
    try {
      stat = ProductStatus.values.firstWhere(
        (e) => e.toString() == json['status'] || e.name == json['status'],
      );
    } catch (_) {
      stat = ProductStatus.available;
    }

    return ProductModel(
      id: json['id'] ?? '',
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? 'Agro Farmer',
      maskedSellerName: json['maskedSellerName'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: cat,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'কেজি',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      images: List<String>.from(json['images'] ?? []),
      location: json['location'],
      district: json['district'],
      upazila: json['upazila'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: stat,
      isFeatured: json['isFeatured'] ?? false,
      isOrganic: json['isOrganic'] ?? false,
      qualityGrade: json['qualityGrade'] ?? 'Grade A (প্রিমিয়াম)',
      batchCode: json['batchCode'],
      minOrderQuantity: (json['minOrderQuantity'] as num?)?.toDouble() ?? 1.0,
      escrowProtected: json['escrowProtected'] ?? true,
      harvestDate: json['harvestDate'] != null
          ? DateTime.tryParse(json['harvestDate'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      views: json['views'] ?? 0,
      favorites: json['favorites'] ?? 0,
    );
  }
}
