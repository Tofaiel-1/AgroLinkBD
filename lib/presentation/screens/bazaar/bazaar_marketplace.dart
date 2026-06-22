import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'product_detail.dart';

class BazaarMarketplace extends StatefulWidget {
  const BazaarMarketplace({super.key});

  @override
  State<BazaarMarketplace> createState() => _BazaarMarketplaceState();
}

class _BazaarMarketplaceState extends State<BazaarMarketplace> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _selectedCategory = 'all';
  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _allProducts = [];
  List<Map<String, dynamic>> _filteredProducts = [];

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'key': 'all', 'icon': Icons.apps},
    {'name': 'Vegetables', 'key': 'vegetables', 'icon': Icons.eco},
    {'name': 'Fruits', 'key': 'fruits', 'icon': Icons.apple},
    {'name': 'Spices', 'key': 'spices', 'icon': Icons.grain},
  ];

  @override
  void initState() {
    super.initState();
    _loadAllProducts();
    _searchController.addListener(_filterProducts);
  }

  Future<void> _loadAllProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('bazaar_products')
          .orderBy('createdAt', descending: true)
          .get();

      setState(() {
        _allProducts = querySnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        _isLoading = false;
      });

      _filterProducts();
    } catch (e) {
      debugPrint('Error loading products: $e');
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts() {
    List<Map<String, dynamic>> filtered = _allProducts;

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered =
          filtered.where((p) => p['category'] == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((p) =>
              p['name']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              p['category']
                  .toString()
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bazaar Marketplace'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Theme.of(context).colorScheme.surface,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        _searchQuery = value;
                        _filterProducts();
                      },
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  _searchQuery = '';
                                  _filterProducts();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),

                  // Category Filter
                  SizedBox(
                    height: 110,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(12),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category['key'];

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category['key'] as String;
                              });
                              _filterProducts();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).primaryColor
                                    : Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    category['icon'] as IconData,
                                    color: isSelected
                                        ? Colors.white
                                        : Theme.of(context).primaryColor,
                                    size: 28,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    category['name'] as String,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(context).primaryColor,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Product Grid
                  if (_filteredProducts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.shopping_basket_outlined,
                            size: 64,
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try searching or adjusting filters',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  else
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      padding: const EdgeInsets.all(12),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];
                        return _buildProductCard(product);
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final price = (product['price'] as num?)?.toStringAsFixed(0) ?? '0';
    String? imageUrl = product['imageUrl'];
    
    // Provide dynamic fallback images based on category if imageUrl is missing
    if (imageUrl == null || imageUrl.isEmpty) {
      final cat = product['category']?.toString().toLowerCase() ?? '';
      final name = product['name']?.toString().toLowerCase() ?? '';

      if (name.contains('chili') || name.contains('মরিচ')) {
        imageUrl = 'https://6a38c58967012f040a070b17.imgix.net/Screenshot%202026-06-22%20111227.png?auto=format&fit=fill&w=384';
      } else if (name.contains('mango') || name.contains('আম')) {
        imageUrl = 'https://images.unsplash.com/photo-1591073113125-e46713c829ed?w=400&q=80';
      } else if (name.contains('rice') || name.contains('ধান') || name.contains('চাল')) {
        imageUrl = 'https://images.unsplash.com/photo-1586201375761-83865001e8ac?w=400&q=80';
      } else if (name.contains('onion') || name.contains('পেঁয়াজ')) {
        imageUrl = 'https://images.unsplash.com/photo-1518977956812-cd3dbadaaf31?w=400&q=80';
      } else if (name.contains('potato') || name.contains('আলু')) {
        imageUrl = 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&q=80';
      } else if (name.contains('tomato') || name.contains('টমেটো')) {
        imageUrl = 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?w=400&q=80';
      } else if (cat == 'vegetables') {
        imageUrl = 'https://images.unsplash.com/photo-1566385101042-1a0aa0c1268c?w=400&q=80';
      } else if (cat == 'fruits') {
        imageUrl = 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&q=80';
      } else if (cat == 'spices') {
        imageUrl = 'https://images.unsplash.com/photo-1596040033229-a9821ebd058d?w=400&q=80';
      } else {
        imageUrl = 'https://images.unsplash.com/photo-1592982537447-7440770cbfc9?w=400&q=80';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetail(product: product),
          ),
        ).then((_) => _loadAllProducts());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            width: 1,
          ),
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
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
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
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(
                                  Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.image_not_supported,
                              color: Theme.of(context).primaryColor,
                              size: 32,
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.local_florist_outlined,
                          size: 48,
                          color: Theme.of(context).primaryColor,
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
                      product['name'] ?? 'Unknown',
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
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product['category'] ?? 'Unknown',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: 9,
                            ),
                      ),
                    ),
                    const Spacer(),

                    // Price and Quantity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '৳$price',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'per unit',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${product['quantity'] ?? 0}',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
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
