import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/presentation/buyer/providers/product_provider.dart';
import 'package:agrolinkbd/presentation/buyer/widgets/product_card.dart';
import 'package:agrolinkbd/presentation/buyer/screens/product_detail_screen.dart';

class BrowseProductsScreen extends ConsumerStatefulWidget {
  final String? initialCategory;

  const BrowseProductsScreen({Key? key, this.initialCategory})
      : super(key: key);

  @override
  ConsumerState<BrowseProductsScreen> createState() =>
      _BrowseProductsScreenState();
}

class _BrowseProductsScreenState extends ConsumerState<BrowseProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = ref.watch(filteredProductsProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('পণ্য ব্রাউজ করুন'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'পণ্য খুঁজুন...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => setState(() => _showFilters = !_showFilters),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.filter_list, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // Filters
          if (_showFilters)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('মূল্য পরিসর',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'ন্যূনতম',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'সর্বোচ্চ',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('রেটিং',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ...List.generate(5, (index) {
                        final rating = 5 - index;
                        return FilterChip(
                          label: Text('$rating+ তারকা'),
                          onSelected: (bool value) {},
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          // Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: categories.when(
              data: (categoryList) => Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('সব'),
                    selected: selectedCategory == null,
                    onSelected: (bool value) {
                      ref.read(selectedCategoryProvider.notifier).state = null;
                    },
                  ),
                  ...categoryList.map(
                    (category) => FilterChip(
                      label: Text(category),
                      selected: selectedCategory == category,
                      onSelected: (bool value) {
                        ref.read(selectedCategoryProvider.notifier).state =
                            category;
                      },
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox(
                  height: 40, child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 8),
          // Products grid
          Expanded(
            child: filteredProducts.when(
              data: (products) => products.isEmpty
                  ? const Center(
                      child: Text('কোন পণ্য পাওয়া যায়নি'),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: products.length,
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
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailScreen(product: product),
                              ),
                            );
                          },
                          onAddToCart: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('পণ্য কার্টে যোগ করা হয়েছে')),
                            );
                          },
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
