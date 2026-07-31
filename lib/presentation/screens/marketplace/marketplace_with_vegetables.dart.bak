import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';
import 'package:agrolinkbd/core/models/agriculture_products.dart';
import 'package:agrolinkbd/presentation/screens/cart/cart_screen.dart';

class EnhancedMarketplaceWithVegetables extends StatefulWidget {
  const EnhancedMarketplaceWithVegetables({super.key});

  @override
  State<EnhancedMarketplaceWithVegetables> createState() =>
      _EnhancedMarketplaceWithVegetablesState();
}

class _EnhancedMarketplaceWithVegetablesState
    extends State<EnhancedMarketplaceWithVegetables>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  bool _isLoading = true;

  final List<String> _tabs = [
    'সবজি',
    'দুধ ও ঘি',
    'ডিম ও মাংস',
    'মধু ও শস্য',
    'সব',
  ];

  final List<String> _tabTypes = [
    'vegetable',
    'dairy',
    'animal_products',
    'honey',
    'all',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_filterByTab);
    _loadProducts();
    _searchController.addListener(_searchProducts);
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;

    try {
      // সরাসরি শুধুমাত্র ডিফাইন করা পণ্য লোড করুন
      final products = AgricultureProducts.getAllProducts();

      setState(() {
        _allProducts = products;
        _isLoading = false;
      });

      _filterByTab();
    } catch (e) {
      debugPrint('Error loading products: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterByTab() {
    if (!mounted) return;

    String selectedType = _tabTypes[_tabController.index];
    List<Map<String, dynamic>> filtered;

    if (selectedType == 'all') {
      filtered = _allProducts;
    } else {
      filtered = _allProducts
          .where((product) => product['type'] == selectedType)
          .toList();
    }

    // সার্চ ফিল্টার প্রয়োগ করুন
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered.where((product) {
        final title = (product['title'] ?? '').toString().toLowerCase();
        final description =
            (product['description'] ?? '').toString().toLowerCase();
        return title.contains(query) || description.contains(query);
      }).toList();
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _searchProducts() {
    _filterByTab();
  }

  void _addToCart(Map<String, dynamic> product) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final cartItem = CartItem(
      productId: product['id'] ?? '',
      title: product['title'] ?? 'Unknown',
      price: (product['price'] as num?)?.toDouble() ?? 0.0,
      quantity: 1,
      imageUrl: product['image'] ?? '',
      sellerId: product['seller'] ?? 'Unknown',
      sellerName: product['seller'] ?? 'Unknown',
      unit: product['unit'] ?? 'kg',
    );
    cartProvider.addToCart(cartItem);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product['title']} কার্টে যোগ করা হয়েছে'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          // অ্যাপ বার এবং সার্চ
          SliverAppBar(
            floating: true,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            expandedHeight: 160,
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
                    // সার্চ বার
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'পণ্য খুঁজুন...',
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // ট্যাব
                    TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // কন্টেন্ট
          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _filteredProducts.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'কোন পণ্য পাওয়া যায়নি',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                            return Stack(
                              children: [
                                ProductCard(
                                  product: product,
                                  onTap: () {
                                    _showProductDetails(product);
                                  },
                                ),
                                // দ্রুত কার্টে যোগ করুন বাটন
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2E7D32),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.add,
                                          color: Colors.white, size: 20),
                                      onPressed: () {
                                        _addToCart(product);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  void _showProductDetails(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          children: [
            // পণ্যের ছবি
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Image.asset(
                product['image'],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[600],
                      size: 64,
                    ),
                  );
                },
              ),
            ),
            // বিস্তারিত
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // শিরোনাম এবং দাম
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['title'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product['bengaliName'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          Text(
                            '${product['rating']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '(${product['reviews']} পর্যালোচনা)',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // দাম এবং স্টক
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'দাম:',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '৳${product['price']}/${product['unit']}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text('স্টক:'),
                            Text(
                              '${product['stock']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // বিক্রেতা তথ্য
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'বিক্রেতা:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(product['seller']),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 6),
                            Expanded(child: Text(product['location'])),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // বর্ণনা
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'বিবরণ:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product['description'],
                        style: const TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // কার্টে যোগ করুন বাটন
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        _addToCart(product);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                      ),
                      child: const Text(
                        'কার্টে যোগ করুন',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
