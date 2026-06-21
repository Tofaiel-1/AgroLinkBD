import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider;
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/service_provider_providers.dart';
import 'package:agrolinkbd/core/models/service_provider_models.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_products_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_orders_screen.dart';

/// Service Provider Dashboard - Shop-Centric Design
/// Redesigned to focus on product selling: সার, কীটনাশক, ট্র্যাক্টর, বীজ, যন্ত্রপাতি
class ServiceProviderDashboard extends ConsumerStatefulWidget {
  const ServiceProviderDashboard({super.key});

  @override
  ConsumerState<ServiceProviderDashboard> createState() => _ServiceProviderDashboardState();
}

class _ServiceProviderDashboardState extends ConsumerState<ServiceProviderDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(serviceProductProvider);
    final orders = ref.watch(serviceOrderProvider);
    final pendingCount = ref.watch(pendingOrderCountProvider);
    final lowStockProducts = ref.watch(lowStockProductsProvider);
    final totalRevenue = ref.watch(totalRevenueProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // ============================================
            // SHOP HEADER
            // ============================================
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: const Color(0xFF4527A0),
              actions: [
                // Pending Orders Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.receipt_long_rounded, color: Colors.white),
                      onPressed: () {
                        Get.to(() => const ServiceProviderOrdersScreen());
                      },
                    ),
                    if (pendingCount > 0)
                      Positioned(
                        right: 6,
                        top: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$pendingCount',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') _showLogoutDialog(context);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'logout', child: Row(
                      children: [Icon(Icons.logout, size: 18), SizedBox(width: 8), Text('লগ আউট')],
                    )),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.more_vert, color: Colors.white),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4527A0), Color(0xFF7B1FA2), Color(0xFF9C27B0)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative circles
                      Positioned(
                        right: -40,
                        top: -40,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -30,
                        bottom: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      // Shop Info
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'আমার কৃষি দোকান',
                                            style: GoogleFonts.poppins(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.verified, color: Colors.amber, size: 18),
                                        ],
                                      ),
                                      Text(
                                        '🟢 অনলাইন • সার, বীজ ও কীটনাশক বিক্রেতা',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Quick Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildHeaderStat('মোট পণ্য', '${products.length}'),
                                _buildHeaderStat('আয়', '৳ ${totalRevenue.toStringAsFixed(0)}'),
                                _buildHeaderStat('রেটিং', '⭐ ৪.৭'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ============================================
            // PRODUCT CATEGORIES
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'পণ্যের ক্যাটাগরি',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 95,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: ServiceProductCategory.values.map((cat) {
                          final count = products.where((p) => p.category == cat).length;
                          return _buildCategoryCard(cat, count);
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ============================================
            // PENDING ORDERS ALERT
            // ============================================
            if (pendingCount > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: GestureDetector(
                    onTap: () => Get.to(() => const ServiceProviderOrdersScreen()),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade600, Colors.deepOrange.shade400],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.notifications_active_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$pendingCount টি নতুন অর্ডার!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'কৃষকরা আপনার পণ্যের জন্য অপেক্ষা করছেন',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // ============================================
            // QUICK STATS GRID
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.55,
                  children: [
                    _buildStatCard(
                      icon: Icons.shopping_bag_rounded,
                      label: 'আজকের অর্ডার',
                      value: '$pendingCount',
                      color: const Color(0xFF4527A0),
                    ),
                    _buildStatCard(
                      icon: Icons.inventory_2_rounded,
                      label: 'মোট পণ্য',
                      value: '${products.length}',
                      color: const Color(0xFF1976D2),
                    ),
                    _buildStatCard(
                      icon: Icons.trending_up_rounded,
                      label: 'বিক্রি সম্পন্ন',
                      value: '${orders.where((o) => o.status == ServiceOrderStatus.delivered).length}',
                      color: const Color(0xFF2E7D32),
                    ),
                    _buildStatCard(
                      icon: Icons.warning_amber_rounded,
                      label: 'স্টক কম',
                      value: '${lowStockProducts.length}',
                      color: lowStockProducts.isEmpty ? Colors.grey : Colors.red,
                    ),
                  ],
                ),
              ),
            ),

            // ============================================
            // LOW STOCK ALERTS
            // ============================================
            if (lowStockProducts.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red.shade600, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'স্টক কম আছে!',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...lowStockProducts.map((p) => _buildLowStockItem(p)),
                    ],
                  ),
                ),
              ),

            // ============================================
            // RECENT ORDERS
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'সাম্প্রতিক অর্ডার',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const ServiceProviderOrdersScreen()),
                      child: Text('সব দেখুন', style: GoogleFonts.poppins(color: const Color(0xFF4527A0))),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: orders.take(3).map((order) => _buildOrderCard(order)).toList(),
                ),
              ),
            ),

            // ============================================
            // TOP PRODUCTS
            // ============================================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'জনপ্রিয় পণ্য',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => const ServiceProviderProductsScreen()),
                      child: Text('সব পণ্য', style: GoogleFonts.poppins(color: const Color(0xFF4527A0))),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: (products.toList()..sort((a, b) => b.totalSold.compareTo(a.totalSold)))
                      .take(5)
                      .map((p) => _buildProductPreviewCard(p))
                      .toList(),
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
    );
  }

  // ===== HELPER WIDGETS =====

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildCategoryCard(ServiceProductCategory category, int count) {
    final colors = {
      ServiceProductCategory.fertilizer: const Color(0xFF2E7D32),
      ServiceProductCategory.pesticide: const Color(0xFFE65100),
      ServiceProductCategory.tractor: const Color(0xFF1565C0),
      ServiceProductCategory.seed: const Color(0xFF558B2F),
      ServiceProductCategory.equipment: const Color(0xFF6A1B9A),
      ServiceProductCategory.advisory: const Color(0xFF00838F),
    };
    final icons = {
      ServiceProductCategory.fertilizer: Icons.science_rounded,
      ServiceProductCategory.pesticide: Icons.pest_control_rounded,
      ServiceProductCategory.tractor: Icons.agriculture_rounded,
      ServiceProductCategory.seed: Icons.grass_rounded,
      ServiceProductCategory.equipment: Icons.handyman_rounded,
      ServiceProductCategory.advisory: Icons.support_agent_rounded,
    };

    return GestureDetector(
      onTap: () {
        ref.read(serviceProductCategoryFilterProvider.notifier).state = category;
        Get.to(() => const ServiceProviderProductsScreen());
      },
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors[category]!.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors[category]!.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icons[category], color: colors[category], size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              category.bengaliName,
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            Text(
              '$count পণ্য',
              style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(ServiceProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          Icon(
            product.isOutOfStock ? Icons.error_rounded : Icons.warning_rounded,
            color: product.isOutOfStock ? Colors.red : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${product.name} — ${product.isOutOfStock ? "স্টক শেষ!" : "মাত্র ${product.stockQuantity}টি বাকি"}',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 30)),
            child: Text('রিস্টক', style: GoogleFonts.poppins(fontSize: 11, color: Colors.red.shade700, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(ServiceOrder order) {
    final statusColors = {
      ServiceOrderStatus.pending: Colors.orange,
      ServiceOrderStatus.accepted: Colors.blue,
      ServiceOrderStatus.processing: Colors.indigo,
      ServiceOrderStatus.delivered: Colors.green,
      ServiceOrderStatus.cancelled: Colors.red,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Container(height: 3, color: statusColors[order.status]),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.farmerName,
                        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColors[order.status]!.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          order.status.bengaliName,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: statusColors[order.status],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    order.items.map((i) => '${i.productName} x${i.quantity}').join(', '),
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '৳ ${order.totalAmount.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                      ),
                      if (order.status == ServiceOrderStatus.pending)
                        Row(
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                ref.read(serviceOrderProvider.notifier).cancelOrder(order.id);
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                side: BorderSide(color: Colors.red.shade300),
                                minimumSize: const Size(0, 30),
                              ),
                              child: Text('বাতিল', style: GoogleFonts.poppins(fontSize: 11, color: Colors.red)),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(serviceOrderProvider.notifier).updateOrderStatus(order.id, ServiceOrderStatus.accepted);
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                backgroundColor: const Color(0xFF4527A0),
                                minimumSize: const Size(0, 30),
                              ),
                              child: Text('গ্রহণ', style: GoogleFonts.poppins(fontSize: 11, color: Colors.white)),
                            ),
                          ],
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

  Widget _buildProductPreviewCard(ServiceProduct product) {
    return Container(
      width: 155,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image Placeholder
          Container(
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF4527A0).withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Center(
              child: Text(
                product.category.icon,
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (product.hasDiscount)
                      Text(
                        '৳${product.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    if (product.hasDiscount) const SizedBox(width: 4),
                    Text(
                      '৳${product.effectivePrice.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.amber.shade600),
                    const SizedBox(width: 2),
                    Text('${product.rating}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade600)),
                    const SizedBox(width: 6),
                    Text('${product.totalSold} বিক্রি', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey.shade500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('লগ আউট', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text('আপনি কি নিশ্চিত যে আপনি লগ আউট করতে চান?', style: GoogleFonts.poppins(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('বাতিল'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final userProvider = context.read<UserProvider>();
                await userProvider.signOut();
              } catch (e) {
                Get.snackbar('Error', 'লগ আউট করতে সমস্যা হয়েছে: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('লগ আউট', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
