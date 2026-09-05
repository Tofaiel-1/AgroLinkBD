import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/profile/profile_settings.dart';
import 'package:agrolinkbd/presentation/widgets/global_announcement_banner.dart';
import 'package:agrolinkbd/presentation/widgets/secure_balance_widget.dart';
import 'package:agrolinkbd/presentation/widgets/quick_buy_bottom_sheet.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/utils/number_converter.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/presentation/screens/buyer/order_details_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/services/transaction_service.dart';
import 'package:agrolinkbd/core/services/vip_subscription_service.dart';
import 'package:agrolinkbd/presentation/screens/subscription/vip_subscription_paywall_screen.dart';
import 'package:agrolinkbd/presentation/buyer/screens/buyer_notifications_screen.dart';
import 'package:agrolinkbd/core/services/buyer_analytics_service.dart';
import 'package:agrolinkbd/core/services/market_price_service.dart';
import 'package:agrolinkbd/core/models/market_price_model.dart';
import 'package:agrolinkbd/presentation/screens/analytics/market_price_analysis_screen.dart';
import 'package:agrolinkbd/core/services/weather_service.dart';
import 'package:agrolinkbd/core/models/weather_model.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _darkBlue = Color(0xFF0D47A1);

  final TransactionService _transactionService = TransactionService();
  final VipSubscriptionService _vipService = VipSubscriptionService();
  final BuyerAnalyticsService _analyticsService = BuyerAnalyticsService();
  final MarketPriceService _marketPriceService = MarketPriceService();
  final WeatherService _weatherService = WeatherService();

  double _balance = 0.0;
  WeatherModel? _currentWeather;

  @override
  void initState() {
    super.initState();
    _fetchBalance();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await _weatherService.fetchCurrentWeather();
      if (mounted) setState(() => _currentWeather = weather);
    } catch (_) {}
  }

  Future<void> _fetchBalance() async {
    final userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : null;
    final uid = userController?.userId ??
        FirebaseAuth.instance.currentUser?.uid ??
        '';
    if (uid.isNotEmpty) {
      final bal = await _transactionService.getWalletBalance(uid);
      if (mounted) {
        setState(() => _balance = bal);
      }
    }
  }

  void _openQuickBuy(Map<String, dynamic> product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: QuickBuyBottomSheet(product: product),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());

    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final uid = userController.userId.isNotEmpty
        ? userController.userId
        : FirebaseAuth.instance.currentUser?.uid ?? '';

    // Buyer Greeting Name Resolution
    final String buyerName = userController.userName.isNotEmpty
        ? userController.userName
        : (FirebaseAuth.instance.currentUser?.displayName?.isNotEmpty == true
            ? FirebaseAuth.instance.currentUser!.displayName!
            : (isBn ? 'সম্মানিত ক্রেতা' : 'Valued Buyer'));

    // Master-class High Contrast Palette
    final Color bgColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color cardBorder =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final Color textPrimary =
        isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final Color textSecondary =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ========================================================
          // 1. COMPACT SPACE-SAVING HEADER (TOP BALANCE + SALAM NAME)
          // ========================================================
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 14,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_darkBlue, _primaryBlue, Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Compact Balance Pill + Notifications + Profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Space-saving Balance Pill at top left
                      StreamBuilder<DocumentSnapshot>(
                        stream: uid.isNotEmpty
                            ? FirebaseFirestore.instance
                                .collection('cards')
                                .doc(uid)
                                .snapshots()
                            : null,
                        builder: (context, snapshot) {
                          String? walletPin;
                          if (snapshot.hasData && snapshot.data!.data() != null) {
                            walletPin = (snapshot.data!.data()
                                as Map<String, dynamic>)['walletPin'];
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                SecureBalanceWidget(
                                  balance: _balance,
                                  pin: walletPin,
                                  pinFieldType: 'walletBalance',
                                  textColor: Colors.white,
                                  fontSize: 11.5,
                                  label: isBn
                                      ? 'ব্যালেন্স দেখতে ট্যাপ করুন'
                                      : 'Tap for balance',
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Orders, Notification & Profile Icons
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeaderIcon(
                            Icons.receipt_long_rounded,
                            () => Get.to(() => const FishBuyerOrdersScreen()),
                            tooltip: isBn ? 'আমার অর্ডারসমূহ' : 'My Orders',
                          ),
                          const SizedBox(width: 8),
                          StreamBuilder<QuerySnapshot>(
                            stream: uid.isNotEmpty
                                ? FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .collection('notifications')
                                    .where('read', isEqualTo: false)
                                    .snapshots()
                                : null,
                            builder: (context, notifSnap) {
                              final unreadCount =
                                  notifSnap.data?.docs.length ?? 0;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  _buildHeaderIcon(
                                    Icons.notifications_none_rounded,
                                    () => Get.to(
                                        () => const BuyerNotificationsScreen()),
                                    tooltip: isBn ? 'বিজ্ঞপ্তি' : 'Notifications',
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      top: -2,
                                      right: -2,
                                      child: Container(
                                        padding: const EdgeInsets.all(3.5),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFEF4444),
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          unreadCount > 9
                                              ? '9+'
                                              : '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Get.to(() => const ProfileSettings()),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 1.5),
                              ),
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.25),
                                child: Text(
                                  buyerName.trim().isNotEmpty
                                      ? buyerName.trim()[0].toUpperCase()
                                      : 'B',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Salam Greeting with Name & Direct Orders Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          isBn
                              ? 'আসসালামু আলাইকুম, $buyerName 👋'
                              : 'Assalamu Alaikum, $buyerName 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Get.to(() => const FishBuyerOrdersScreen()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_shipping_outlined,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                isBn ? 'অর্ডার দেখুন' : 'My Orders',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Inline Smart Search Bar
                  GestureDetector(
                    onTap: () => Get.to(() => const MarketplaceScreen()),
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded,
                              color: Colors.white70, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isBn
                                  ? 'টাটকা সবজি, মাছ, চাল বা কৃষক খুঁজুন...'
                                  : 'Search fresh vegetables, fish, grains...',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isBn ? 'মার্কেট' : 'Market',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
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

          // ===== ANNOUNCEMENTS =====
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: 6.0),
              child: GlobalAnnouncementBanner(),
            ),
          ),

          // ========================================================
          // 1.5 LIVE MARKET PRICE TICKER (HORIZONTALLY SCROLLING)
          // ========================================================
          SliverToBoxAdapter(
            child: _buildMarketPriceTickerBar(
              context,
              isBn: isBn,
              isDark: isDark,
              cardBg: cardBg,
              cardBorder: cardBorder,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),

          // ========================================================
          // 2. QUICK STATS & ORDERS (LIVE FIRESTORE DATA STREAM)
          // ========================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: StreamBuilder<QuerySnapshot>(
                stream: uid.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection('orders')
                        .where('buyerId', isEqualTo: uid)
                        .snapshots()
                    : null,
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  final totalOrders = docs.length;
                  final activeOrders = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final status =
                        data['status']?.toString().toLowerCase() ?? '';
                    return status == 'pending' ||
                        status == 'processing' ||
                        status == 'in_transit' ||
                        status == 'shipped';
                  }).length;

                  final String totalOrdersStr = isBn
                      ? BanglaEnglishNumberHelper.toBanglaDigits(totalOrders)
                      : '$totalOrders';
                  final String activeOrdersStr = isBn
                      ? BanglaEnglishNumberHelper.toBanglaDigits(activeOrders)
                      : '$activeOrders';

                  return Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.shopping_bag_outlined,
                          iconColor: _primaryBlue,
                          value: totalOrdersStr,
                          label: isBn ? 'মোট অর্ডার' : 'Total Orders',
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () =>
                              Get.to(() => const FishBuyerOrdersScreen()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.local_shipping_outlined,
                          iconColor: const Color(0xFF10B981),
                          value: activeOrdersStr,
                          label: isBn ? 'চলমান ডেলিভারি' : 'Active Orders',
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () =>
                              Get.to(() => const FishBuyerOrdersScreen()),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          icon: Icons.verified_user_outlined,
                          iconColor: const Color(0xFFF59E0B),
                          value: isBn ? 'সুরক্ষিত' : 'Active',
                          label: isBn ? 'এস্ক্রো সুরক্ষিত' : 'Escrow Guard',
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () =>
                              Get.to(() => const MarketplaceScreen()),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),

          // ========================================================
          // 2.5 ACTIVE ORDER LIVE TRACKER (CONDITIONAL)
          // ========================================================
          SliverToBoxAdapter(
            child: _buildActiveOrderLiveTracker(
              context,
              uid: uid,
              isBn: isBn,
              isDark: isDark,
              cardBg: cardBg,
              cardBorder: cardBorder,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),

          // ========================================================
          // 2.8 BUYER SPENDING INSIGHTS & LOYALTY TRUST SCORE
          // ========================================================
          SliverToBoxAdapter(
            child: _buildSpendingInsightsSection(
              context,
              uid: uid,
              isBn: isBn,
              isDark: isDark,
              cardBg: cardBg,
              cardBorder: cardBorder,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),

          // ========================================================
          // 2.9 AGRICULTURAL WEATHER CONTEXT
          // ========================================================
          SliverToBoxAdapter(
            child: _buildWeatherContextCard(
              context,
              isBn: isBn,
              isDark: isDark,
              cardBg: cardBg,
              cardBorder: cardBorder,
              textPrimary: textPrimary,
              textSecondary: textSecondary,
            ),
          ),

          // ========================================================
          // 3. VIP PASS & REVENUE MONETIZATION BANNER (SSLCOMMERZ)
          // ========================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: _vipService.getSubscriptionStatusStream(uid),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data();
                  final status = data?['status'] as String?;
                  final expiresAt =
                      (data?['expiresAt'] as Timestamp?)?.toDate();
                  final bool isVip = (status == 'approved' ||
                          status == 'active') &&
                      (expiresAt == null || expiresAt.isAfter(DateTime.now()));

                  return _buildVipMonetizationCard(
                    context,
                    isVip: isVip,
                    expiresAt: expiresAt,
                    isBn: isBn,
                    isDark: isDark,
                  );
                },
              ),
            ),
          ),

          // ========================================================
          // 4. EXACT 6 CATEGORIES IN 1 SINGLE CLEAN LINE
          // ========================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn ? 'ক্যাটাগরি' : 'Categories',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const MarketplaceScreen()),
                    child: Text(
                      isBn ? 'সব দেখুন' : 'View All',
                      style: const TextStyle(
                        color: _primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  _buildCompactCategoryItem(
                    context,
                    '🥬',
                    isBn ? 'শাকসবজি' : 'Vegetables',
                    'vegetables',
                    Colors.green,
                    isDark,
                    textPrimary,
                  ),
                  _buildCompactCategoryItem(
                    context,
                    '🍎',
                    isBn ? 'ফলমূল' : 'Fruits',
                    'fruits',
                    Colors.red,
                    isDark,
                    textPrimary,
                  ),
                  _buildCompactCategoryItem(
                    context,
                    '🌾',
                    isBn ? 'শস্য' : 'Grains',
                    'grains',
                    Colors.amber.shade700,
                    isDark,
                    textPrimary,
                  ),
                  _buildCompactCategoryItem(
                    context,
                    '🌶️',
                    isBn ? 'মসলা' : 'Spices',
                    'spices',
                    Colors.deepOrange,
                    isDark,
                    textPrimary,
                  ),
                  _buildCompactCategoryItem(
                    context,
                    '🐟',
                    isBn ? 'মাছ' : 'Fish',
                    'fish',
                    Colors.blue,
                    isDark,
                    textPrimary,
                  ),
                  _buildCompactCategoryItem(
                    context,
                    '🥩',
                    isBn ? 'মাংস/ডিম' : 'Meat',
                    'meat',
                    Colors.brown,
                    isDark,
                    textPrimary,
                  ),
                ],
              ),
            ),
          ),



          // ========================================================
          // 6. EXACT 4 POPULAR PRODUCTS IN 1 ROW WITH ZERO OVERFLOW
          // ========================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn ? 'জনপ্রিয় পণ্য 🔥' : 'Popular Products 🔥',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const MarketplaceScreen()),
                    child: Text(
                      isBn ? 'আরও দেখুন' : 'See More',
                      style: const TextStyle(
                        color: _primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('status', isEqualTo: 'ProductStatus.available')
                  .limit(8)
                  .snapshots(),
              builder: (context, snapshot) {
                final docs = snapshot.data?.docs ?? [];
                if (docs.isNotEmpty) {
                  return SizedBox(
                    height: 215,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final name = data['title'] as String? ??
                            (isBn ? 'কৃষি পণ্য' : 'Agri Produce');
                        final price =
                            (data['price'] as num?)?.toDouble() ?? 0.0;
                        final unit = data['unit'] as String? ??
                            (isBn ? 'কেজি' : 'kg');
                        final farmer = data['sellerName'] as String? ??
                            (isBn ? 'স্থানীয় কৃষক' : 'Local Farmer');
                        final category =
                            data['category'] as String? ?? 'vegetables';
                        final priceStr = isBn
                            ? '৳${BanglaEnglishNumberHelper.toBanglaDigits(price.toStringAsFixed(0))}/$unit'
                            : '৳${price.toStringAsFixed(0)}/$unit';

                        MaterialColor color = Colors.green;
                        String emoji = '🥬';
                        if (category.contains('fruit')) {
                          color = Colors.red;
                          emoji = '🍎';
                        } else if (category.contains('grain')) {
                          color = Colors.amber;
                          emoji = '🌾';
                        } else if (category.contains('spice')) {
                          color = Colors.deepOrange;
                          emoji = '🌶️';
                        } else if (category.contains('fish')) {
                          color = Colors.blue;
                          emoji = '🐟';
                        } else if (category.contains('meat')) {
                          color = Colors.brown;
                          emoji = '🥩';
                        }

                        return _buildProductCard(
                          context,
                          name: name,
                          priceText: priceStr,
                          farmer: farmer,
                          emoji: emoji,
                          color: color,
                          isDark: isDark,
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          isBn: isBn,
                          rawPrice: price,
                          unit: unit,
                          id: doc.id,
                          category: category,
                        );
                      },
                    ),
                  );
                }

                return SizedBox(
                  height: 215,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _buildProductCard(
                        context,
                        name: isBn ? 'তাজা টমেটো' : 'Fresh Tomatoes',
                        priceText: '৳৪০/${isBn ? 'কেজি' : 'kg'}',
                        farmer: isBn ? 'করিম ফার্ম' : 'Karim Farm',
                        emoji: '🍅',
                        color: Colors.red,
                        isDark: isDark,
                        cardBg: cardBg,
                        cardBorder: cardBorder,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        isBn: isBn,
                        rawPrice: 40.0,
                        unit: isBn ? 'কেজি' : 'kg',
                        id: 'tom_101',
                        category: 'vegetables',
                      ),
                      _buildProductCard(
                        context,
                        name: isBn ? 'দেশি পেঁয়াজ' : 'Local Onions',
                        priceText: '৳৭০/${isBn ? 'কেজি' : 'kg'}',
                        farmer: isBn ? 'রহিম এগ্রো' : 'Rahim Agro',
                        emoji: '🧅',
                        color: Colors.purple,
                        isDark: isDark,
                        cardBg: cardBg,
                        cardBorder: cardBorder,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        isBn: isBn,
                        rawPrice: 70.0,
                        unit: isBn ? 'কেজি' : 'kg',
                        id: 'oni_102',
                        category: 'vegetables',
                      ),
                      _buildProductCard(
                        context,
                        name: isBn ? 'মিনিকেট চাল' : 'Miniket Rice',
                        priceText: '৳৬৫/${isBn ? 'কেজি' : 'kg'}',
                        farmer: isBn ? 'কৃষক সমবায়' : 'Farmers Co-op',
                        emoji: '🌾',
                        color: Colors.amber,
                        isDark: isDark,
                        cardBg: cardBg,
                        cardBorder: cardBorder,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        isBn: isBn,
                        rawPrice: 65.0,
                        unit: isBn ? 'কেজি' : 'kg',
                        id: 'rice_103',
                        category: 'grains',
                      ),
                      _buildProductCard(
                        context,
                        name: isBn ? 'গোল আলু' : 'Fresh Potatoes',
                        priceText: '৳২৫/${isBn ? 'কেজি' : 'kg'}',
                        farmer: isBn ? 'রংপুর ফার্ম' : 'Rangpur Farm',
                        emoji: '🥔',
                        color: Colors.brown,
                        isDark: isDark,
                        cardBg: cardBg,
                        cardBorder: cardBorder,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        isBn: isBn,
                        rawPrice: 25.0,
                        unit: isBn ? 'কেজি' : 'kg',
                        id: 'pot_104',
                        category: 'vegetables',
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // ========================================================
          // 7. RECENT ORDERS (LIVE FIREBASE HISTORY & TRACKING)
          // ========================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn ? 'সাম্প্রতিক অর্ডার' : 'Recent Orders',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(() => const FishBuyerOrdersScreen()),
                    child: Text(
                      isBn ? 'হিস্ট্রি দেখুন' : 'Order History',
                      style: const TextStyle(
                        color: _primaryBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<QuerySnapshot>(
                stream: uid.isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection('orders')
                        .where('buyerId', isEqualTo: uid)
                        .orderBy('createdAt', descending: true)
                        .limit(4)
                        .snapshots()
                    : null,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(color: _primaryBlue),
                      ),
                    );
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: cardBorder),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shopping_bag_outlined,
                              color: _primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isBn
                                      ? 'এখনও কোনো অর্ডার নেই'
                                      : 'No orders yet',
                                  style: GoogleFonts.hindSiliguri(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: textPrimary,
                                  ),
                                ),
                                Text(
                                  isBn
                                      ? 'মার্কেটপ্লেস থেকে সাশ্রয়ী মূল্যে সরাসরি কিনুন'
                                      : 'Buy directly from farmers at wholesale prices',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 11,
                                    color: textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                Get.to(() => const MarketplaceScreen()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              isBn ? 'কিনুন' : 'Shop',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final order = OrderModel.fromMap(data, doc.id);

                      String statusText;
                      Color statusColor;
                      switch (order.status.toLowerCase()) {
                        case 'completed':
                        case 'delivered':
                          statusText = isBn ? 'ডেলিভার্ড' : 'Delivered';
                          statusColor = const Color(0xFF10B981);
                          break;
                        case 'in_transit':
                        case 'shipped':
                          statusText = isBn ? 'পথে আছে' : 'In Transit';
                          statusColor = const Color(0xFF3B82F6);
                          break;
                        case 'processing':
                          statusText = isBn ? 'প্রক্রিয়াধীন' : 'Processing';
                          statusColor = const Color(0xFFF59E0B);
                          break;
                        case 'cancelled':
                          statusText = isBn ? 'বাতিল' : 'Cancelled';
                          statusColor = const Color(0xFFEF4444);
                          break;
                        default:
                          statusText = isBn ? 'অপেক্ষমাণ' : 'Pending';
                          statusColor = const Color(0xFF8B5CF6);
                      }

                      final itemsSummary = order.productName.isNotEmpty
                          ? '${order.productName} (${order.quantity.toInt()} ${order.unit})'
                          : (isBn ? 'কৃষি পণ্য' : 'Agri Produce');

                      final totalStr = isBn
                          ? '৳${BanglaEnglishNumberHelper.toBanglaDigits(order.totalAmount.toStringAsFixed(0))}'
                          : '৳${order.totalAmount.toStringAsFixed(0)}';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildRecentOrderCard(
                          context,
                          orderId: order.batchCode.isNotEmpty
                              ? order.batchCode
                              : '#${order.id.substring(0, 6).toUpperCase()}',
                          items: itemsSummary,
                          total: totalStr,
                          status: statusText,
                          statusColor: statusColor,
                          isDark: isDark,
                          cardBg: cardBg,
                          cardBorder: cardBorder,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                          onTap: () {
                            Get.to(() => OrderDetailsScreen(order: order));
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 85)),
        ],
      ),
    );
  }

  Widget _buildVipMonetizationCard(
    BuildContext context, {
    required bool isVip,
    DateTime? expiresAt,
    required bool isBn,
    required bool isDark,
  }) {
    if (isVip) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF78350F), Color(0xFFB45309), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD97706).withValues(alpha: 0.3),
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
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: Colors.amberAccent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn
                        ? '👑 ভিআইপি গোল্ড মেম্বার (সক্রিয়)'
                        : '👑 VIP Gold Member (Active)',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    isBn
                        ? '০% প্ল্যাটফর্ম ফি • প্রিমিয়াম সাপোর্ট • এক্সক্লুসিভ রেট'
                        : '0% Platform Fee • Priority Support • Exclusive Rates',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 10.5,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Get.to(() => const VipSubscriptionPaywallScreen()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isBn ? 'সুবিধা দেখুন' : 'Benefits',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Non-VIP Monetization Pitch (Opens SSLCommerz Paywall)
    return GestureDetector(
      onTap: () => Get.to(() => const VipSubscriptionPaywallScreen()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEA580C), Color(0xFFF97316), Color(0xFFD97706)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEA580C).withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars_rounded,
                  color: Colors.amberAccent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isBn ? '👑 ভিআইপি ট্রেডার্স পাস' : '👑 VIP Traders Pass',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isBn ? 'মাত্র ৳২৯৯' : 'From ৳299',
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.amberAccent,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    isBn
                        ? '০% কমিশনে সরাসরি পাইকারি দামে কিনুন ও অগ্রাধিকার ডেলিভারি'
                        : 'Buy at 0% fee with wholesale rates & priority dispatch',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                isBn ? 'আনলক করুন' : 'Unlock VIP',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEA580C),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap,
      {String? tooltip}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        tooltip: tooltip,
        onPressed: onTap,
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.hindSiliguri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 10.5,
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactCategoryItem(
    BuildContext context,
    String emoji,
    String label,
    String categoryKey,
    Color accentColor,
    bool isDark,
    Color textPrimary,
  ) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () =>
            Get.to(() => MarketplaceScreen(initialCategory: categoryKey)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : accentColor.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context, {
    required String name,
    required String priceText,
    required String farmer,
    required String emoji,
    required MaterialColor color,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required bool isBn,
    required double rawPrice,
    required String unit,
    required String id,
    required String category,
  }) {
    final productMap = {
      'id': id,
      'name': name,
      'price': rawPrice,
      'unit': unit,
      'farmer': farmer,
      'farmerId': 'farmer_$id',
      'location': isBn ? 'উপজেলা কালেকশন হাব' : 'Upazila Collection Hub',
      'rating': 4.8,
      'category': category,
      'qualityGrade':
          isBn ? 'Grade A+ (প্রিমিয়াম)' : 'Grade A+ (Premium)',
    };

    return GestureDetector(
      onTap: () => _openQuickBuy(productMap),
      child: Container(
        width: 142,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area with Emoji
            Container(
              height: 82,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.shade50,
                    isDark
                        ? color.shade900.withValues(alpha: 0.3)
                        : color.shade100,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 38)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    farmer,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 10.5,
                      color: textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          priceText,
                          style: GoogleFonts.hindSiliguri(
                            color: const Color(0xFF10B981),
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openQuickBuy(productMap),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _primaryBlue,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.flash_on,
                                  color: Colors.amberAccent, size: 11),
                              const SizedBox(width: 2),
                              Text(
                                isBn ? 'কিনুন' : 'Buy',
                                style: GoogleFonts.hindSiliguri(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
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

  Widget _buildRecentOrderCard(
    BuildContext context, {
    required String orderId,
    required String items,
    required String total,
    required String status,
    required Color statusColor,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.receipt_long, color: statusColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        orderId,
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          color: textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    total,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
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

  Widget _buildMarketPriceTickerBar(
    BuildContext context, {
    required bool isBn,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return StreamBuilder<List<MarketPriceModel>>(
      stream: _marketPriceService.streamCurrentMarketPrices(),
      builder: (context, snapshot) {
        final prices = snapshot.data ?? <MarketPriceModel>[];
        final displayPrices = prices.isNotEmpty
            ? prices.map((m) {
                String emoji = '🥬';
                if (m.category.contains('fruit')) emoji = '🍎';
                if (m.category.contains('grain')) emoji = '🌾';
                if (m.category.contains('spice')) emoji = '🌶️';
                if (m.category.contains('fish')) emoji = '🐟';
                if (m.category.contains('meat')) emoji = '🥩';
                if (m.productName.contains('টমেটো')) emoji = '🍅';
                if (m.productName.contains('আলু')) emoji = '🥔';
                if (m.productName.contains('পেঁয়াজ') ||
                    m.productName.contains('পেয়াজ')) emoji = '🧅';
                final priceFormatted = isBn
                    ? BanglaEnglishNumberHelper.toBanglaDigits(
                        m.currentPrice.toStringAsFixed(0))
                    : m.currentPrice.toStringAsFixed(0);
                return {
                  'name': m.productName,
                  'price': priceFormatted,
                  'unit': m.unit,
                  'icon': emoji,
                  'up': m.trend == PriceTrend.up,
                  'down': m.trend == PriceTrend.down,
                };
              }).toList()
            : [
                {'name': isBn ? 'টমেটো' : 'Tomato', 'price': isBn ? '৮০' : '80', 'unit': isBn ? 'কেজি' : 'kg', 'icon': '🍅', 'up': false, 'down': false},
                {'name': isBn ? 'আলু' : 'Potato', 'price': isBn ? '৪০' : '40', 'unit': isBn ? 'কেজি' : 'kg', 'icon': '🥔', 'up': true, 'down': false},
                {'name': isBn ? 'পেঁয়াজ' : 'Onion', 'price': isBn ? '৯০' : '90', 'unit': isBn ? 'কেজি' : 'kg', 'icon': '🧅', 'up': false, 'down': false},
                {'name': isBn ? 'কাঁচা মরিচ' : 'Green Chili', 'price': isBn ? '১৫০' : '150', 'unit': isBn ? 'কেজি' : 'kg', 'icon': '🌶️', 'up': true, 'down': false},
                {'name': isBn ? 'মিনিকেট চাল' : 'Rice', 'price': isBn ? '৭০' : '70', 'unit': isBn ? 'কেজি' : 'kg', 'icon': '🌾', 'up': false, 'down': false},
                {'name': isBn ? 'রুই মাছ' : 'Rui Fish', 'price': isBn ? '৩৫০' : '350', 'unit': isBn ? 'কেজি' : 'kg', 'icon': '🐟', 'up': true, 'down': false},
              ];

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.to(() => const MarketPriceAnalysisScreen()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          color: Color(0xFF10B981), size: 14),
                      const SizedBox(width: 3),
                      Text(
                        isBn ? 'বাজারদর' : 'Live Rates',
                        style: GoogleFonts.hindSiliguri(
                          color: const Color(0xFF10B981),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: displayPrices.map((p) {
                      final isUp = p['up'] == true;
                      final isDown = p['down'] == true;
                      return GestureDetector(
                        onTap: () => Get.to(() => const MarketPriceAnalysisScreen()),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${p['icon'] ?? '🥬'}',
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 3),
                              Text(
                                '${p['name']} ৳${p['price']}/${p['unit']}',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isUp
                                      ? const Color(0xFFEF4444)
                                      : isDown
                                          ? const Color(0xFF10B981)
                                          : textPrimary,
                                ),
                              ),
                              Icon(
                                isUp
                                    ? Icons.arrow_drop_up
                                    : isDown
                                        ? Icons.arrow_drop_down
                                        : Icons.remove,
                                color: isUp
                                    ? const Color(0xFFEF4444)
                                    : isDown
                                        ? const Color(0xFF10B981)
                                        : Colors.grey,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveOrderLiveTracker(
    BuildContext context, {
    required String uid,
    required bool isBn,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    if (uid.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('buyerId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        final activeDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = (data['status'] as String? ?? '').toLowerCase();
          return status == 'pending' ||
              status == 'processing' ||
              status == 'in_transit' ||
              status == 'shipped';
        }).toList();

        if (activeDocs.isEmpty) return const SizedBox.shrink();

        final activeDoc = activeDocs.first;
        final data = activeDoc.data() as Map<String, dynamic>;
        final order = OrderModel.fromMap(data, activeDoc.id);

        int currentStep = 1;
        String stepTitle = isBn ? 'অর্ডার গ্রহণ করা হয়েছে' : 'Order Placed';
        final st = order.status.toLowerCase();
        if (st == 'processing') {
          currentStep = 2;
          stepTitle =
              isBn ? 'প্যাকেজিং ও প্রসেসিং চলছে' : 'Packaging & Processing';
        } else if (st == 'in_transit' || st == 'shipped') {
          currentStep = 3;
          stepTitle = isBn ? 'ডেলিভারির পথে রয়েছে' : 'Out for Delivery';
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3B82F6)
                    .withValues(alpha: isDark ? 0.15 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6)
                              .withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.local_shipping_rounded,
                            color: Color(0xFF3B82F6), size: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isBn
                            ? 'চলমান ডেলিভারি লাইভ ট্র্যাকার'
                            : 'Live Shipment Tracker',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () =>
                        Get.to(() => OrderDetailsScreen(order: order)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isBn ? 'বিস্তারিত' : 'Details',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: _primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.productName.isNotEmpty
                          ? '${order.productName} (${order.quantity.toInt()} ${order.unit})'
                          : (isBn ? 'কৃষি অর্ডার' : 'Agri Order'),
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    isBn
                        ? '৳${BanglaEnglishNumberHelper.toBanglaDigits(order.totalAmount.toStringAsFixed(0))}'
                        : '৳${order.totalAmount.toStringAsFixed(0)}',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                stepTitle,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 11,
                  color: const Color(0xFF3B82F6),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              // 4-Step Progress Bar
              Row(
                children: [
                  _buildProgressStep(
                      1, currentStep, isBn ? 'গৃহীত' : 'Placed'),
                  _buildProgressConnector(1 < currentStep),
                  _buildProgressStep(
                      2, currentStep, isBn ? 'প্রসেসিং' : 'Packing'),
                  _buildProgressConnector(2 < currentStep),
                  _buildProgressStep(
                      3, currentStep, isBn ? 'পথে' : 'Transit'),
                  _buildProgressConnector(3 < currentStep),
                  _buildProgressStep(
                      4, currentStep, isBn ? 'ডেলিভার্ড' : 'Delivered'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressStep(int stepIndex, int currentStep, String label) {
    final bool isDone = stepIndex <= currentStep;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color:
                  isDone ? const Color(0xFF3B82F6) : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: GoogleFonts.hindSiliguri(
                fontSize: 9.5,
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                color: isDone ? const Color(0xFF3B82F6) : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressConnector(bool isDone) {
    return Container(
      width: 18,
      height: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: isDone ? const Color(0xFF3B82F6) : Colors.grey.shade300,
    );
  }

  Widget _buildSpendingInsightsSection(
    BuildContext context, {
    required String uid,
    required bool isBn,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    if (uid.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: StreamBuilder<BuyerSpendingInsights>(
        stream: _analyticsService.getSpendingInsightsStream(uid),
        builder: (context, snapshot) {
          final insights = snapshot.data ?? BuyerSpendingInsights.empty();

          final monthlySpendStr = isBn
              ? '৳${BanglaEnglishNumberHelper.toBanglaDigits(insights.monthlySpend.toStringAsFixed(0))}'
              : '৳${insights.monthlySpend.toStringAsFixed(0)}';

          final scoreStr = isBn
              ? '${BanglaEnglishNumberHelper.toBanglaDigits(insights.trustScore)}/১০০'
              : '${insights.trustScore}/100';

          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFF1F5F9), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.insights_rounded,
                              color: Color(0xFF8B5CF6), size: 16),
                          const SizedBox(width: 5),
                          Text(
                            isBn ? 'চলতি মাসে খরচ' : 'Monthly Spend',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              color: textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        monthlySpendStr,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        isBn
                            ? 'স্মার্ট হোলসেল সঞ্চয়'
                            : 'Smart Wholesale Savings',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 9.5,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: cardBorder,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: Color(0xFFF59E0B), size: 16),
                          const SizedBox(width: 5),
                          Text(
                            isBn ? 'বায়ার ট্রাস্ট স্কোর' : 'Trust Score',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              color: textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        scoreStr,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      Text(
                        isBn
                            ? 'টিয়ার: ${insights.trustTier} মেম্বার'
                            : 'Tier: ${insights.trustTier} Member',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 9.5,
                          color: const Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeatherContextCard(
    BuildContext context, {
    required bool isBn,
    required bool isDark,
    required Color cardBg,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final weather = _currentWeather;
    final location = weather != null
        ? weather.getLocationDisplayName(isBn)
        : (isBn ? 'বাংলাদেশ' : 'Bangladesh');
    final tempStr = weather != null
        ? '${isBn ? BanglaEnglishNumberHelper.toBanglaDigits(weather.temperature.toStringAsFixed(0)) : weather.temperature.toStringAsFixed(0)}°C'
        : '28°C';
    final condition = weather != null
        ? weather.getConditionText(isBn)
        : (isBn ? 'অনুকূল আবহাওয়া' : 'Favorable Weather');
    final advice = weather != null
        ? weather.getAgriAdviceText(isBn, isBuyer: true)
        : (isBn
            ? 'তাজা শাকসবজি ও ফল সংগ্রহের চমৎকার দিন।'
            : 'Favorable day for fresh produce sourcing.');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wb_sunny_outlined,
                color: Color(0xFF0284C7), size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$location: $tempStr ($condition)',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  advice,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 10.5,
                    color: textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
