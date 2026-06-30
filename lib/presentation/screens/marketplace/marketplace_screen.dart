import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/add_product_screen.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/presentation/screens/buyer/buyer_orders_screen.dart';
import 'package:agrolinkbd/presentation/widgets/quick_buy_bottom_sheet.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'সব';
  String _sortBy = 'popular';
  int _currentBannerIndex = 0;

  final List<String> _banners = [
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1595853035070-59a39fe84da3?q=80&w=1200&auto=format&fit=crop',
  ];

  final List<Map<String, dynamic>> _categories = [
    {'label': 'সব', 'key': 'all', 'icon': Icons.grid_view_rounded},
    {'label': 'সবজি', 'key': 'vegetables', 'icon': Icons.grass_rounded},
    {'label': 'ফলমূল', 'key': 'fruits', 'icon': Icons.apple_rounded},
    {'label': 'চাল', 'key': 'grains', 'icon': Icons.agriculture_rounded},
    {'label': 'মসলা', 'key': 'spices', 'icon': Icons.local_florist_rounded},
    {'label': 'মাছ', 'key': 'fish', 'icon': Icons.set_meal_rounded},
    {'label': 'মাংস', 'key': 'meat', 'icon': Icons.kebab_dining_rounded},
    {'label': 'দুধ-ডিম', 'key': 'dairy', 'icon': Icons.egg_rounded},
  ];

  
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isFarmer = userProvider.currentUser?.userType == UserType.farmer;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==========================================
          // PREMIUM APP BAR & SEARCH
          // ==========================================
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            floating: true,
            backgroundColor: const Color(0xFF1B5E20), // Deep forest green
            elevation: 0,
            title: Text(
              'এগ্রোলিংক মার্কেট',
              style: GoogleFonts.hindSiliguri(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                onPressed: () {},
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort, color: Colors.white),
                onSelected: (value) => setState(() => _sortBy = value),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'popular', child: Text('জনপ্রিয়', style: GoogleFonts.hindSiliguri())),
                  PopupMenuItem(value: 'price_low', child: Text('দাম: কম → বেশি', style: GoogleFonts.hindSiliguri())),
                  PopupMenuItem(value: 'price_high', child: Text('দাম: বেশি → কম', style: GoogleFonts.hindSiliguri())),
                  PopupMenuItem(value: 'rating', child: Text('সেরা রেটিং', style: GoogleFonts.hindSiliguri())),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'কী খুঁজছেন? (যেমন: টমেটো, আলু)',
                          hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade400, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF1B5E20)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // BANNER CAROUSEL
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: SizedBox(
                height: 160,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: _banners.length,
                      onPageChanged: (index) => setState(() => _currentBannerIndex = index),
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(_banners[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                                  child: Text('HOT DEALS', style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  index == 0 ? 'তাজা শাকসবজি' : index == 1 ? 'সরাসরি কৃষকের থেকে' : 'অর্গানিক ফলমূল',
                                  style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_banners.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentBannerIndex == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentBannerIndex == index ? const Color(0xFF4CAF50) : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // CATEGORY CHIPS
          // ==========================================
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['label'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['label']),
                    child: Container(
                      width: 75,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1B5E20) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat['icon'],
                            color: isSelected ? Colors.white : const Color(0xFF1B5E20),
                            size: 28,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat['label'],
                            style: GoogleFonts.hindSiliguri(
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ==========================================
          // PRODUCT GRID WITH FIREBASE
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bazaar_products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var docs = snapshot.data?.docs ?? [];
                
                List<Map<String, dynamic>> allProducts = [];
                
                for(var doc in docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  final title = data['title']?.toString().trim() ?? '';
                  if (title.isEmpty || title.toLowerCase() == 'unknown') {
                    continue;
                  }
                  allProducts.add({
                    'id': doc.id,
                    'name': title,
                    'price': (data['price'] ?? 0).toDouble(),
                    'unit': data['unit'] ?? 'kg',
                    'farmer': 'AgroLink Farm',
                    'farmerId': data['userId'],
                    'location': data['location'] ?? 'বাংলাদেশ',
                    'image': data['imageUrl'] ?? 'https://via.placeholder.com/150',
                    'rating': 4.5,
                    'category': data['category'] ?? 'other',
                    'badge': 'New',
                    'isVerified': true,
                  });
                }

                allProducts.addAll([
                  {
                    'name': 'তাজা টমেটো (Premium)',
                    'price': 120,
                    'unit': 'কেজি',
                    'farmer': 'করিম ফার্ম',
                    'location': 'বগুড়া',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757091/Tomato_hcjt7o.png',
                    'rating': 4.8,
                    'category': 'vegetables',
                    'badge': 'Hot',
                    'isVerified': true,
                  },
                  {
                    'name': 'দেশি পেঁয়াজ (Organic)',
                    'price': 40,
                    'unit': 'কেজি',
                    'farmer': 'রহিম এগ্রো',
                    'location': 'পাবনা',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757375/images_z5w9hg.jpg',
                    'rating': 4.5,
                    'category': 'vegetables',
                    'badge': 'Sale',
                    'isVerified': true,
                  },
                  {
                    'name': 'মিনিকেট চাল (সুপার)',
                    'price': 80,
                    'unit': 'কেজি',
                    'farmer': 'কৃষক সমবায়',
                    'location': 'দিনাজপুর',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584453/Screenshot_2026-06-28_002037_e5q6ll.png',
                    'rating': 4.9,
                    'category': 'grains',
                    'badge': null,
                    'isVerified': true,
                  },
                  {
                    'name': 'তাজা আলু (রংপুর)',
                    'price': 20,
                    'unit': 'কেজি',
                    'farmer': 'রংপুর ফার্ম',
                    'location': 'রংপুর',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782584736/Screenshot_2026-06-28_002524_ziwqmo.png',
                    'rating': 4.3,
                    'category': 'vegetables',
                    'badge': null,
                    'isVerified': false,
                  },
                  {
                    'name': 'আম (হিমসাগর)',
                    'price': 120,
                    'unit': 'কেজি',
                    'farmer': 'রাজশাহী ফ্রুট',
                    'location': 'রাজশাহী',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782583216/image_sxwwpa.png',
                    'rating': 4.9,
                    'category': 'fruits',
                    'badge': 'Top Rated',
                    'isVerified': true,
                  },
                  {
                    'name': 'রুই মাছ (হালদা)',
                    'price': 350,
                    'unit': 'কেজি',
                    'farmer': 'মৎস্য খামার',
                    'location': 'ময়মনসিংহ',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782734272/Screenshot_2026-06-29_175728_q4k1bk.png',
                    'rating': 4.7,
                    'category': 'fish',
                    'badge': 'Fresh',
                    'isVerified': true,
                  },
                  {
                    'name': 'গরুর মাংস (দেশি)',
                    'price': 650,
                    'unit': 'কেজি',
                    'farmer': 'সততা এগ্রো',
                    'location': 'ঢাকা',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782756123/images_wrgten.webp',
                    'rating': 4.8,
                    'category': 'meat',
                    'badge': null,
                    'isVerified': true,
                  },
                  {
                    'name': 'ফার্মের ডিম',
                    'price': 100,
                    'unit': 'ডজন',
                    'farmer': 'পোলট্রি ফার্ম',
                    'location': 'গাজীপুর',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782756249/download_ezwxls.jpg',
                    'rating': 4.6,
                    'category': 'dairy',
                    'badge': null,
                    'isVerified': true,
                  },
                                    {
                    'name': 'খাঁটি মধু (সুন্দরবন)',
                    'price': 1200,
                    'unit': 'কেজি',
                    'farmer': 'মৌয়াল সমবায়',
                    'location': 'খুলনা',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782756674/images_fhqvvm.jpg',
                    'rating': 4.9,
                    'category': 'spices',
                    'badge': 'Premium',
                    'isVerified': true,
                  },
                  {
                    'name': 'টাটকা বেগুন',
                    'price': 50,
                    'unit': 'কেজি',
                    'farmer': 'সবুজ এগ্রো',
                    'location': 'নরসিংদী',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757463/images_vqbixx.jpg',
                    'rating': 4.2,
                    'category': 'vegetables',
                    'badge': 'Fresh',
                    'isVerified': true,
                  },
                  {
                    'name': 'সরিষার তেল (ঘানি ভাঙা)',
                    'price': 350,
                    'unit': 'লিটার',
                    'farmer': 'তৈল কল',
                    'location': 'জামালপুর',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757514/images_cnlkya.jpg',
                    'rating': 4.9,
                    'category': 'spices',
                    'badge': 'Organic',
                    'isVerified': true,
                  },
                  {
                    'name': 'দেশি মুরগি',
                    'price': 600,
                    'unit': 'পিছ',
                    'farmer': 'গ্রামের খামার',
                    'location': 'কুমিল্লা',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757555/images_xgtcyf.jpg',
                    'rating': 4.7,
                    'category': 'meat',
                    'badge': null,
                    'isVerified': true,
                  },
                  {
                    'name': 'তরমুজ (বরিশাল)',
                    'price': 200,
                    'unit': 'পিছ',
                    'farmer': 'বরিশাল ফ্রুটস',
                    'location': 'বরিশাল',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757612/images_elzmmv.jpg',
                    'rating': 4.8,
                    'category': 'fruits',
                    'badge': 'Summer Special',
                    'isVerified': true,
                  },
                  {
                    'name': 'ধনে পাতা (দেশি)',
                    'price': 20,
                    'unit': 'আঁটি',
                    'farmer': 'কৃষক বাজার',
                    'location': 'সাভার',
                    'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1782757651/images_gnubxi.jpg',
                    'rating': 4.5,
                    'category': 'vegetables',
                    'badge': null,
                    'isVerified': false,
                  },
                ]);

                String selectedKey = 'all';
                for(var c in _categories) {
                  if(c['label'] == _selectedCategory) {
                    selectedKey = c['key'];
                    break;
                  }
                }

                var products = selectedKey == 'all' 
                    ? allProducts 
                    : allProducts.where((p) => p['category'] == selectedKey).toList();

                if (_sortBy == 'price_low') {
                  products.sort((a, b) => (a['price'] as num).compareTo(b['price'] as num));
                } else if (_sortBy == 'price_high') {
                  products.sort((a, b) => (b['price'] as num).compareTo(a['price'] as num));
                } else if (_sortBy == 'rating') {
                  products.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        '${products.length} টি পণ্য পাওয়া গেছে',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    if (products.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text('কোনো পণ্য পাওয়া যায়নি', style: GoogleFonts.hindSiliguri(color: Colors.grey.shade600, fontSize: 16)),
                            ],
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            return _buildProductCard(products[index]);
                          },
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: isFarmer ? FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const AddProductScreen());
        },
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('পণ্য যোগ করুন', style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold)),
      ) : null,
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => QuickBuyBottomSheet(product: product),
        );
      },
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product['image'] ?? 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?q=80&w=600&auto=format&fit=crop',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade200,
                        child: Icon(Icons.image_not_supported, color: Colors.grey.shade400, size: 40),
                      ),
                    ),
                    if (product['badge'] != null)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: product['badge'] == 'Hot' ? Colors.red : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product['badge'],
                            style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info Area
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${product['rating']}', style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        if (product['isVerified'])
                          const Icon(Icons.verified, size: 14, color: Colors.blue),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['name'],
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product['location'],
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '৳${product['price']}',
                              style: GoogleFonts.hindSiliguri(
                                color: const Color(0xFF1B5E20),
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'প্রতি ${product['unit']}',
                              style: GoogleFonts.hindSiliguri(
                                color: Colors.grey.shade600,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B5E20),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Order Now',
                            style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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

