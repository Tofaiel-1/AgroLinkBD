enum ProductCategory {
  vegetables,
  fruits,
  grains,
  seeds,
  fertilizers,
  pesticides,
  tools,
  other,
}

enum ProductStatus { available, sold, reserved, expired }

class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
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
  final DateTime? harvestDate;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int views;
  final int favorites;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
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
    this.harvestDate,
    required this.createdAt,
    this.updatedAt,
    this.views = 0,
    this.favorites = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
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
      'harvestDate': harvestDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'views': views,
      'favorites': favorites,
    };
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      sellerId: json['sellerId'],
      sellerName: json['sellerName'],
      title: json['title'],
      description: json['description'],
      category: ProductCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
      ),
      price: json['price'].toDouble(),
      unit: json['unit'],
      quantity: json['quantity'].toDouble(),
      images: List<String>.from(json['images']),
      location: json['location'],
      district: json['district'],
      upazila: json['upazila'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      status: ProductStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      isFeatured: json['isFeatured'] ?? false,
      isOrganic: json['isOrganic'] ?? false,
      harvestDate: json['harvestDate'] != null
          ? DateTime.parse(json['harvestDate'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      views: json['views'] ?? 0,
      favorites: json['favorites'] ?? 0,
    );
  }
}
