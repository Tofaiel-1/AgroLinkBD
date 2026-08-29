import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'bazaar_products.dart';
import 'bazaar_marketplace.dart';
import 'add_product_screen.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/presentation/screens/analytics/market_price_analysis_screen.dart';
import 'package:agrolinkbd/presentation/screens/telemedicine/agri_telemedicine_screen.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/buyer_rfq_board_screen.dart';
import 'package:agrolinkbd/presentation/screens/machinery/machinery_rental_screen.dart';
import 'package:agrolinkbd/presentation/screens/transport/upazila_transport_screen.dart';

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
    final userProvider = Provider.of<UserProvider>(context);
    final isBuyer = userProvider.currentUser?.userType == UserType.buyer;
    final isBn = LanguageProvider.isBn(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Light theme background
      appBar: AppBar(
        title: Text(isBn ? 'বাজার' : 'Bazaar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), 
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
                        hintText: isBn ? 'ফসল, মসলা এবং অন্যান্য অনুসন্ধান করুন...' : 'Search crops, spices, and more...',
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                        icon: const Icon(Icons.search, color: Colors.amber),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Add Product Quick Button
                  if (!isBuyer)
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
                            const Icon(Icons.add_circle, color: Colors.white, size: 28),
                            const SizedBox(width: 12),
                            Text(
                              isBn ? 'নতুন পণ্য যোগ করুন' : 'Add New Product',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!isBuyer)
                    const SizedBox(height: 28),

                  // Explore Marketplace Section
                  Text(
                    isBn ? 'মার্কেটপ্লেস অন্বেষণ করুন' : 'Explore Marketplace',
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
                                    isBn ? 'বাজার ব্রাউজ করুন' : 'Browse Bazaar',
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
                                    isBn ? 'সকল কৃষকের পণ্য দেখুন' : 'See products from all farmers',
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
                  const SizedBox(height: 24),

                  // ==========================================
                  // ULTRA PRO MONETIZATION & VALUE SERVICES
                  // ==========================================
                  Text(
                    isBn ? 'প্রিমিয়াম কৃষি ও মৎস্য সেবা 💎' : 'Premium Agro Services 💎',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.25,
                    children: [
                      _buildServiceTile(
                        title: isBn ? 'কৃষি ও মৎস্য ডাক্তার 🩺' : 'Agri & Fish Doctor',
                        subtitle: isBn ? 'লাইভ ভিডিও কল পরামর্শ' : 'Live Specialist Consult',
                        badge: '৳৩০ টোকেন',
                        badgeColor: Colors.purple,
                        icon: Icons.video_camera_front_outlined,
                        color: const Color(0xFF6A1B9A),
                        onTap: () => Get.to(() => const AgriTelemedicineScreen()),
                      ),
                      _buildServiceTile(
                        title: isBn ? 'পাইকারি চাহিদা বোর্ড 📋' : 'Bulk RFQ Board',
                        subtitle: isBn ? 'পাইকারদের বড় টেন্ডার' : 'Wholesale Tenders',
                        badge: 'বড় ডিল ⚡',
                        badgeColor: Colors.red,
                        icon: Icons.assignment_outlined,
                        color: const Color(0xFFC62828),
                        onTap: () => Get.to(() => const BuyerRfqBoardScreen()),
                      ),
                      _buildServiceTile(
                        title: isBn ? 'মেশিনারি ও হার্ভেস্টার 🚜' : 'Machinery Rental',
                        subtitle: isBn ? 'ট্রাক্টর ও কম্বাইন ভাড়া' : 'Harvester & Drone Rental',
                        badge: 'এস্ক্রো সুরক্ষিত',
                        badgeColor: Colors.amber.shade900,
                        icon: Icons.agriculture_outlined,
                        color: const Color(0xFFE65100),
                        onTap: () => Get.to(() => const MachineryRentalScreen()),
                      ),
                      _buildServiceTile(
                        title: isBn ? 'উপজেলা ট্রান্সপোর্ট 🚚' : 'Upazila Transport',
                        subtitle: isBn ? 'পিকআপ ও ট্রাক বুকিং' : 'Live Truck GPS Booking',
                        badge: '৫% প্ল্যাটফর্ম সেফটি',
                        badgeColor: Colors.blue,
                        icon: Icons.local_shipping_outlined,
                        color: const Color(0xFF1565C0),
                        onTap: () => Get.to(() => const UpazilaTransportScreen()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // B2B Sponsored Brand Deals Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade900.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified, color: Colors.amber, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'ACI & Lal Teer পার্টনার জোন',
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'SPONSORED',
                                      style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'সার্টিফাইড হাইব্রিড বীজ ও ফিডে আকর্ষণীয় ছাড়',
                                style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.white.withOpacity(0.85)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Trending Crops Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBn ? 'জনপ্রিয় ফসল' : 'Trending Crops',
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
                    isBn ? 'আমার দোকান' : 'My Shop',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryGrid(),
                  const SizedBox(height: 32),

                  // Market Price Analytics Link
                  _buildMarketPriceLink(isBn),
                  const SizedBox(height: 32),

                  // Quick Stats
                  Text(
                    isBn ? 'দোকানের পরিসংখ্যান' : 'Shop Statistics',
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
    final isBn = LanguageProvider.isBn(context);
    final trending = [
      {
        'name': isBn ? 'কাঁচা মরিচ' : 'Fresh Chili', 
        'price': isBn ? '৳১২০/কেজি' : '৳120/kg', 
        'rating': '4.8★', 
        'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584281/Screenshot_2026-06-28_001608_krqrup.png',
        'color': Colors.redAccent
      },
      {
        'name': isBn ? 'দেশি আম' : 'Deshi Mango', 
        'price': isBn ? '৳৮০/কেজি' : '৳80/kg', 
        'rating': '4.9★', 
        'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782583216/image_sxwwpa.png',
        'color': Colors.orangeAccent
      },
      {
        'name': isBn ? 'প্রিমিয়াম চাল' : 'Premium Rice', 
        'price': isBn ? '৳৭৫/কেজি' : '৳75/kg', 
        'rating': '4.7★', 
        'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584453/Screenshot_2026-06-28_002037_e5q6ll.png',
        'color': Colors.amber
      },
      {
        'name': isBn ? 'অর্গানিক পেঁয়াজ' : 'Organic Onion', 
        'price': isBn ? '৳৯০/কেজি' : '৳90/kg', 
        'rating': '4.5★', 
        'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584281/Screenshot_2026-06-28_001608_krqrup.png',
        'color': Colors.purpleAccent
      },
      {
        'name': isBn ? 'তাজা টমেটো' : 'Fresh Tomato', 
        'price': isBn ? '৳৬০/কেজি' : '৳60/kg', 
        'rating': '4.6★', 
        'image': 'https://images.unsplash.com/photo-1561136594-7f68413baa99?q=80&w=400&auto=format&fit=crop',
        'color': Colors.red
      },
      {
        'name': isBn ? 'বগুড়ার আলু' : 'Bogura Potato', 
        'price': isBn ? '৳৪৫/কেজি' : '৳45/kg', 
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
    final isBn = LanguageProvider.isBn(context);
    final categories = [
      {'name': isBn ? 'শাকসবজি' : 'Vegetables', 'icon': Icons.eco, 'key': 'vegetables', 'color': Colors.lightGreen},
      {'name': isBn ? 'ফলমূল' : 'Fruits', 'icon': Icons.apple, 'key': 'fruits', 'color': Colors.orange},
      {'name': isBn ? 'মসলা' : 'Spices', 'icon': Icons.grain, 'key': 'spices', 'color': Colors.red},
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
              LanguageProvider.isBn(context) ? '$productCount টি পণ্য' : '$productCount Items',
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
    final isBn = LanguageProvider.isBn(context);
    final total = _categoryProductCounts.values.fold<int>(0, (a, b) => a + b);

    return Row(
      children: [
        _buildStatCard(isBn ? 'মোট পণ্য' : 'Total Products', '$total', Icons.inventory_2, Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard(isBn ? 'ক্যাটাগরি' : 'Categories', '3', Icons.category, Colors.purple),
        const SizedBox(width: 12),
        _buildStatCard(isBn ? 'সক্রিয়' : 'Active', isBn ? 'হ্যাঁ' : 'Yes', Icons.check_circle, Colors.green),
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

  Widget _buildMarketPriceLink(bool isBn) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MarketPriceAnalysisScreen(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'বাজার দর বিশ্লেষণ' : 'Market Price Analysis',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isBn ? 'আজকের বাজার দর ও প্রবণতা জানুন' : 'Check today\'s market prices & trends',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTile({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    badge,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

