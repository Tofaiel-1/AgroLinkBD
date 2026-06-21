import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/core/models/service_provider_models.dart';

/// State notifier for Service Provider's product catalog
class ServiceProductNotifier extends StateNotifier<List<ServiceProduct>> {
  ServiceProductNotifier() : super([]) {
    _loadMockProducts();
  }

  void _loadMockProducts() {
    state = [
      // ===== সার (Fertilizers) =====
      ServiceProduct(
        id: 'sp_001',
        shopOwnerId: 'shop_001',
        name: 'ইউরিয়া সার (সাদা দানাদার)',
        description: 'উচ্চমানের ইউরিয়া সার। ফসলের বৃদ্ধি ও সবুজ রং বজায় রাখতে অত্যন্ত কার্যকর। নাইট্রোজেন সমৃদ্ধ।',
        category: ServiceProductCategory.fertilizer,
        price: 1800,
        discountPrice: 1650,
        stockQuantity: 250,
        unit: 'বস্তা (৫০ কেজি)',
        brand: 'যমুনা ফার্টিলাইজার',
        rating: 4.8,
        totalSold: 1250,
        totalReviews: 89,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
      ServiceProduct(
        id: 'sp_002',
        shopOwnerId: 'shop_001',
        name: 'TSP সার (ট্রিপল সুপার ফসফেট)',
        description: 'ফসফরাস সমৃদ্ধ সার। শিকড় বৃদ্ধি ও ফুল-ফল ধরতে সহায়ক। ধান, গম ও সবজির জন্য উপযুক্ত।',
        category: ServiceProductCategory.fertilizer,
        price: 2200,
        stockQuantity: 120,
        unit: 'বস্তা (৫০ কেজি)',
        brand: 'চিটাগং কেমিক্যাল',
        rating: 4.6,
        totalSold: 780,
        totalReviews: 56,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      ServiceProduct(
        id: 'sp_003',
        shopOwnerId: 'shop_001',
        name: 'ভার্মি কম্পোস্ট (জৈব সার)',
        description: 'কেঁচো সার। মাটির উর্বরতা বৃদ্ধি করে, পানি ধারণ ক্ষমতা বাড়ায়। জৈব চাষের জন্য আদর্শ।',
        category: ServiceProductCategory.fertilizer,
        price: 600,
        discountPrice: 500,
        stockQuantity: 8,
        unit: 'বস্তা (২৫ কেজি)',
        brand: 'গ্রিন আর্থ',
        rating: 4.9,
        totalSold: 2100,
        totalReviews: 145,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
      ),

      // ===== কীটনাশক (Pesticides) =====
      ServiceProduct(
        id: 'sp_004',
        shopOwnerId: 'shop_001',
        name: 'ফাইটার ২.৫ EC (কীটনাশক)',
        description: 'ধানের মাজরা পোকা, বাদামী গাছফড়িং দমনে কার্যকর। ব্যবহারবিধি অনুসরণ করুন।',
        category: ServiceProductCategory.pesticide,
        price: 350,
        stockQuantity: 180,
        unit: 'বোতল (১ লি.)',
        brand: 'সিনজেন্টা',
        rating: 4.5,
        totalSold: 920,
        totalReviews: 67,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      ServiceProduct(
        id: 'sp_005',
        shopOwnerId: 'shop_001',
        name: 'রিপকর্ড ১০ EC',
        description: 'সবজি ও ফলের জাবপোকা, থ্রিপস ও সাদামাছি দমনে অত্যন্ত কার্যকর কীটনাশক।',
        category: ServiceProductCategory.pesticide,
        price: 280,
        stockQuantity: 95,
        unit: 'বোতল (৫০০ মিলি)',
        brand: 'বায়ার',
        rating: 4.7,
        totalSold: 650,
        totalReviews: 42,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),

      // ===== বীজ (Seeds) =====
      ServiceProduct(
        id: 'sp_006',
        shopOwnerId: 'shop_001',
        name: 'BRRI ধান-২৯ (বোরো ধান)',
        description: 'উচ্চ ফলনশীল বোরো ধানের বীজ। প্রতি বিঘায় ২০-২২ মণ ফলন। রোগ প্রতিরোধী।',
        category: ServiceProductCategory.seed,
        price: 120,
        stockQuantity: 500,
        unit: 'কেজি',
        brand: 'BRRI',
        rating: 4.9,
        totalSold: 3200,
        totalReviews: 210,
        createdAt: DateTime.now().subtract(const Duration(days: 120)),
      ),
      ServiceProduct(
        id: 'sp_007',
        shopOwnerId: 'shop_001',
        name: 'হাইব্রিড টমেটো বীজ',
        description: 'সারা বছর চাষযোগ্য হাইব্রিড টমেটো। প্রতি গাছে ৫-৮ কেজি ফলন।',
        category: ServiceProductCategory.seed,
        price: 450,
        discountPrice: 380,
        stockQuantity: 3,
        unit: 'প্যাকেট (১০ গ্রাম)',
        brand: 'ইস্ট ওয়েস্ট সিড',
        rating: 4.6,
        totalSold: 890,
        totalReviews: 73,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),

      // ===== ট্র্যাক্টর (Tractors) =====
      ServiceProduct(
        id: 'sp_008',
        shopOwnerId: 'shop_001',
        name: 'সোনালিকা DI-60 ট্র্যাক্টর',
        description: '৬০ HP ডিজেল ট্র্যাক্টর। জমি চাষ, মাড়াই ও পরিবহনের জন্য উপযুক্ত। ভাড়ায় পাওয়া যায়।',
        category: ServiceProductCategory.tractor,
        price: 850000,
        stockQuantity: 2,
        unit: 'পিস',
        brand: 'সোনালিকা',
        rating: 4.7,
        totalSold: 5,
        totalReviews: 3,
        isForRent: true,
        rentPricePerDay: 3500,
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
      ),

      // ===== কৃষি যন্ত্রপাতি (Equipment) =====
      ServiceProduct(
        id: 'sp_009',
        shopOwnerId: 'shop_001',
        name: 'পাওয়ার স্প্রেয়ার (ব্যাটারি)',
        description: '১৬ লিটার ক্যাপাসিটি রিচার্জেবল ব্যাটারি স্প্রেয়ার। কীটনাশক ছিটানোর জন্য।',
        category: ServiceProductCategory.equipment,
        price: 4500,
        discountPrice: 3800,
        stockQuantity: 35,
        unit: 'পিস',
        brand: 'পাদ্মা ইঞ্জিনিয়ারিং',
        rating: 4.4,
        totalSold: 320,
        totalReviews: 28,
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
      ServiceProduct(
        id: 'sp_010',
        shopOwnerId: 'shop_001',
        name: 'সেচ পাম্প (১.৫ HP)',
        description: 'ডিজেল চালিত সেচ পাম্প। ছোট ও মাঝারি জমিতে সেচ দেওয়ার জন্য আদর্শ।',
        category: ServiceProductCategory.equipment,
        price: 12000,
        stockQuantity: 15,
        unit: 'পিস',
        brand: 'রবিন',
        rating: 4.3,
        totalSold: 180,
        totalReviews: 15,
        isForRent: true,
        rentPricePerDay: 800,
        createdAt: DateTime.now().subtract(const Duration(days: 75)),
      ),
    ];
  }

  void addProduct(ServiceProduct product) {
    state = [product, ...state];
  }

  void updateProduct(ServiceProduct updated) {
    state = [
      for (final p in state)
        if (p.id == updated.id) updated else p
    ];
  }

  void deleteProduct(String id) {
    state = state.where((p) => p.id != id).toList();
  }

  void toggleAvailability(String id) {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(isAvailable: !p.isAvailable) else p
    ];
  }

  void updateStock(String id, int newStock) {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(stockQuantity: newStock) else p
    ];
  }
}

/// State notifier for Service Provider's orders
class ServiceOrderNotifier extends StateNotifier<List<ServiceOrder>> {
  ServiceOrderNotifier() : super([]) {
    _loadMockOrders();
  }

  void _loadMockOrders() {
    state = [
      ServiceOrder(
        id: 'ORD-1001',
        farmerId: 'f_001',
        farmerName: 'মোঃ রহিম উদ্দিন',
        farmerPhone: '01712345678',
        shopOwnerId: 'shop_001',
        items: [
          ServiceOrderItem(productId: 'sp_001', productName: 'ইউরিয়া সার', quantity: 5, unitPrice: 1650, unit: 'বস্তা'),
          ServiceOrderItem(productId: 'sp_004', productName: 'ফাইটার ২.৫ EC', quantity: 2, unitPrice: 350, unit: 'বোতল'),
        ],
        totalAmount: 8950,
        status: ServiceOrderStatus.pending,
        deliveryAddress: 'গ্রাম: কাশিনাথপুর, বগুড়া সদর',
        createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      ServiceOrder(
        id: 'ORD-1002',
        farmerId: 'f_002',
        farmerName: 'আবুল হোসেন',
        farmerPhone: '01898765432',
        shopOwnerId: 'shop_001',
        items: [
          ServiceOrderItem(productId: 'sp_006', productName: 'BRRI ধান-২৯', quantity: 20, unitPrice: 120, unit: 'কেজি'),
        ],
        totalAmount: 2400,
        status: ServiceOrderStatus.pending,
        deliveryAddress: 'গ্রাম: চরবাড়ীপাড়া, শেরপুর',
        note: 'দ্রুত পাঠান, বোরো মৌসুম শুরু হয়ে গেছে।',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      ServiceOrder(
        id: 'ORD-0998',
        farmerId: 'f_003',
        farmerName: 'ফাতেমা বেগম',
        farmerPhone: '01611223344',
        shopOwnerId: 'shop_001',
        items: [
          ServiceOrderItem(productId: 'sp_009', productName: 'পাওয়ার স্প্রেয়ার', quantity: 1, unitPrice: 3800, unit: 'পিস'),
          ServiceOrderItem(productId: 'sp_005', productName: 'রিপকর্ড ১০ EC', quantity: 3, unitPrice: 280, unit: 'বোতল'),
        ],
        totalAmount: 4640,
        status: ServiceOrderStatus.processing,
        deliveryAddress: 'ঠাকুরগাঁও সদর',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      ServiceOrder(
        id: 'ORD-0995',
        farmerId: 'f_004',
        farmerName: 'জামাল মিয়া',
        farmerPhone: '01555667788',
        shopOwnerId: 'shop_001',
        items: [
          ServiceOrderItem(productId: 'sp_003', productName: 'ভার্মি কম্পোস্ট', quantity: 10, unitPrice: 500, unit: 'বস্তা'),
        ],
        totalAmount: 5000,
        status: ServiceOrderStatus.delivered,
        deliveryAddress: 'নাটোর সদর',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  void updateOrderStatus(String orderId, ServiceOrderStatus newStatus) {
    state = [
      for (final o in state)
        if (o.id == orderId) o.copyWith(status: newStatus, updatedAt: DateTime.now()) else o
    ];
  }

  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, ServiceOrderStatus.cancelled);
  }
}

// ===== Riverpod Providers =====

final serviceProductProvider =
    StateNotifierProvider<ServiceProductNotifier, List<ServiceProduct>>((ref) {
  return ServiceProductNotifier();
});

final serviceOrderProvider =
    StateNotifierProvider<ServiceOrderNotifier, List<ServiceOrder>>((ref) {
  return ServiceOrderNotifier();
});

// Filter providers
final serviceProductCategoryFilterProvider =
    StateProvider<ServiceProductCategory?>((ref) => null);

final serviceOrderStatusFilterProvider =
    StateProvider<ServiceOrderStatus?>((ref) => null);

// Derived providers
final filteredServiceProductsProvider = Provider<List<ServiceProduct>>((ref) {
  final products = ref.watch(serviceProductProvider);
  final categoryFilter = ref.watch(serviceProductCategoryFilterProvider);
  if (categoryFilter == null) return products;
  return products.where((p) => p.category == categoryFilter).toList();
});

final filteredServiceOrdersProvider = Provider<List<ServiceOrder>>((ref) {
  final orders = ref.watch(serviceOrderProvider);
  final statusFilter = ref.watch(serviceOrderStatusFilterProvider);
  if (statusFilter == null) return orders;
  return orders.where((o) => o.status == statusFilter).toList();
});

final pendingOrderCountProvider = Provider<int>((ref) {
  final orders = ref.watch(serviceOrderProvider);
  return orders.where((o) => o.status == ServiceOrderStatus.pending).length;
});

final lowStockProductsProvider = Provider<List<ServiceProduct>>((ref) {
  final products = ref.watch(serviceProductProvider);
  return products.where((p) => p.isLowStock || p.isOutOfStock).toList();
});

final totalRevenueProvider = Provider<double>((ref) {
  final orders = ref.watch(serviceOrderProvider);
  return orders
      .where((o) => o.status == ServiceOrderStatus.delivered)
      .fold(0.0, (sum, o) => sum + o.totalAmount);
});
