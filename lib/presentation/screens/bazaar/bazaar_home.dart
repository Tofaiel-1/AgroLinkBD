import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'bazaar_products.dart';
import 'bazaar_marketplace.dart';
import 'add_product_screen.dart';

class BazaarHome extends StatefulWidget {
  const BazaarHome({super.key});

  @override
  State<BazaarHome> createState() => _BazaarHomeState();
}

class _BazaarHomeState extends State<BazaarHome> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String _userId;
  bool _isLoading = true;

  Map<String, int> _categoryProductCounts = {
    'vegetables': 0,
    'fruits': 0,
    'spices': 0,
  };

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _userId = userProvider.currentUser?.id ??
        FirebaseAuth.instance.currentUser?.uid ??
        '';
    _loadProductCounts();
  }

  Future<void> _loadProductCounts() async {
    if (_userId.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final Map<String, int> tempCounts = {};

      for (var category in _categoryProductCounts.keys) {
        final query = _firestore
            .collection('bazaar_products')
            .where('userId', isEqualTo: _userId)
            .where('category', isEqualTo: category);

        final countResult = await query.count().get();
        tempCounts[category] = countResult.count ?? 0;
      }

      if (mounted) {
        setState(() {
          _categoryProductCounts = tempCounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading product counts: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light theme background
      appBar: AppBar(
        title: const Text('Bazaar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
        elevation: 0,
        backgroundColor: Colors.green.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Search Bar (Premium Light Mode Style)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: 'Search crops, spices, and more...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        icon: const Icon(Icons.search, color: Colors.amber),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Add Product Quick Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade600,
                          Colors.amber.shade400,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddProductScreen(),
                          ),
                        ).then((result) {
                          if (result == true) {
                            _loadProductCounts();
                          }
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_circle_outline,
                            color: Colors.black87,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add New Product',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Explore Marketplace Section
                  Text(
                    'Explore Marketplace',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BazaarMarketplace(),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.1),
                                    blurRadius: 5,
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.storefront,
                                color: Colors.green,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Browse Bazaar',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.green.shade800,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'See products from all farmers',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Colors.green.shade700,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.green.shade400,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Trending Crops Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trending Crops',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade400),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTrendingCrops(),
                  const SizedBox(height: 32),

                  // My Shop Section
                  Text(
                    'My Shop',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryGrid(),
                  const SizedBox(height: 32),

                  // Quick Stats
                  Text(
                    'Shop Statistics',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsRow(),
                ],
              ),
            ),
    );
  }

  Widget _buildTrendingCrops() {
    final trending = [
      {
        'name': 'Fresh Chili', 
        'price': '৳120/kg', 
        'rating': '4.8★', 
        'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584281/Screenshot_2026-06-28_001608_krqrup.png',
        'color': Colors.redAccent
      },
      {
        'name': 'Deshi Mango', 
        'price': '৳80/kg', 
        'rating': '4.9★', 
        'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782583216/image_sxwwpa.png',
        'color': Colors.orangeAccent
      },
      {
        'name': 'Premium Rice', 
        'price': '৳75/kg', 
        'rating': '4.7★', 
        'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584453/Screenshot_2026-06-28_002037_e5q6ll.png',
        'color': Colors.amber
      },
      {
        'name': 'Organic Onion', 
        'price': '৳90/kg', 
        'rating': '4.5★', 
        'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584281/Screenshot_2026-06-28_001608_krqrup.png',
        'color': Colors.purpleAccent
      },
      {
        'name': 'Fresh Tomato', 
        'price': '৳60/kg', 
        'rating': '4.6★', 
        'image': 'https://images.unsplash.com/photo-1561136594-7f68413baa99?q=80&w=400&auto=format&fit=crop',
        'color': Colors.red
      },
      {
        'name': 'Bogura Potato', 
        'price': '৳45/kg', 
        'rating': '4.8★', 
        'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584736/Screenshot_2026-06-28_002524_ziwqmo.png',
        'color': Colors.brown
      },
    ];

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: trending.length,
        itemBuilder: (context, index) {
          final item = trending[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 5,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(
                        item['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: (item['color'] as Color).withOpacity(0.2),
                          child: Icon(Icons.image_not_supported, color: item['color'] as Color),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['name'] as String,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['price'] as String,
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item['rating'] as String,
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
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
        },
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Vegetables', 'icon': Icons.eco, 'key': 'vegetables', 'color': Colors.lightGreen},
      {'name': 'Fruits', 'icon': Icons.apple, 'key': 'fruits', 'color': Colors.orange},
      {'name': 'Spices', 'icon': Icons.grain, 'key': 'spices', 'color': Colors.red},
    ];

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: categories.map((category) {
        final count = _categoryProductCounts[category['key']] ?? 0;
        return _buildCategoryCard(
          name: category['name'] as String,
          icon: category['icon'] as IconData,
          categoryKey: category['key'] as String,
          productCount: count,
          color: category['color'] as Color,
        );
      }).toList(),
    );
  }

  Widget _buildCategoryCard({
    required String name,
    required IconData icon,
    required String categoryKey,
    required int productCount,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BazaarProducts(category: categoryKey),
          ),
        ).then((_) {
          _loadProductCounts();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$productCount Items',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final total = _categoryProductCounts.values.fold<int>(0, (a, b) => a + b);

    return Row(
      children: [
        _buildStatCard('Total Products', '$total', Icons.inventory_2, Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard('Categories', '3', Icons.category, Colors.purple),
        const SizedBox(width: 12),
        _buildStatCard('Active', 'Yes', Icons.check_circle, Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
