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
  final String description;
  final ServiceProductCategory category;
  final double price;
  final double? discountPrice;
  final int stockQuantity;
  final String unit; // কেজি, লিটার, প্যাকেট, পিস
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
    required this.description,
    required this.category,
    required this.price,
    this.discountPrice,
    required this.stockQuantity,
    required this.unit,
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
    String? description,
    ServiceProductCategory? category,
    double? price,
    double? discountPrice,
    int? stockQuantity,
    String? unit,
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
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
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

  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  double get effectivePrice => discountPrice ?? price;
  double get discountPercentage => hasDiscount ? ((price - discountPrice!) / price * 100) : 0;
  bool get isLowStock => stockQuantity > 0 && stockQuantity <= 10;
  bool get isOutOfStock => stockQuantity <= 0;
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
