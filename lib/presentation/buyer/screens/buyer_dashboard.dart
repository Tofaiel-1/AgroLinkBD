import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/buyer/providers/product_provider.dart';
import 'package:agrolinkbd/presentation/buyer/providers/buyer_profile_provider.dart';
import 'package:agrolinkbd/presentation/buyer/widgets/product_card.dart';
import 'package:agrolinkbd/presentation/buyer/widgets/category_chip.dart';
import 'package:agrolinkbd/presentation/buyer/screens/browse_products_screen.dart';
import 'package:agrolinkbd/presentation/buyer/screens/product_detail_screen.dart';

class BuyerDashboardScreen extends ConsumerStatefulWidget {
  const BuyerDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<BuyerDashboardScreen> createState() =>
      _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends ConsumerState<BuyerDashboardScreen> {
  int _selectedCategoryIndex = -1;
  final List<Map<String, dynamic>> categories = [
    {'label': 'ধান', 'icon': Icons.grain, 'value': 'rice'},
    {'label': 'সবজি', 'icon': Icons.agriculture, 'value': 'vegetables'},
    {'label': 'ফল', 'icon': Icons.emoji_nature, 'value': 'fruits'},
    {'label': 'মসলা', 'icon': Icons.restaurant, 'value': 'spices'},
    {'label': 'ডাল', 'icon': Icons.grain, 'value': 'pulses'},
    {'label': 'তেলবীজ', 'icon': Icons.opacity, 'value': 'oilseeds'},
    {'label': 'জৈব', 'icon': Icons.eco, 'value': 'organic'},
  ];

  @override
  Widget build(BuildContext context) {
    final buyerProfile = ref.watch(buyerProfileProvider);
    final trendingProducts = ref.watch(trendingProductsProvider);
    final discountedProducts = ref.watch(discountedProductsProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(allProductsProvider);
          ref.invalidate(trendingProductsProvider);
          ref.invalidate(discountedProductsProvider);
          return Future.value();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // AppBar
              Container(
                color: const Color(0xFF1976D2),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'স্বাগতম',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                            buyerProfile.when(
                              data: (profile) => Text(
                                profile?.name ?? 'ক্রেতা',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              loading: () => const Text(
                                'লোড হচ্ছে...',
                                style: TextStyle(color: Colors.white),
                              ),
                              error: (_, __) => const Text(
                                'ত্রুটি',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications,
                                  color: Colors.white),
                              onPressed: () {
                                Get.toNamed('/buyer/notifications');
                              },
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.shopping_cart,
                                      color: Colors.white),
                                  onPressed: () {
                                    Get.toNamed('/buyer/cart');
                                  },
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: const Text(
                                      '0',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search bar
                    GestureDetector(
                      onTap: () => Get.to(() => const BrowseProductsScreen()),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'পণ্য খুঁজুন...',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            Icon(Icons.mic, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Wallet balance
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: buyerProfile.when(
                  data: (profile) => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'ওয়ালেট ব্যালেন্স',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '৳${(profile?.walletBalance ?? 0).toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Get.toNamed('/buyer/wallet');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                          ),
                          child: const Text(
                            'টাকা যোগ করুন',
                            style: TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  loading: () => Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 16),
              // Categories
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ক্যাটাগরি',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 70,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: CategoryChip(
                              label: category['label'],
                              icon: category['icon'],
                              isSelected: _selectedCategoryIndex == index,
                              onTap: () {
                                setState(() => _selectedCategoryIndex = index);
                                ref
                                    .read(selectedCategoryProvider.notifier)
                                    .state = category['value'];
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Banner carousel (placeholder)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('বিজ্ঞাপন ব্যানার'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Trending products
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ট্রেন্ডিং পণ্য',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Get.to(() => const BrowseProductsScreen()),
                          child: const Text(
                            'সবাই দেখুন',
                            style: TextStyle(
                              color: Color(0xFF1976D2),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    trendingProducts.when(
                      data: (products) => SizedBox(
                        height: 280,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: SizedBox(
                                width: 180,
                                child: ProductCard(
                                  productId: product.id,
                                  productName: product.name,
                                  productNamebn: product.namebn,
                                  price: product.price,
                                  originalPrice: product.originalPrice,
                                  imageUrl: product.images.isNotEmpty
                                      ? product.images[0]
                                      : null,
                                  farmerName: product.farmerName,
                                  farmerRating: product.farmerRating,
                                  stock: product.availableStock,
                                  onTap: () {
                                    Get.to(() =>
                                        ProductDetailScreen(product: product));
                                  },
                                  onAddToCart: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'পণ্য কার্টে যোগ করা হয়েছে')),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('Error: $error')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Discounted products
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'বিশেষ অফার',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    discountedProducts.when(
                      data: (products) => GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: products.length.clamp(0, 4),
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            productId: product.id,
                            productName: product.name,
                            productNamebn: product.namebn,
                            price: product.price,
                            originalPrice: product.originalPrice,
                            imageUrl: product.images.isNotEmpty
                                ? product.images[0]
                                : null,
                            farmerName: product.farmerName,
                            farmerRating: product.farmerRating,
                            stock: product.availableStock,
                            onTap: () {
                              Get.to(
                                  () => ProductDetailScreen(product: product));
                            },
                            onAddToCart: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('পণ্য কার্টে যোগ করা হয়েছে')),
                              );
                            },
                          );
                        },
                      ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, _) => Center(child: Text('Error: $error')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
