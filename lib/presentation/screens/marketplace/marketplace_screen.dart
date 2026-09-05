import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/add_product_screen.dart';
import 'package:agrolinkbd/core/models/market_price_model.dart';
import 'package:agrolinkbd/presentation/widgets/quick_buy_bottom_sheet.dart';
import 'package:agrolinkbd/presentation/screens/analytics/market_price_analysis_screen.dart';
import 'package:agrolinkbd/core/services/market_price_service.dart';
import 'package:agrolinkbd/core/utils/masked_identity_helper.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/utils/number_converter.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  final String? initialCategory;
  const MarketplaceScreen({super.key, this.initialCategory});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late String _selectedCategoryKey;
  String _sortBy = 'popular';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  int _currentBannerIndex = 0;
  final MarketPriceService _marketPriceService = MarketPriceService();
  Map<String, double> _marketPrices = {};

  final List<String> _banners = [
    'https://images.unsplash.com/photo-1488459716781-31db52582fe9?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1542838132-92c53300491e?q=80&w=1200&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1595853035070-59a39fe84da3?q=80&w=1200&auto=format&fit=crop',
  ];

  final List<Map<String, dynamic>> _categories = [
    {'bn': 'সব', 'en': 'All', 'key': 'all', 'icon': Icons.grid_view_rounded},
    {'bn': 'শাকসবজি', 'en': 'Vegetables', 'key': 'vegetables', 'icon': Icons.eco_rounded},
    {'bn': 'ফলমূল', 'en': 'Fruits', 'key': 'fruits', 'icon': Icons.apple_rounded},
    {'bn': 'চাল ও শস্য', 'en': 'Grains', 'key': 'grains', 'icon': Icons.agriculture_rounded},
    {'bn': 'মসলা', 'en': 'Spices', 'key': 'spices', 'icon': Icons.local_florist_rounded},
    {'bn': 'তাজা মাছ', 'en': 'Fresh Fish', 'key': 'fish', 'icon': Icons.set_meal_rounded},
    {'bn': 'মাংস ও ডিম', 'en': 'Meat & Eggs', 'key': 'meat', 'icon': Icons.kebab_dining_rounded},
  ];

  List<MarketPriceModel> _marketCommodities = [];
  StreamSubscription<List<MarketPriceModel>>? _marketPriceSub;

  @override
  void initState() {
    super.initState();
    _selectedCategoryKey = widget.initialCategory ?? 'all';
    _subscribeToMarketPrices();
  }

  @override
  void dispose() {
    _marketPriceSub?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _subscribeToMarketPrices() {
    _marketPriceSub = _marketPriceService.streamCurrentMarketPrices().listen((prices) {
      if (mounted) {
        setState(() {
          _marketCommodities = prices;
          for (var p in prices) {
            _marketPrices[p.productName] = p.currentPrice;
          }
        });
      }
    });
  }

  void _openQuickBuyForCommodity(MarketPriceModel commodity) {
    final isBn = LanguageProvider.isBnStatic(context);
    final adaptedProduct = {
      'id': commodity.id.isNotEmpty ? commodity.id : 'commodity_${commodity.productName.hashCode}',
      'name': commodity.productName,
      'price': commodity.currentPrice,
      'unit': commodity.unit,
      'farmer': isBn ? 'এগ্রোলিংক ভেরিফাইড হাব কৃষক' : 'AgroLink Verified Hub Farmer',
      'farmerId': 'hub_farmer_verified',
      'location': isBn ? 'উপজেলা কালেকশন হাব' : 'Upazila Collection Hub',
      'image': commodity.imageUrl ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400&q=80',
      'rating': 4.9,
      'category': commodity.category,
      'isVerified': true,
      'qualityGrade': isBn ? 'Grade A+ (সুপার প্রিমিয়াম)' : 'Grade A+ (Super Premium)',
      'batchCode': MaskedIdentityHelper.generateBatchCode(),
    };
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: QuickBuyBottomSheet(product: adaptedProduct),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isFarmer = userProvider.currentUser?.userType == UserType.farmer;
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final textPrimary = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final textSecondary = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==========================================
          // PREMIUM APP BAR & SEARCH
          // ==========================================
          SliverAppBar(
            expandedHeight: 145,
            pinned: true,
            floating: true,
            backgroundColor: const Color(0xFF0F5132),
            elevation: 0,
            title: Text(
              isBn ? 'এগ্রোলিংক মার্কেটপ্লেস' : 'AgroLink Marketplace',
              style: GoogleFonts.hindSiliguri(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                tooltip: isBn ? 'আমার অর্ডারসমূহ' : 'My Orders',
                icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                onPressed: () {
                  Get.to(() => const FishBuyerOrdersScreen());
                },
              ),
              PopupMenuButton<String>(
                tooltip: isBn ? 'সাজান' : 'Sort',
                icon: const Icon(Icons.sort_rounded, color: Colors.white),
                onSelected: (value) => setState(() => _sortBy = value),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'popular',
                    child: Text(
                      isBn ? 'জনপ্রিয় পণ্য' : 'Popular',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'price_low',
                    child: Text(
                      isBn ? 'দাম: কম → বেশি' : 'Price: Low → High',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'price_high',
                    child: Text(
                      isBn ? 'দাম: বেশি → কম' : 'Price: High → Low',
                      style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0F5132), Color(0xFF198754), Color(0xFF15803D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 56, left: 16, right: 16),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val.trim()),
                        style: GoogleFonts.hindSiliguri(color: textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: isBn ? 'কী খুঁজছেন? (যেমন: টমেটো, আলু, মাছ)' : 'Search products (e.g. Tomato, Rice)...',
                          hintStyle: GoogleFonts.hindSiliguri(color: textSecondary, fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF15803D), size: 22),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded, color: textSecondary, size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SizedBox(
                height: 150,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: _banners.length,
                      onPageChanged: (index) => setState(() => _currentBannerIndex = index),
                      itemBuilder: (context, index) {
                        final bannerTitlesBn = [
                          'তাজা শাকসবজি ও ফলমূল',
                          'সরাসরি কৃষকের মাঠ থেকে',
                          '১০০% খাঁটি ও নিরাপদ পণ্য'
                        ];
                        final bannerTitlesEn = [
                          'Fresh Vegetables & Fruits',
                          'Direct From Farmer Fields',
                          '100% Pure & Safe Produce'
                        ];
                        final bannerSubBn = [
                          'পাইকারি মূল্যে এস্ক্রো সুরক্ষায় অর্ডার করুন',
                          'সরাসরি সরবরাহ ও মান যাচাইকৃত',
                          'নিরাপদ গেটওয়ে ও দ্রুত ডেলিভারি'
                        ];
                        final bannerSubEn = [
                          'Order at wholesale rates with escrow',
                          'Direct supply & quality checked',
                          'Secure checkout & fast delivery'
                        ];

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
                                colors: [
                                  Colors.black.withOpacity(0.75),
                                  Colors.black.withOpacity(0.2),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isBn ? '🔥 সেরা ডিল' : '🔥 BEST DEALS',
                                    style: GoogleFonts.hindSiliguri(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isBn ? bannerTitlesBn[index] : bannerTitlesEn[index],
                                  style: GoogleFonts.hindSiliguri(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  isBn ? bannerSubBn[index] : bannerSubEn[index],
                                  style: GoogleFonts.hindSiliguri(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
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
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: _currentBannerIndex == index ? 22 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentBannerIndex == index
                                  ? const Color(0xFF10B981)
                                  : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(3),
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
          // 6 KEY CATEGORIES (EXACT 6 + ALL)
          // ==========================================
          SliverToBoxAdapter(
            child: Container(
              height: 94,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final key = cat['key'] as String;
                  final isSelected = _selectedCategoryKey == key;
                  final label = isBn ? cat['bn'] : cat['en'];

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategoryKey = key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 80,
                      margin: const EdgeInsets.only(right: 10, top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF15803D) : cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF15803D) : borderColor,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? const Color(0xFF15803D).withOpacity(0.3)
                                : Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            color: isSelected ? Colors.white : const Color(0xFF15803D),
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.hindSiliguri(
                                color: isSelected ? Colors.white : textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                fontSize: 11,
                              ),
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
          // MARKET PRICE ANALYSIS PROMO BANNER
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarketPriceAnalysisScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEA580C).withOpacity(0.3),
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
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'দৈনিক বাজার দর ও অ্যানালিটিক্স' : 'Daily Market Price & Analytics',
                              style: GoogleFonts.hindSiliguri(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              isBn ? 'আজকের দাম, ট্রেন্ড ও এআই পূর্বাভাস দেখুন' : 'View today\'s prices, trends & AI forecast',
                              style: GoogleFonts.hindSiliguri(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // COMMODITY GRID (FILTERED & SORTED)
          // ==========================================
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                var filtered = _selectedCategoryKey == 'all'
                    ? List<MarketPriceModel>.from(_marketCommodities)
                    : _marketCommodities.where((p) => p.category == _selectedCategoryKey).toList();

                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered.where((p) =>
                      p.productName.toLowerCase().contains(q) ||
                      p.category.toLowerCase().contains(q)).toList();
                }

                if (_sortBy == 'price_low') {
                  filtered.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
                } else if (_sortBy == 'price_high') {
                  filtered.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
                }

                if (_marketCommodities.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF15803D)),
                    ),
                  );
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      child: Column(
                        children: [
                          Icon(Icons.search_off_rounded, size: 64, color: textSecondary.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          Text(
                            isBn ? 'কোনো পণ্য পাওয়া যায়নি' : 'No products found',
                            style: GoogleFonts.hindSiliguri(
                              color: textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isBn
                                ? 'অনুগ্রহ করে অন্য ক্যাটাগরি বা শব্দ দিয়ে চেষ্টা করুন'
                                : 'Please try another category or search query',
                            style: GoogleFonts.hindSiliguri(color: textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedCategoryKey = 'all';
                              });
                            },
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(
                              isBn ? 'সব পণ্য দেখুন' : 'View All Products',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn
                                ? '${BanglaEnglishNumberHelper.toBanglaDigits(filtered.length)} টি পণ্য পাওয়া গেছে'
                                : '${filtered.length} products found',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: textSecondary,
                            ),
                          ),
                          if (_selectedCategoryKey != 'all' || _searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _selectedCategoryKey = 'all';
                                });
                              },
                              child: Text(
                                isBn ? 'রিসেট করুন' : 'Reset Filter',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF15803D),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.74,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _buildCommodityCard(
                            filtered[index],
                            isBn: isBn,
                            isDark: isDark,
                            cardBg: cardBg,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
      floatingActionButton: isFarmer
          ? FloatingActionButton.extended(
              onPressed: () {
                Get.to(() => const AddProductScreen());
              },
              backgroundColor: const Color(0xFF15803D),
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                isBn ? 'পণ্য যোগ করুন' : 'Add Product',
                style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildCommodityCard(
    MarketPriceModel commodity, {
    required bool isBn,
    required bool isDark,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final bool isTrendUp = commodity.trend == PriceTrend.up;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Badges (Compact)
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  child: Container(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    width: double.infinity,
                    height: double.infinity,
                    child: commodity.imageUrl != null
                        ? Image.network(
                            commodity.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                Icons.eco_rounded,
                                size: 30,
                                color: isDark ? Colors.white38 : Colors.grey.shade400,
                              ),
                            ),
                          )
                        : Center(
                            child: Icon(
                              commodity.category == 'vegetables'
                                  ? Icons.eco
                                  : commodity.category == 'fish'
                                      ? Icons.set_meal
                                      : commodity.category == 'meat'
                                          ? Icons.kebab_dining
                                          : Icons.shopping_basket_rounded,
                              size: 30,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                  ),
                ),
                // Trend badge
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: isTrendUp ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isTrendUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          size: 9,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 1.5),
                        Text(
                          isTrendUp
                              ? (isBn ? 'উচ্চমূল্য' : 'High')
                              : (isBn ? 'স্বাভাবিক' : 'Normal'),
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Hub Verified Pill
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 9, color: Color(0xFF38BDF8)),
                        const SizedBox(width: 2),
                        Text(
                          isBn ? 'হাব' : 'HUB',
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content and CTA Button (Compact & Sleek)
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        commodity.productName,
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: textPrimary,
                          height: 1.15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, size: 9.5, color: textSecondary),
                          const SizedBox(width: 1.5),
                          Expanded(
                            child: Text(
                              isBn ? 'কালেকশন হাব' : 'Collection Hub',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 9.5,
                                color: textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '৳${isBn ? BanglaEnglishNumberHelper.toBanglaDigits(commodity.currentPrice.toStringAsFixed(0)) : commodity.currentPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.hindSiliguri(
                              color: const Color(0xFF15803D),
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '/ ${commodity.unit}',
                            style: GoogleFonts.hindSiliguri(
                              color: textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Order Now / Buy Button (Compact & Sleek)
                  SizedBox(
                    width: double.infinity,
                    height: 27,
                    child: ElevatedButton(
                      onPressed: () => _openQuickBuyForCommodity(commodity),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.flash_on_rounded, color: Colors.amberAccent, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            isBn ? 'অর্ডার করুন' : 'Order Now',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
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
