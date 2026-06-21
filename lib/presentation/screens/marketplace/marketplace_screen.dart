import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/add_product_screen.dart';

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
    {'label': 'সব', 'icon': Icons.grid_view_rounded},
    {'label': 'সবজি', 'icon': Icons.grass_rounded},
    {'label': 'ফলমূল', 'icon': Icons.apple_rounded},
    {'label': 'চাল', 'icon': Icons.agriculture_rounded},
    {'label': 'মসলা', 'icon': Icons.local_florist_rounded},
    {'label': 'মাছ', 'icon': Icons.set_meal_rounded},
    {'label': 'মাংস', 'icon': Icons.kebab_dining_rounded},
    {'label': 'দুধ-ডিম', 'icon': Icons.egg_rounded},
  ];

  final List<Map<String, dynamic>> _products = [
    {
      'name': 'তাজা টমেটো (Premium)',
      'price': 40,
      'unit': 'কেজি',
      'farmer': 'করিম ফার্ম',
      'location': 'বগুড়া',
      'image': 'https://images.unsplash.com/photo-1592924357228-91a4daadcfea?q=80&w=600&auto=format&fit=crop',
      'rating': 4.8,
      'category': 'সবজি',
      'badge': 'Hot',
      'isVerified': true,
    },
    {
      'name': 'দেশি পেঁয়াজ (Organic)',
      'price': 70,
      'unit': 'কেজি',
      'farmer': 'রহিম এগ্রো',
      'location': 'পাবনা',
      'image': 'https://images.unsplash.com/photo-1618512496248-a07fe83aa8cb?q=80&w=600&auto=format&fit=crop',
      'rating': 4.5,
      'category': 'সবজি',
      'badge': 'Sale',
      'isVerified': true,
    },
    {
      'name': 'মিনিকেট চাল (সুপার)',
      'price': 65,
      'unit': 'কেজি',
      'farmer': 'কৃষক সমবায়',
      'location': 'দিনাজপুর',
      'image': 'https://images.unsplash.com/photo-1586201375761-83865001e31c?q=80&w=600&auto=format&fit=crop',
      'rating': 4.9,
      'category': 'চাল',
      'badge': null,
      'isVerified': true,
    },
    {
      'name': 'তাজা আলু (রংপুর)',
      'price': 25,
      'unit': 'কেজি',
      'farmer': 'রংপুর ফার্ম',
      'location': 'রংপুর',
      'image': 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?q=80&w=600&auto=format&fit=crop',
      'rating': 4.3,
      'category': 'সবজি',
      'badge': null,
      'isVerified': false,
    },
    {
      'name': 'আম (হিমসাগর)',
      'price': 120,
      'unit': 'কেজি',
      'farmer': 'রাজশাহী ফ্রুট',
      'location': 'রাজশাহী',
      'image': 'https://images.unsplash.com/photo-1553284965-83fd3e82fa5a?q=80&w=600&auto=format&fit=crop',
      'rating': 4.9,
      'category': 'ফলমূল',
      'badge': 'Top Rated',
      'isVerified': true,
    },
    {
      'name': 'রুই মাছ (হালদা)',
      'price': 350,
      'unit': 'কেজি',
      'farmer': 'মৎস্য খামার',
      'location': 'ময়মনসিংহ',
      'image': 'https://images.unsplash.com/photo-1524824267900-2fa9cbf7a506?q=80&w=600&auto=format&fit=crop',
      'rating': 4.7,
      'category': 'মাছ',
      'badge': 'Fresh',
      'isVerified': true,
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    var products = _selectedCategory == 'সব'
        ? _products
        : _products.where((p) => p['category'] == _selectedCategory).toList();

    if (_sortBy == 'price_low') {
      products.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    } else if (_sortBy == 'price_high') {
      products.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    } else if (_sortBy == 'rating') {
      products.sort(
          (a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    }

    return products;
  }

  @override
  Widget build(BuildContext context) {
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
              style: GoogleFonts.poppins(
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
                  PopupMenuItem(value: 'popular', child: Text('জনপ্রিয়', style: GoogleFonts.poppins())),
                  PopupMenuItem(value: 'price_low', child: Text('দাম: কম → বেশি', style: GoogleFonts.poppins())),
                  PopupMenuItem(value: 'price_high', child: Text('দাম: বেশি → কম', style: GoogleFonts.poppins())),
                  PopupMenuItem(value: 'rating', child: Text('সেরা রেটিং', style: GoogleFonts.poppins())),
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
                          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
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
                                  child: Text('HOT DEALS', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  index == 0 ? 'তাজা শাকসবজি' : index == 1 ? 'সরাসরি কৃষকের থেকে' : 'অর্গানিক ফলমূল',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                            style: GoogleFonts.poppins(
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
          // PRODUCT COUNT
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Text(
                    '${_filteredProducts.length} টি পণ্য পাওয়া গেছে',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // PRODUCT GRID
          // ==========================================
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: _filteredProducts.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text('কোনো পণ্য পাওয়া যায়নি', style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                  )
                : SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.68,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildProductCard(_filteredProducts[index]);
                      },
                      childCount: _filteredProducts.length,
                    ),
                  ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const AddProductScreen());
        },
        backgroundColor: const Color(0xFF1B5E20),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('পণ্য যোগ করুন', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Container(
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
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(product['image']),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
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
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
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
                      Text('${product['rating']}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (product['isVerified'])
                        const Icon(Icons.verified, size: 14, color: Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product['name'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 12, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          product['location'],
                          style: GoogleFonts.poppins(
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
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '৳${product['price']}',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF1B5E20),
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'প্রতি ${product['unit']}',
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B5E20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
