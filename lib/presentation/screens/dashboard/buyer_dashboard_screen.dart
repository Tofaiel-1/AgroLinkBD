import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/profile/profile_screen.dart';
import 'package:agrolinkbd/presentation/widgets/global_announcement_banner.dart';

import 'package:agrolinkbd/core/services/transaction_service.dart';

class BuyerDashboardScreen extends StatefulWidget {
  const BuyerDashboardScreen({super.key});

  @override
  State<BuyerDashboardScreen> createState() => _BuyerDashboardScreenState();
}

class _BuyerDashboardScreenState extends State<BuyerDashboardScreen> {
  static const Color _primaryBlue = Color(0xFF1976D2);
  static const Color _darkBlue = Color(0xFF0D47A1);

  final TransactionService _transactionService = TransactionService();
  double _balance = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    final userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());
    String uid = userController.userId.isNotEmpty ? userController.userId : 'buyer_demo';
    final balance = await _transactionService.getWalletBalance(uid);
    if (mounted) {
      setState(() {
        _balance = balance;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ===== HEADER =====
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20,
                right: 20,
                bottom: 28,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_darkBlue, _primaryBlue, Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Welcome + Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'আসসালামু আলাইকুম 👋',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userController.userName.isEmpty
                                  ? 'ক্রেতা'
                                  : userController.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildHeaderIcon(Icons.notifications_none_rounded, () {}),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => Get.to(() => const ProfileScreen()),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white38, width: 2),
                              ),
                              child: const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.person, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'পণ্য খুঁজুন (যেমন: চাল, সবজি)...',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                        border: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.white.withOpacity(0.6)),
                        suffixIcon: Icon(Icons.tune_rounded, color: Colors.white.withOpacity(0.6)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
              padding: EdgeInsets.only(top: 8.0),
              child: GlobalAnnouncementBanner(),
            ),
          ),

          // ===== QUICK STATS =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.shopping_bag_outlined,
                      iconColor: _primaryBlue,
                      value: '১৫',
                      label: 'মোট অর্ডার',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      iconColor: Colors.green,
                      value: '৳${_balance.toStringAsFixed(0)}',
                      label: 'ওয়ালেট ব্যালেন্স',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.favorite_border,
                      iconColor: Colors.red,
                      value: '৮',
                      label: 'প্রিয় কৃষক',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== CATEGORIES =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ক্যাটাগরি',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const MarketplaceScreen()),
                    child: const Text('সব দেখুন', style: TextStyle(color: _primaryBlue)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryItem(context, '🥬', 'সবজি', Colors.green, isDark),
                  _buildCategoryItem(context, '🍎', 'ফলমূল', Colors.red, isDark),
                  _buildCategoryItem(context, '🌾', 'চাল ও ডাল', Colors.amber, isDark),
                  _buildCategoryItem(context, '🌶️', 'মসলা', Colors.deepOrange, isDark),
                  _buildCategoryItem(context, '🐟', 'মাছ', Colors.blue, isDark),
                  _buildCategoryItem(context, '🥩', 'মাংস', Colors.brown, isDark),
                  _buildCategoryItem(context, '🥚', 'দুধ-ডিম', Colors.orange, isDark),
                ],
              ),
            ),
          ),

          // ===== FEATURED PRODUCTS =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'জনপ্রিয় পণ্য 🔥',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.to(() => const MarketplaceScreen()),
                    child: const Text('আরও দেখুন', style: TextStyle(color: _primaryBlue)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 230,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildProductCard(context, 'তাজা টমেটো', '৳৪০/কেজি', 'করিম ফার্ম', '🍅', Colors.red, isDark),
                  _buildProductCard(context, 'দেশি পেঁয়াজ', '৳৭০/কেজি', 'রহিম এগ্রো', '🧅', Colors.purple, isDark),
                  _buildProductCard(context, 'মিনিকেট চাল', '৳৬৫/কেজি', 'কৃষক সমবায়', '🌾', Colors.amber, isDark),
                  _buildProductCard(context, 'আলু', '৳২৫/কেজি', 'রংপুর ফার্ম', '🥔', Colors.brown, isDark),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // ===== RECENT ORDERS =====
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Text(
                'সাম্প্রতিক অর্ডার',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildRecentOrderCard(
                    context,
                    orderId: '#ORD-১০১',
                    items: 'টমেটো ৫০কেজি, পেঁয়াজ ২৫কেজি',
                    total: '৳২,৫২০',
                    status: 'ডেলিভারি প্রক্রিয়ায়',
                    statusColor: Colors.blue,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildRecentOrderCard(
                    context,
                    orderId: '#ORD-১০০',
                    items: 'আলু ৭৫কেজি',
                    total: '৳১,৮৭৫',
                    status: 'ডেলিভার হয়েছে ✓',
                    statusColor: Colors.green,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  // ===== HELPER WIDGETS =====

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white54 : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String emoji,
    String label,
    MaterialColor color,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => Get.to(() => const MarketplaceScreen()),
      child: Container(
        width: 76,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: isDark ? color.shade900.withOpacity(0.3) : color.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? color.shade700.withOpacity(0.3) : color.shade100,
                ),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey.shade700,
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

  Widget _buildProductCard(
    BuildContext context,
    String name,
    String price,
    String farmer,
    String emoji,
    MaterialColor color,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => Get.to(() => const MarketplaceScreen()),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.shade50,
                    isDark ? color.shade900.withOpacity(0.3) : color.shade100,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 48)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    farmer,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _primaryBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16),
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
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade100,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.receipt_long, color: statusColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      orderId,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(isDark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  items,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  total,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
