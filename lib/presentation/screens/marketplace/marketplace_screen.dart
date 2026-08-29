import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/add_product_screen.dart';
import 'package:agrolinkbd/core/models/market_price_model.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';
import 'package:agrolinkbd/presentation/widgets/quick_buy_bottom_sheet.dart';
import 'package:agrolinkbd/presentation/screens/analytics/market_price_analysis_screen.dart';
import 'package:agrolinkbd/core/services/market_price_service.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String _selectedCategory = 'সব';
  String _sortBy = 'popular';
  int _currentBannerIndex = 0;
  final MarketPriceService _marketPriceService = MarketPriceService();
  Map<String, double> _marketPrices = {};

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

  List<MarketPriceModel> _marketCommodities = [];

  @override
  void initState() {
    super.initState();
    _fetchMarketPrices();
  }

  Future<void> _fetchMarketPrices() async {
    final prices = await _marketPriceService.fetchCurrentMarketPrices();
    if (mounted) {
      setState(() {
        _marketCommodities = prices;
        for (var p in prices) {
          _marketPrices[p.productName] = p.currentPrice;
        }
      });
    }
  }

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
          // MARKET PRICE ANALYSIS BANNER
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarketPriceAnalysisScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
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
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.analytics, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'বাজার দর বিশ্লেষণ',
                              style: GoogleFonts.hindSiliguri(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'আজকের বাজার দর ও প্রবণতা জানুন',
                              style: GoogleFonts.hindSiliguri(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // ==========================================
          // COMMODITY GRID
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                String selectedKey = 'all';
                for(var c in _categories) {
                  if(c['label'] == _selectedCategory) {
                    selectedKey = c['key'];
                    break;
                  }
                }

                var filteredCommodities = selectedKey == 'all' 
                    ? _marketCommodities 
                    : _marketCommodities.where((p) => p.category == selectedKey).toList();

                if (_marketCommodities.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (filteredCommodities.isEmpty) {
                  return Center(
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
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        '${filteredCommodities.length} টি আইটেম পাওয়া গেছে',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: filteredCommodities.length,
                        itemBuilder: (context, index) {
                          return _buildCommodityCard(filteredCommodities[index]);
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

  Widget _buildCommodityCard(MarketPriceModel commodity) {
    bool isTrendUp = commodity.trend == PriceTrend.up;
    return GestureDetector(
      onTap: () {
        Get.toNamed('/commodity-order-book', arguments: commodity);
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
                child: Container(
                  color: Colors.grey.shade100,
                  width: double.infinity,
                  child: commodity.imageUrl != null 
                      ? Image.network(
                          commodity.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            size: 60,
                            color: Colors.grey.shade400,
                          ),
                        )
                      : Center(
                          child: Icon(
                            commodity.category == 'vegetables' ? Icons.grass : 
                            commodity.category == 'fish' ? Icons.set_meal : 
                            commodity.category == 'meat' ? Icons.kebab_dining : Icons.shopping_basket,
                            size: 60,
                            color: Colors.green.shade300,
                          ),
                        ),
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
                    Text(
                      commodity.productName,
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'বেস প্রাইস (Agrolink)',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '৳${commodity.currentPrice}',
                              style: GoogleFonts.hindSiliguri(
                                color: const Color(0xFF1B5E20),
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              'প্রতি ${commodity.unit}',
                              style: GoogleFonts.hindSiliguri(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: isTrendUp ? Colors.red.shade50 : Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isTrendUp ? Icons.arrow_upward : Icons.arrow_downward,
                                size: 12,
                                color: isTrendUp ? Colors.red : Colors.green,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                isTrendUp ? 'উচ্চমূল্য' : 'স্বাভাবিক',
                                style: GoogleFonts.hindSiliguri(
                                  color: isTrendUp ? Colors.red : Colors.green, 
                                  fontSize: 10, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
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

