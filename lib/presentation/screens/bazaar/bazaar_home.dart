import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';
import 'package:agrolinkbd/presentation/screens/buyer/shopping_cart_screen.dart';
import 'package:agrolinkbd/presentation/screens/auction/auction_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/contracts/farmer_contracts_screen.dart';
import 'package:agrolinkbd/presentation/screens/analytics/market_price_analysis_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/vip_wholesaler_directory_screen.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/buyer_rfq_board_screen.dart';
import 'package:agrolinkbd/core/services/vip_subscription_service.dart';
import 'widgets/vip_wholesale_gatekeeper_card.dart';
import 'add_product_screen.dart';
import 'product_detail.dart';

class BazaarHome extends StatefulWidget {
  const BazaarHome({super.key});

  @override
  State<BazaarHome> createState() => _BazaarHomeState();
}

class _BazaarHomeState extends State<BazaarHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _userId = '';
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'All', 'nameBN': 'সব ফসল', 'key': 'all', 'icon': Icons.grid_view_rounded},
    {'name': 'Vegetables', 'nameBN': '🥬 শাকসবজি', 'key': 'vegetables', 'icon': Icons.eco},
    {'name': 'Fruits', 'nameBN': '🍎 ফলমূল', 'key': 'fruits', 'icon': Icons.apple},
    {'name': 'Grains', 'nameBN': '🌾 খাদ্যশস্য ও চাল', 'key': 'grains', 'icon': Icons.grass},
    {'name': 'Spices', 'nameBN': '🌶️ মসলা ও পেঁয়াজ', 'key': 'spices', 'icon': Icons.whatshot},
    {'name': 'Seeds', 'nameBN': '🌱 বীজ ও চারা', 'key': 'seeds', 'icon': Icons.spa},
    {'name': 'Bio Inputs', 'nameBN': '🧪 জৈব সার ও উপাদান', 'key': 'inputs', 'icon': Icons.science},
  ];

  final List<Map<String, dynamic>> _marketTicker = [
    {
      'cropBn': 'বগুড়ার আলু',
      'cropEn': 'Bogura Potato',
      'priceBn': '৳৪৫/কেজি',
      'priceEn': '৳45/kg',
      'change': '+৳2.0 (4.6%)',
      'isUp': true
    },
    {
      'cropBn': 'কাটারিভোগ চাল',
      'cropEn': 'Kataribhog Rice',
      'priceBn': '৳৮৫/কেজি',
      'priceEn': '৳85/kg',
      'change': '+৳1.5 (1.8%)',
      'isUp': true
    },
    {
      'cropBn': 'রাজশাহীর আম',
      'cropEn': 'Rajshahi Mango',
      'priceBn': '৳১১০/কেজি',
      'priceEn': '৳110/kg',
      'change': '-৳5.0 (4.3%)',
      'isUp': false
    },
    {
      'cropBn': 'ফরিদপুরের পেঁয়াজ',
      'cropEn': 'Faridpur Onion',
      'priceBn': '৳৭০/কেজি',
      'priceEn': '৳70/kg',
      'change': '+৳3.0 (4.4%)',
      'isUp': true
    },
    {
      'cropBn': 'চাঁদপুরের মরিচ',
      'cropEn': 'Chandpur Chili',
      'priceBn': '৳১৩০/কেজি',
      'priceEn': '৳130/kg',
      'change': '-৳10.0 (7.1%)',
      'isUp': false
    },
    {
      'cropBn': 'যশোরের বেগুন',
      'cropEn': 'Jashore Eggplant',
      'priceBn': '৳৫৫/কেজি',
      'priceEn': '৳55/kg',
      'change': '+৳2.0 (3.7%)',
      'isUp': true
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeUser();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  void _initializeUser() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _userId = userProvider.currentUser?.id ?? FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = LanguageProvider.isBn(context);
    const Color forestGreen = Color(0xFF1B5E20);
    const Color lightBg = Color(0xFFF4F7F5);
    const Color darkBg = Color(0xFF0C140E);

    return Scaffold(
      backgroundColor: isDark ? darkBg : lightBg,
      appBar: AppBar(
        backgroundColor: forestGreen,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.amberAccent, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'পাইকারি কৃষি বাজার ও ফসল হাব' : 'Agri Wholesale Bazaar',
                    style: GoogleFonts.hindSiliguri(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isBn ? 'দেশজুড়ে সরাসরি কৃষকের ফসল বাণিজ্য' : 'Direct Farmer-to-Wholesale Trade',
                    style: GoogleFonts.hindSiliguri(
                      color: Colors.white70,
                      fontSize: 10.5,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Add product quick button
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: isBn ? 'নতুন ফসল বিক্রির বিজ্ঞাপন' : 'Add New Product',
            onPressed: () {
              Get.to(() => const AddProductScreen());
            },
          ),
          // Shopping Cart Badge
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    tooltip: isBn ? 'শপিং কার্ট' : 'Shopping Cart',
                    onPressed: () => Get.to(() => const ShoppingCartScreen()),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${cart.itemCount}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: forestGreen,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.amberAccent,
              indicatorWeight: 3.5,
              labelColor: Colors.amberAccent,
              unselectedLabelColor: Colors.white70,
              labelStyle: GoogleFonts.hindSiliguri(fontSize: 14, fontWeight: FontWeight.bold),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.travel_explore_rounded, size: 18),
                      const SizedBox(width: 6),
                      Text(isBn ? 'পাইকারি বাজার ট্রেড' : 'Live Wholesale'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 18),
                      const SizedBox(width: 6),
                      Text(isBn ? 'আমার দোকান ও স্টক' : 'My Shop & Stock'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLiveBazaarTab(isDark, isBn, forestGreen),
          _buildMyShopTab(isDark, isBn, forestGreen),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddProductScreen()),
        backgroundColor: forestGreen,
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: Text(
          isBn ? 'ফসল পোস্ট করুন' : 'Post Crop',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // TAB 1: LIVE WHOLESALE BAZAAR & COMMODITY FLOOR
  // ==========================================================
  Widget _buildLiveBazaarTab(bool isDark, bool isBn, Color primaryGreen) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: CustomScrollView(
        slivers: [
          // 1. Search and Filter Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1B261D) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: primaryGreen.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.hindSiliguri(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: isBn ? 'ফসল, জাত বা জেলার নাম লিখে খুঁজুন...' : 'Search crops, variety, or district...',
                    hintStyle: GoogleFonts.hindSiliguri(
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                      fontSize: 13,
                    ),
                    icon: const Icon(Icons.search, color: Color(0xFF2E7D32)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          // 2. Live Market Price Ticker Bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF132216), const Color(0xFF1A301E)]
                      : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.show_chart, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isBn ? 'আজকের লাইভ পাইকারি দর ও ট্রেন্ড' : "Today's Wholesale Price Ticker",
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.greenAccent : const Color(0xFF1B5E20),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => Get.to(() => const MarketPriceAnalysisScreen()),
                        child: Text(
                          isBn ? 'সব রেট ➔' : 'View All ➔',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 52,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _marketTicker.length,
                      itemBuilder: (context, index) {
                        final item = _marketTicker[index];
                        final isUp = item['isUp'] as bool;
                        return Container(
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E2E20) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isUp
                                  ? Colors.green.withValues(alpha: 0.4)
                                  : Colors.red.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isBn ? (item['cropBn'] as String) : (item['cropEn'] as String),
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    isBn ? (item['priceBn'] as String) : (item['priceEn'] as String),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2E7D32),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['change'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: isUp ? Colors.green.shade700 : Colors.red.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Ultra Pro Trade Hub (Auction, Contract Farming, Price Radar, Aratdar Directory)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isBn ? 'আল্ট্রা প্রো ফসল বাণিজ্য ও ট্রেড হাব 💎' : 'Ultra Pro Agri-Trade Hub 💎',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'PRO',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHubCard(
                          title: isBn ? 'লাইভ ফসল নিলাম' : 'Live Crop Auction',
                          subtitle: isBn ? 'উন্মুক্ত ডাক ও বিডিং' : 'Open Wholesaler Bidding',
                          icon: Icons.gavel_rounded,
                          color: const Color(0xFFC2185B),
                          onTap: () => Get.to(() => const AuctionScreen()),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildHubCard(
                          title: isBn ? 'চুক্তি চাষ ও করপোরেট' : 'Contract Farming',
                          subtitle: isBn ? 'আগাম নিশ্চিত বায়না' : 'Corporate Harvest Buyback',
                          icon: Icons.assignment_turned_in_rounded,
                          color: const Color(0xFF00796B),
                          onTap: () => Get.to(() => const FarmerContractsScreen()),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildHubCard(
                          title: isBn ? '১৪-দিনের দর পূর্বাভাস' : 'AI Price Forecast',
                          subtitle: isBn ? 'দামের ওঠানামা রাডার' : 'Demand & Trend Radar',
                          icon: Icons.trending_up_rounded,
                          color: const Color(0xFF6A1B9A),
                          onTap: () => Get.to(() => const MarketPriceAnalysisScreen()),
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildHubCard(
                          title: isBn ? 'আড়তদার ডিরেক্টরি' : 'Aratdar Directory',
                          subtitle: isBn ? 'বড় পাইকারদের নম্বর' : 'Verified Merchant List',
                          icon: Icons.contact_phone_rounded,
                          color: const Color(0xFFE65100),
                          onTap: () => Get.to(() => const VipWholesalerDirectoryScreen()),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. Dynamic Category Selector Chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat['key'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        showCheckmark: false,
                        label: Text(
                          isBn ? cat['nameBN'] as String : cat['name'] as String,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.grey.shade300 : Colors.black87),
                          ),
                        ),
                        backgroundColor: isDark ? const Color(0xFF1A281E) : Colors.white,
                        selectedColor: primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? primaryGreen
                                : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = cat['key'] as String;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // 5. Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn ? 'সক্রিয় পাইকারি ফসল তালিকা' : 'Active Wholesale Crop Listings',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  Text(
                    isBn ? 'সরাসরি খামারের দর' : 'Direct Farm Gate Price',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11.5,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 6. Real-time Live Wholesale Crop Stream from Firestore
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('bazaar_products')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              List<Map<String, dynamic>> products = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                data['id'] = doc.id;
                return data;
              }).toList();

              // Filter by category
              if (_selectedCategory != 'all') {
                products = products
                    .where((p) => (p['category'] ?? '').toString().toLowerCase() == _selectedCategory)
                    .toList();
              }

              // Filter by search query
              if (_searchQuery.isNotEmpty) {
                products = products.where((p) {
                  final title = (p['title'] ?? p['name'] ?? '').toString().toLowerCase();
                  final loc = (p['location'] ?? '').toString().toLowerCase();
                  final cat = (p['category'] ?? '').toString().toLowerCase();
                  return title.contains(_searchQuery) || loc.contains(_searchQuery) || cat.contains(_searchQuery);
                }).toList();
              }

              if (products.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyBazaarView(isDark, isBn),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = products[index];
                      return _buildCropProductCard(item, isDark, isBn, primaryGreen);
                    },
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // TAB 2: MY SHOP & INVENTORY HUB (আমার দোকান)
  // ==========================================================
  Widget _buildMyShopTab(bool isDark, bool isBn, Color primaryGreen) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: CustomScrollView(
        slivers: [
          // 1. Farmer Shop Header & Stats Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade900.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                            final user = userProvider.currentUser;
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    (user?.name.isNotEmpty == true)
                                        ? user!.name[0].toUpperCase()
                                        : 'F',
                                    style: GoogleFonts.poppins(
                                      color: primaryGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user?.name.isNotEmpty == true
                                          ? '${user!.name} এর দোকান'
                                          : (isBn ? 'আমার কৃষি দোকান' : 'My Agri Store'),
                                      style: GoogleFonts.hindSiliguri(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.verified, color: Colors.amberAccent, size: 13),
                                        const SizedBox(width: 4),
                                        Text(
                                          isBn ? 'ভেরিফাইড কৃষক সেলার' : 'Verified Farmer Seller',
                                          style: GoogleFonts.hindSiliguri(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Get.to(() => const AddProductScreen()),
                          icon: const Icon(Icons.add, size: 16, color: Color(0xFF1B5E20)),
                          label: Text(
                            isBn ? 'নতুন ফসল' : 'New Crop',
                            style: GoogleFonts.hindSiliguri(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: const Color(0xFF1B5E20),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 14),

                    // Live Stats
                    StreamBuilder<QuerySnapshot>(
                      stream: _firestore
                          .collection('bazaar_products')
                          .where('sellerId', isEqualTo: _userId.isNotEmpty ? _userId : 'dummy_id')
                          .snapshots(),
                      builder: (context, snap) {
                        int totalItems = 0;
                        double totalEstValue = 0.0;
                        int activeItems = 0;

                        if (snap.hasData) {
                          totalItems = snap.data!.docs.length;
                          for (var doc in snap.data!.docs) {
                            final data = doc.data() as Map<String, dynamic>;
                            final price = (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0;
                            final qty = (data['quantity'] is num) ? (data['quantity'] as num).toDouble() : 0.0;
                            totalEstValue += (price * qty);
                            if (data['status'] == 'available' || data['status'] == null) {
                              activeItems++;
                            }
                          }
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildShopStatItem(
                              label: isBn ? 'মোট ফসল' : 'Total Items',
                              value: '$totalItems',
                              icon: Icons.inventory_2,
                            ),
                            Container(width: 1, height: 30, color: Colors.white24),
                            _buildShopStatItem(
                              label: isBn ? 'সক্রিয় লিস্টিং' : 'Active Stock',
                              value: '$activeItems',
                              icon: Icons.check_circle_outline,
                            ),
                            Container(width: 1, height: 30, color: Colors.white24),
                            _buildShopStatItem(
                              label: isBn ? 'সম্ভাব্য বিক্রয়' : 'Est. Value',
                              value: '৳${totalEstValue.toStringAsFixed(0)}',
                              icon: Icons.monetization_on_outlined,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Quick Action Links
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.to(() => const BuyerRfqBoardScreen()),
                      icon: const Icon(Icons.assignment_outlined, size: 16, color: Color(0xFF2E7D32)),
                      label: Text(
                        isBn ? 'পাইকারি চাহিদা বোর্ড' : 'Buyer RFQ Board',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.to(() => const AddProductScreen()),
                      icon: const Icon(Icons.cloud_upload_outlined, size: 16, color: Colors.white),
                      label: Text(
                        isBn ? 'নতুন ফসল আপলোড' : 'Upload Crop',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Section Title
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                isBn ? 'আপনার দোকানের ফসল ইনভেন্টরি' : 'Your Shop Inventory',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),

          // 4. Live My Products List with Instant Edit / Delete
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('bazaar_products')
                .where('sellerId', isEqualTo: _userId.isNotEmpty ? _userId : 'dummy_id')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyMyShopView(isDark, isBn),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      data['id'] = doc.id;
                      return _buildMyShopItemCard(data, isDark, isBn, primaryGreen);
                    },
                    childCount: docs.length,
                  ),
                ),
              );
            },
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 90),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HELPER WIDGETS
  // ==========================================================
  Widget _buildHubCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF17241A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 10,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCropProductCard(
    Map<String, dynamic> item,
    bool isDark,
    bool isBn,
    Color primaryGreen,
  ) {
    final title = item['title'] ?? item['name'] ?? 'কৃষি ফসল';
    final price = (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0;
    final quantity = (item['quantity'] is num) ? (item['quantity'] as num).toDouble() : 0.0;
    final unit = item['unit'] ?? 'কেজি';
    final location = item['location'] ?? 'বাংলাদেশ';
    final imageUrl = item['imageUrl'] as String?;
    final isAvailable = item['status'] == 'available' || item['status'] == null;

    return InkWell(
      onTap: () {
        Get.to(() => ProductDetail(product: item));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF17241A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Category Pill & Stock Status
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    color: primaryGreen.withValues(alpha: 0.08),
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => _buildPlaceholderCropImage(primaryGreen),
                          )
                        : _buildPlaceholderCropImage(primaryGreen),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 10, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          location,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 9.5,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAvailable ? Colors.green.shade700 : Colors.red.shade700,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isAvailable ? (isBn ? 'স্টকে আছে' : 'In Stock') : (isBn ? 'স্টক শেষ' : 'Sold Out'),
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${isBn ? 'মজুদ:' : 'Stock:'} ${quantity.toStringAsFixed(0)} $unit',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Price & 1-tap Cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '৳${price.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                          Text(
                            '/$unit',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          // Quick add to cart
                          final cartProvider = Provider.of<CartProvider>(context, listen: false);
                          cartProvider.addToCart(
                            CartItem(
                              id: item['id'] ?? UniqueKey().toString(),
                              title: title,
                              price: price,
                              unit: unit,
                              quantity: 1.0,
                              imageUrl: imageUrl ?? '',
                              itemType: CartItemType.product,
                              sellerId: item['sellerId'] ?? item['userId'] ?? '',
                              sellerName: item['sellerName'] ?? 'কৃষক',
                              sellerRole: 'farmer',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isBn ? '$title কার্টে যোগ করা হয়েছে 🛒' : '$title added to cart 🛒',
                                style: GoogleFonts.hindSiliguri(),
                              ),
                              backgroundColor: const Color(0xFF1B5E20),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyShopItemCard(
    Map<String, dynamic> item,
    bool isDark,
    bool isBn,
    Color primaryGreen,
  ) {
    final title = item['title'] ?? item['name'] ?? 'ফসল';
    final price = (item['price'] is num) ? (item['price'] as num).toDouble() : 0.0;
    final quantity = (item['quantity'] is num) ? (item['quantity'] as num).toDouble() : 0.0;
    final unit = item['unit'] ?? 'কেজি';
    final location = item['location'] ?? 'খামার';
    final isAvailable = item['status'] == 'available' || item['status'] == null;
    final imageUrl = item['imageUrl'] as String?;
    final docId = item['id'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17241A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primaryGreen.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70,
                height: 70,
                color: primaryGreen.withValues(alpha: 0.1),
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => _buildPlaceholderCropImage(primaryGreen),
                      )
                    : _buildPlaceholderCropImage(primaryGreen),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isAvailable ? Colors.green.shade300 : Colors.red.shade300,
                          ),
                        ),
                        child: Text(
                          isAvailable ? (isBn ? 'সক্রিয়' : 'Active') : (isBn ? 'স্টক শেষ' : 'Sold Out'),
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isAvailable ? Colors.green.shade800 : Colors.red.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '৳${price.toStringAsFixed(0)}/$unit • $quantity $unit $location',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Quick Edit Price & Quantity
                      InkWell(
                        onTap: () => _showQuickEditDialog(docId, title, price, quantity, unit, isAvailable),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.edit, size: 12, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                isBn ? 'এডিট করুন' : 'Edit',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Quick Delete
                      InkWell(
                        onTap: () => _showDeleteConfirmDialog(docId, title),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline, size: 12, color: Colors.red),
                              const SizedBox(width: 4),
                              Text(
                                isBn ? 'মুছুন' : 'Delete',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18, color: Colors.amberAccent),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(
            fontSize: 10.5,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyBazaarView(bool isDark, bool isBn) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17241A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.storefront_outlined, size: 60, color: Color(0xFF2E7D32)),
          const SizedBox(height: 12),
          Text(
            isBn ? 'এই ক্যাটাগরিতে কোনো ফসল বিজ্ঞাপিত হয়নি' : 'No crops listed in this category',
            style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            isBn ? 'আপনার খামারের ফসল বিক্রি করতে নিচে ক্লিক করুন' : 'Post your farm produce for sale now',
            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddProductScreen()),
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              isBn ? 'নতুন ফসল যোগ করুন' : 'Add New Product',
              style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMyShopView(bool isDark, bool isBn) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF17241A) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.agriculture_rounded, size: 50, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 14),
          Text(
            isBn ? 'আপনার দোকানে কোনো ফসল তালিকাভুক্ত নেই' : 'No crops in your shop yet',
            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            isBn
                ? 'আপনার ক্ষেতের উৎপাদিত শাকসবজি, ফলমূল বা খাদ্যশস্য সরাসরি পাইকার ও ক্রেতাদের কাছে বিক্রি করতে এখনই বিজ্ঞাপন দিন।'
                : 'Post your agricultural harvest directly to thousands of wholesale and retail buyers.',
            textAlign: TextAlign.center,
            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const AddProductScreen()),
            icon: const Icon(Icons.add_circle, color: Colors.white),
            label: Text(
              isBn ? 'প্রথম ফসল যোগ করুন 🌾' : 'Add First Crop 🌾',
              style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderCropImage(Color primaryGreen) {
    return Container(
      color: primaryGreen.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(Icons.eco, color: Color(0xFF2E7D32), size: 36),
      ),
    );
  }

  // ==========================================================
  // QUICK EDIT & DELETE DIALOGS
  // ==========================================================
  void _showQuickEditDialog(
    String docId,
    String currentTitle,
    double currentPrice,
    double currentQty,
    String unit,
    bool isAvailable,
  ) {
    final priceController = TextEditingController(text: currentPrice.toStringAsFixed(0));
    final qtyController = TextEditingController(text: currentQty.toStringAsFixed(0));
    bool available = isAvailable;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(
                'ফসল আপডেট: $currentTitle',
                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'প্রতি $unit মূল্য (৳)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'মজুদ পরিমাণ ($unit)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: Text('বিক্রয়ের জন্য উন্মুক্ত', style: GoogleFonts.hindSiliguri(fontSize: 13)),
                    value: available,
                    activeThumbColor: const Color(0xFF2E7D32),
                    onChanged: (val) {
                      setDialogState(() {
                        available = val;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('বাতিল', style: GoogleFonts.hindSiliguri(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newPrice = double.tryParse(priceController.text) ?? currentPrice;
                    final newQty = double.tryParse(qtyController.text) ?? currentQty;

                    await _firestore.collection('bazaar_products').doc(docId).update({
                      'price': newPrice,
                      'quantity': newQty,
                      'status': available ? 'available' : 'sold_out',
                      'updatedAt': FieldValue.serverTimestamp(),
                    });

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ফসল সফলভাবে আপডেট হয়েছে! ✅'),
                          backgroundColor: Color(0xFF1B5E20),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
                  child: Text('সংরক্ষণ করুন', style: GoogleFonts.hindSiliguri(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmDialog(String docId, String title) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            'ফসল ডিলিট নিশ্চিতকরণ',
            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          content: Text(
            'আপনি কি নিশ্চিতভাবে "$title" তালিকাটি দোকান থেকে মুছে ফেলতে চান?',
            style: GoogleFonts.hindSiliguri(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('বাতিল', style: GoogleFonts.hindSiliguri(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _firestore.collection('bazaar_products').doc(docId).delete();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('ফসল সফলভাবে মুছে ফেলা হয়েছে! 🗑️'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('ডিলিট করুন', style: GoogleFonts.hindSiliguri(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
