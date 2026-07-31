import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';
import 'package:agrolinkbd/presentation/screens/cart/cart_screen.dart';

class EnhancedMarketplace extends StatefulWidget {
  const EnhancedMarketplace({super.key});

  @override
  State<EnhancedMarketplace> createState() => _EnhancedMarketplaceState();
}

class _EnhancedMarketplaceState extends State<EnhancedMarketplace> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'vegetables';
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  final List<String> _categories = [
    'সকল',
    'vegetables',
    'fruits',
    'spices',
    'grains',
    'seeds',
    'tools',
  ];

  final Map<String, String> _categoryLabels = {
    'সকল': 'All',
    'vegetables': 'সবজি',
    'fruits': 'ফল',
    'spices': 'মসলা',
    'grains': 'শস্য',
    'seeds': 'বীজ',
    'tools': 'যন্ত্র',
  };

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    try {
      // Simplified query to avoid composite index requirement
      // Does filtering in code instead of Firestore
      final querySnapshot = await _firestore
          .collection('bazaar_products')
          .orderBy('createdAt', descending: true)
          .limit(500) // Limit to prevent huge dataset
          .get();

      if (!mounted) return; // Check again after async operation

      setState(() {
        _products = querySnapshot.docs
            .where((doc) => doc['status'] == 'available') // Filter in app
            .map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        _isLoading = false;
      });

      _filterProducts();
    } catch (e) {
      debugPrint('Error loading products: $e');
      if (mounted) {
        // Check mounted before setState
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterProducts() {
    if (!mounted) return;

    List<Map<String, dynamic>> filtered = _products;

    // Filter by category
    if (_selectedCategory != 'সকল' && _selectedCategory.isNotEmpty) {
      filtered =
          filtered.where((p) => p['category'] == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((p) {
        final title = (p['title'] ?? '').toString().toLowerCase();
        final description = (p['description'] ?? '').toString().toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    if (mounted) {
      // Check mounted before setState
      setState(() {
        _filteredProducts = filtered;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            backgroundColor: const Color(0xFF2E7D32),
            icon: Stack(
              children: [
                const Icon(Icons.shopping_bag, color: Colors.white),
                if (cartProvider.itemCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cartProvider.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: Text(
              '৳${cartProvider.totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
      ),
      body: CustomScrollView(
        slivers: [
          // App Bar with Search
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            expandedHeight: 130,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2E7D32),
                      Colors.green.shade600,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Search Bar
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'পণ্য খুঁজুন...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Category Chips
          SliverToBoxAdapter(
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_categoryLabels[category] ?? category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                        _filterProducts();
                      },
                      backgroundColor: Colors.white,
                      selectedColor: Colors.green.shade100,
                      checkmarkColor: Colors.green.shade700,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.green.shade700
                            : Colors.grey.shade700,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Products Grid
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                    ),
                    SizedBox(height: 16),
                    Text('Loading products...'),
                  ],
                ),
              ),
            )
          else if (_filteredProducts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_basket_outlined,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'কোন পণ্য পাওয়া যায়নি',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ফিল্টার পরিবর্তন করুন বা পুনরায় চেষ্টা করুন',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.72,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = _filteredProducts[index];
                    return _buildProductCard(product);
                  },
                  childCount: _filteredProducts.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final price = (product['price'] as num?)?.toStringAsFixed(0) ?? '0';
    final imageUrl = product['imageUrl'];
    final title = product['title'] ?? 'Unknown Product';
    final category = product['category'] ?? 'Other';
    final unit = product['unit'] ?? 'kg';

    return GestureDetector(
      onTap: () {
        // Show product details dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        height: 150,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text('Price: ৳$price'),
                const SizedBox(height: 8),
                Text('Category: $category'),
                const SizedBox(height: 8),
                Text(product['description'] ?? 'No description'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.grey.shade100,
                ),
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 32,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.local_florist_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),

            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),

                    // Category Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _categoryLabels[category] ?? category,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: const Color(0xFF2E7D32),
                              fontSize: 9,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),

                    // Price Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '৳$price',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: const Color(0xFF2E7D32),
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'per $unit',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      fontSize: 8,
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        // Add to Cart Button
                        Consumer<CartProvider>(
                          builder: (context, cartProvider, _) {
                            final inCart =
                                cartProvider.isInCart(product['id'] ?? '');
                            return GestureDetector(
                              onTap: () {
                                if (!inCart) {
                                  cartProvider.addToCart(
                                    CartItem(
                                      productId: product['id'] ?? '',
                                      title: title,
                                      price: (product['price'] as num?)
                                              ?.toDouble() ??
                                          0.0,
                                      unit: unit,
                                      quantity: 1,
                                      imageUrl: imageUrl ?? '',
                                      sellerId: product['sellerId'] ?? '',
                                      sellerName:
                                          product['sellerName'] ?? 'Unknown',
                                    ),
                                  );

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('$title added to cart'),
                                      duration:
                                          const Duration(milliseconds: 800),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: inCart
                                      ? Colors.red.shade400
                                      : const Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  inCart
                                      ? Icons.check
                                      : Icons.add_shopping_cart,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
