import 'package:cloud_firestore/cloud_firestore.dart';

/// Service Provider Product Model
/// Represents products sold by agricultural service providers
/// Categories: সার, কীটনাশক, ট্র্যাক্টর, বীজ, যন্ত্রপাতি, পরামর্শ

enum ServiceProductCategory {
  fertilizer,   // সার
  pesticide,    // কীটনাশক
  tractor,      // ট্র্যাক্টর
  seed,         // বীজ
  equipment,    // কৃষি যন্ত্রপাতি
  advisory,     // কৃষি পরামর্শ
}

extension ServiceProductCategoryExt on ServiceProductCategory {
  String get bengaliName {
    switch (this) {
      case ServiceProductCategory.fertilizer: return 'সার';
      case ServiceProductCategory.pesticide: return 'কীটনাশক';
      case ServiceProductCategory.tractor: return 'ট্র্যাক্টর';
      case ServiceProductCategory.seed: return 'বীজ';
      case ServiceProductCategory.equipment: return 'যন্ত্রপাতি';
      case ServiceProductCategory.advisory: return 'পরামর্শ';
    }
  }

  String get englishName {
    switch (this) {
      case ServiceProductCategory.fertilizer: return 'Fertilizer';
      case ServiceProductCategory.pesticide: return 'Pesticide';
      case ServiceProductCategory.tractor: return 'Tractor';
      case ServiceProductCategory.seed: return 'Seeds';
      case ServiceProductCategory.equipment: return 'Equipment';
      case ServiceProductCategory.advisory: return 'Advisory';
    }
  }

  String get icon {
    switch (this) {
      case ServiceProductCategory.fertilizer: return '🧪';
      case ServiceProductCategory.pesticide: return '🔬';
      case ServiceProductCategory.tractor: return '🚜';
      case ServiceProductCategory.seed: return '🌱';
      case ServiceProductCategory.equipment: return '🔧';
      case ServiceProductCategory.advisory: return '📋';
    }
  }
}

class ServiceProduct {
  final String id;
  final String shopOwnerId;
  final String name;
  final String? nameEN;
  final String description;
  final String? descriptionEN;
  final ServiceProductCategory category;
  final double price;
  final double? discountPrice;
  final int stockQuantity;
  final String unit; // কেজি, লিটার, প্যাকেট, পিস
  final String? unitEN; // kg, liter, packet, pcs
  final String? brand;
  final List<String> images;
  final double rating;
  final int totalSold;
  final int totalReviews;
  final bool isAvailable;
  final bool isForRent; // For tractors/equipment
  final double? rentPricePerDay;
  final DateTime createdAt;

  ServiceProduct({
    required this.id,
    required this.shopOwnerId,
    required this.name,
    this.nameEN,
    required this.description,
    this.descriptionEN,
    required this.category,
    required this.price,
    this.discountPrice,
    required this.stockQuantity,
    required this.unit,
    this.unitEN,
    this.brand,
    this.images = const [],
    this.rating = 0.0,
    this.totalSold = 0,
    this.totalReviews = 0,
    this.isAvailable = true,
    this.isForRent = false,
    this.rentPricePerDay,
    required this.createdAt,
  });

  ServiceProduct copyWith({
    String? id,
    String? shopOwnerId,
    String? name,
    String? nameEN,
    String? description,
    String? descriptionEN,
    ServiceProductCategory? category,
    double? price,
    double? discountPrice,
    int? stockQuantity,
    String? unit,
    String? unitEN,
    String? brand,
    List<String>? images,
    double? rating,
    int? totalSold,
    int? totalReviews,
    bool? isAvailable,
    bool? isForRent,
    double? rentPricePerDay,
    DateTime? createdAt,
  }) {
    return ServiceProduct(
      id: id ?? this.id,
      shopOwnerId: shopOwnerId ?? this.shopOwnerId,
      name: name ?? this.name,
      nameEN: nameEN ?? this.nameEN,
      description: description ?? this.description,
      descriptionEN: descriptionEN ?? this.descriptionEN,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
      unitEN: unitEN ?? this.unitEN,
      brand: brand ?? this.brand,
      images: images ?? this.images,
      rating: rating ?? this.rating,
      totalSold: totalSold ?? this.totalSold,
      totalReviews: totalReviews ?? this.totalReviews,
      isAvailable: isAvailable ?? this.isAvailable,
      isForRent: isForRent ?? this.isForRent,
      rentPricePerDay: rentPricePerDay ?? this.rentPricePerDay,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String getName(bool isBn) => isBn ? name : (nameEN ?? name);
  String getUnit(bool isBn) => isBn ? unit : (unitEN ?? unit);
  String getDescription(bool isBn) => isBn ? description : (descriptionEN ?? description);

  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  double get effectivePrice => discountPrice ?? price;
  double get discountPercentage => hasDiscount ? ((price - discountPrice!) / price * 100) : 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 10;
  bool get isOutOfStock => stockQuantity <= 0;

  static ServiceProductCategory categoryFromString(String? cat) {
    if (cat == null) return ServiceProductCategory.fertilizer;
    switch (cat.toLowerCase().trim()) {
      case 'fertilizer':
      case 'সার':
        return ServiceProductCategory.fertilizer;
      case 'pesticide':
      case 'কীটনাশক':
        return ServiceProductCategory.pesticide;
      case 'tractor':
      case 'ট্র্যাক্টর':
        return ServiceProductCategory.tractor;
      case 'seed':
      case 'seeds':
      case 'বীজ':
        return ServiceProductCategory.seed;
      case 'equipment':
      case 'যন্ত্রপাতি':
        return ServiceProductCategory.equipment;
      case 'advisory':
      case 'পরামর্শ':
        return ServiceProductCategory.advisory;
      default:
        return ServiceProductCategory.fertilizer;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'shopOwnerId': shopOwnerId,
      'name': name,
      'nameEN': nameEN,
      'description': description,
      'descriptionEN': descriptionEN,
      'category': category.name,
      'price': price,
      'discountPrice': discountPrice,
      'stockQuantity': stockQuantity,
      'unit': unit,
      'unitEN': unitEN,
      'brand': brand,
      'images': images,
      'rating': rating,
      'totalSold': totalSold,
      'totalReviews': totalReviews,
      'isAvailable': isAvailable,
      'isForRent': isForRent,
      'rentPricePerDay': rentPricePerDay,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ServiceProduct.fromMap(Map<String, dynamic> map, [String? docId]) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return ServiceProduct(
      id: docId ?? map['id'] ?? '',
      shopOwnerId: map['shopOwnerId'] ?? '',
      name: map['name'] ?? '',
      nameEN: map['nameEN'],
      description: map['description'] ?? '',
      descriptionEN: map['descriptionEN'],
      category: categoryFromString(map['category']),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (map['discountPrice'] as num?)?.toDouble(),
      stockQuantity: (map['stockQuantity'] as num?)?.toInt() ?? 0,
      unit: map['unit'] ?? 'কেজি',
      unitEN: map['unitEN'] ?? 'kg',
      brand: map['brand'],
      images: (map['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      totalSold: (map['totalSold'] as num?)?.toInt() ?? 0,
      totalReviews: (map['totalReviews'] as num?)?.toInt() ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      isForRent: map['isForRent'] ?? false,
      rentPricePerDay: (map['rentPricePerDay'] as num?)?.toDouble(),
      createdAt: parseDate(map['createdAt']),
    );
  }
}

/// Order Item within a ServiceOrder
class ServiceOrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final String unit;

  ServiceOrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.unit,
  });

  double get totalPrice => quantity * unitPrice;
}

enum ServiceOrderStatus {
  pending,     // নতুন অর্ডার
  accepted,    // গৃহীত
  processing,  // প্রক্রিয়াধীন
  delivered,   // বিতরণ সম্পন্ন
  cancelled,   // বাতিল
}

extension ServiceOrderStatusExt on ServiceOrderStatus {
  String get bengaliName {
    switch (this) {
      case ServiceOrderStatus.pending: return 'অপেক্ষমাণ';
      case ServiceOrderStatus.accepted: return 'গৃহীত';
      case ServiceOrderStatus.processing: return 'প্রক্রিয়াধীন';
      case ServiceOrderStatus.delivered: return 'সম্পন্ন';
      case ServiceOrderStatus.cancelled: return 'বাতিল';
    }
  }
}

class ServiceOrder {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String shopOwnerId;
  final List<ServiceOrderItem> items;
  final double totalAmount;
  final ServiceOrderStatus status;
  final String? deliveryAddress;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ServiceOrder({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.shopOwnerId,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.deliveryAddress,
    this.note,
    required this.createdAt,
    this.updatedAt,
  });

  ServiceOrder copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    String? farmerPhone,
    String? shopOwnerId,
    List<ServiceOrderItem>? items,
    double? totalAmount,
    ServiceOrderStatus? status,
    String? deliveryAddress,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceOrder(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      shopOwnerId: shopOwnerId ?? this.shopOwnerId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);
}
