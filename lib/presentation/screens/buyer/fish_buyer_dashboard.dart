import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/utils/number_converter.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/fish_marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/shopping_cart_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/buyer/auction/fish_buyer_auction_list_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/buyer/rfq/post_fish_rfq_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/buyer/rfq/buyer_rfq_responses_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/buyer/contracts/buyer_preharvest_contracts_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/transport/fish_transport_screen.dart';
import 'package:agrolinkbd/presentation/screens/subscription/vip_subscription_paywall_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/fish_price_prediction_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/fish_buyer_qc_inspection_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/fish_cold_chain_directory_screen.dart';

/// Fish Buyer Dashboard - Ultra Pro Edition
/// Dedicated dashboard for commercial fish buyers, restaurants, and wholesalers.
class FishBuyerDashboard extends StatefulWidget {
  const FishBuyerDashboard({super.key});

  @override
  State<FishBuyerDashboard> createState() => _FishBuyerDashboardState();
}

class _FishBuyerDashboardState extends State<FishBuyerDashboard>
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = LanguageProvider.isBn(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? userProvider.currentUser?.id ?? '';
    final userName = userProvider.currentUser?.name ?? '';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ============================================
            // HEADER - Fish Buyer Greeting (Glassmorphism)
            // ============================================
            SliverAppBar(
              floating: false,
              pinned: true,
              toolbarHeight: 65,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF0277BD),
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isBn
                        ? (userName.isNotEmpty ? 'স্বাগতম, $userName 🐟' : 'স্বাগতম, মৎস্য ক্রেতা! 🐟')
                        : (userName.isNotEmpty ? 'Welcome, $userName 🐟' : 'Welcome, Fish Buyer! 🐟'),
                    style: isBn
                        ? GoogleFonts.hindSiliguri(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )
                        : GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                  ),
                  Text(
                    isBn
                        ? 'তাজা মাছের পাইকারি ও সরাসরি সমাহার'
                        : 'Fresh Fish Wholesale & Direct Sourcing',
                    style: isBn
                        ? GoogleFonts.hindSiliguri(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.88),
                          )
                        : GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                  ),
                ],
              ),
              actions: [
                // Cart Icon with live reactive badge
                Consumer<CartProvider>(
                  builder: (context, cartProvider, child) {
                    final itemCount = cartProvider.itemCount;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                          tooltip: isBn ? 'শপিং কার্ট' : 'Shopping Cart',
                          onPressed: () {
                            Get.to(() => const ShoppingCartScreen());
                          },
                        ),
                        if (itemCount > 0)
                          Positioned(
                            right: 6,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.amberAccent,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                BanglaEnglishNumberHelper.format(itemCount, isBn),
                                style: GoogleFonts.poppins(
                                  color: Colors.black87,
                                  fontSize: 10,
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
              ],
            ),

            // ============================================
            // BODY CONTENT
            // ============================================
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ============================================
                    // STATS - 4 Square Cards in 1 Row (Active Orders, Cart, Bidding, Fresh Stock)
                    // ============================================
                    StreamBuilder<List<OrderModel>>(
                      stream: currentUserId.isNotEmpty
                          ? OrderService().getOrdersByBuyerId(currentUserId)
                          : Stream.value([]),
                      builder: (context, orderSnapshot) {
                        final orders = orderSnapshot.data ?? [];
                        final activeOrdersCount = orders.where((o) {
                          final status = o.status.toLowerCase().trim();
                          return status != 'delivered' && status != 'cancelled';
                        }).length;

                        return Consumer<CartProvider>(
                          builder: (context, cartProvider, _) {
                            final cartItemCount = cartProvider.itemCount;

                            return Row(
                              children: [
                                // 1. Active Orders Card
                                Expanded(
                                  child: _buildSquareStatCard(
                                    isDark: isDark,
                                    isBn: isBn,
                                    icon: Icons.local_shipping_outlined,
                                    color: const Color(0xFF0277BD),
                                    label: isBn ? 'সক্রিয় অর্ডার' : 'Active Orders',
                                    value: BanglaEnglishNumberHelper.format(activeOrdersCount, isBn),
                                    onTap: () => Get.to(() => const FishBuyerOrdersScreen()),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // 2. Shopping Cart Card
                                Expanded(
                                  child: _buildSquareStatCard(
                                    isDark: isDark,
                                    isBn: isBn,
                                    icon: Icons.shopping_cart_outlined,
                                    color: const Color(0xFF00796B),
                                    label: isBn ? 'শপিং কার্ট' : 'Shopping Cart',
                                    value: BanglaEnglishNumberHelper.format(cartItemCount, isBn),
                                    onTap: () => Get.to(() => const ShoppingCartScreen()),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // 3. Live Auctions Card
                                Expanded(
                                  child: _buildSquareStatCard(
                                    isDark: isDark,
                                    isBn: isBn,
                                    icon: Icons.gavel_outlined,
                                    color: const Color(0xFFE65100),
                                    label: isBn ? 'লাইভ নিলাম' : 'Live Auctions',
                                    value: isBn ? 'বিডিং' : 'Bidding',
                                    onTap: () => Get.to(() => const FishBuyerAuctionListScreen()),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // 4. Fish Market Card
                                Expanded(
                                  child: _buildSquareStatCard(
                                    isDark: isDark,
                                    isBn: isBn,
                                    icon: Icons.storefront_outlined,
                                    color: const Color(0xFF1565C0),
                                    label: isBn ? 'মাছের বাজার' : 'Fish Bazaar',
                                    value: isBn ? 'তাজা স্টক' : 'Fresh Stock',
                                    onTap: () => Get.to(() => const FishMarketplaceScreen()),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    // ============================================
                    // WHOLESALE & LIVE BIDDING PROCUREMENT HUB
                    // ============================================
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF01579B), Color(0xFF0277BD), Color(0xFF0288D1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF01579B).withValues(alpha: 0.3),
                            blurRadius: 10,
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
                              Row(
                                children: [
                                  const Icon(Icons.gavel, color: Colors.amberAccent, size: 20),
                                  const SizedBox(width: 6),
                                  Text(
                                    isBn ? 'পাইকারি মাছ নিলাম ও প্রকিউরমেন্ট' : 'Wholesale Auction & Procurement',
                                    style: isBn
                                        ? GoogleFonts.hindSiliguri(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          )
                                        : GoogleFonts.poppins(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amberAccent.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.amberAccent),
                                ),
                                child: Text(
                                  'PRO',
                                  style: GoogleFonts.poppins(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amberAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              // 1. Live Auctions
                              Expanded(
                                child: InkWell(
                                  onTap: () => Get.to(() => const FishBuyerAuctionListScreen()),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.touch_app, color: Colors.amberAccent, size: 20),
                                        const SizedBox(height: 2),
                                        Text(
                                          isBn ? 'লাইভ নিলাম' : 'Live Auctions',
                                          style: isBn
                                              ? GoogleFonts.hindSiliguri(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.5,
                                                )
                                              : GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.5,
                                                ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          isBn ? 'লট বিডিং' : 'Lot Bidding',
                                          style: isBn
                                              ? GoogleFonts.hindSiliguri(
                                                  color: Colors.white70,
                                                  fontSize: 10,
                                                )
                                              : GoogleFonts.poppins(
                                                  color: Colors.white70,
                                                  fontSize: 9.5,
                                                ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // 2. Post RFQ
                              Expanded(
                                child: InkWell(
                                  onTap: () => Get.to(() => const PostFishRfqScreen()),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.campaign, color: Colors.cyanAccent, size: 20),
                                        const SizedBox(height: 2),
                                        Text(
                                          isBn ? 'চাহিদাপত্র' : 'Post RFQ',
                                          style: isBn
                                              ? GoogleFonts.hindSiliguri(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.5,
                                                )
                                              : GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.5,
                                                ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          isBn ? 'বাল্ক কোটেশন' : 'Bulk Quotes',
                                          style: isBn
                                              ? GoogleFonts.hindSiliguri(
                                                  color: Colors.white70,
                                                  fontSize: 10,
                                                )
                                              : GoogleFonts.poppins(
                                                  color: Colors.white70,
                                                  fontSize: 9.5,
                                                ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),

                              // 3. Pre-Harvest Futures
                              Expanded(
                                child: InkWell(
                                  onTap: () => Get.to(() => const BuyerPreharvestContractsScreen()),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Column(
                                      children: [
                                        const Icon(Icons.lock_clock, color: Colors.greenAccent, size: 20),
                                        const SizedBox(height: 2),
                                        Text(
                                          isBn ? 'আগাম বুকিং' : 'Pre-Booking',
                                          style: isBn
                                              ? GoogleFonts.hindSiliguri(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13.5,
                                                )
                                              : GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12.5,
                                                ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          isBn ? 'নিশ্চিত মাছ' : 'Guaranteed',
                                          style: isBn
                                              ? GoogleFonts.hindSiliguri(
                                                  color: Colors.white70,
                                                  fontSize: 10,
                                                )
                                              : GoogleFonts.poppins(
                                                  color: Colors.white70,
                                                  fontSize: 9.5,
                                                ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Get.to(() => const BuyerRfqResponsesScreen()),
                                  icon: const Icon(Icons.list_alt, size: 15, color: Colors.white),
                                  label: Text(
                                    isBn ? 'আমার চাহিদাপত্র ও দর' : 'My RFQs & Quotes',
                                    style: isBn
                                        ? GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)
                                        : GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white38),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Get.to(() => const FishTransportScreen()),
                                  icon: const Icon(Icons.local_shipping, size: 15, color: Colors.white),
                                  label: Text(
                                    isBn ? 'অক্সিজেন ভ্যান ট্র্যাক' : 'Track Oxygen Van',
                                    style: isBn
                                        ? GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)
                                        : GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white38),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ============================================
                    // VIP PRO INTELLIGENCE & SATELLITE BAR
                    // ============================================
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2000) : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFFB300).withValues(alpha: isDark ? 0.2 : 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.workspace_premium, color: Color(0xFFE65100), size: 26),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      isBn ? 'ভিআইপি বায়ার হাব 👑' : 'VIP Buyer Hub 👑',
                                      style: isBn
                                          ? GoogleFonts.hindSiliguri(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: const Color(0xFFE65100),
                                            )
                                          : GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: const Color(0xFFE65100),
                                            ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        isBn ? 'দর প্রেডিকশন ও কিউসি' : 'Price Forecast & QC',
                                        style: isBn
                                            ? GoogleFonts.hindSiliguri(fontSize: 11.5, color: isDark ? Colors.amber.shade200 : Colors.brown)
                                            : GoogleFonts.poppins(fontSize: 10.5, color: isDark ? Colors.amber.shade200 : Colors.brown),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Get.to(() => const VipSubscriptionPaywallScreen()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE65100),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'VIP PASS',
                                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Get.to(() => const FishPricePredictionScreen()),
                                  icon: const Icon(Icons.trending_up, size: 17, color: Color(0xFFE65100)),
                                  label: Text(
                                    isBn ? 'এআই দর' : 'AI Price',
                                    style: isBn
                                        ? GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFE65100))
                                        : GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFE65100)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFFFB300), width: 1.2),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Get.to(() => const FishBuyerQcInspectionScreen()),
                                  icon: const Icon(Icons.verified, size: 17, color: Color(0xFFE65100)),
                                  label: Text(
                                    isBn ? 'কিউসি গ্রেড' : 'QC Grade',
                                    style: isBn
                                        ? GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFE65100))
                                        : GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFE65100)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFFFB300), width: 1.2),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Get.to(() => const FishColdChainDirectoryScreen()),
                                  icon: const Icon(Icons.ac_unit, size: 17, color: Color(0xFFE65100)),
                                  label: Text(
                                    isBn ? 'বরফকল' : 'Ice Mill',
                                    style: isBn
                                        ? GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFFE65100))
                                        : GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFE65100)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFFFB300), width: 1.2),
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ============================================
                    // LIVE MARKET TRENDS
                    // ============================================
                    _buildSectionHeader(
                      isBn ? 'লাইভ মার্কেট ট্রেন্ড' : 'Live Market Trends',
                      isDark,
                      isBn: isBn,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 64,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildTrendCard(
                            isBn ? 'ইলিশ' : 'Hilsa',
                            isBn ? '৳১২০০/কেজি' : '৳1200/kg',
                            '+5%',
                            true,
                            isDark,
                            isBn: isBn,
                          ),
                          _buildTrendCard(
                            isBn ? 'রুই' : 'Rui / Rohu',
                            isBn ? '৳৩৫০/কেজি' : '৳350/kg',
                            '-2%',
                            false,
                            isDark,
                            isBn: isBn,
                          ),
                          _buildTrendCard(
                            isBn ? 'বাগদা চিংড়ি' : 'Tiger Shrimp',
                            isBn ? '৳৮০০/কেজি' : '৳800/kg',
                            '+1%',
                            true,
                            isDark,
                            isBn: isBn,
                          ),
                          _buildTrendCard(
                            isBn ? 'কাতলা' : 'Catla',
                            isBn ? '৳৪০০/কেজি' : '৳400/kg',
                            '0%',
                            true,
                            isDark,
                            isBn: isBn,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ============================================
                    // AI SMART RECOMMENDATIONS
                    // ============================================
                    _buildSectionHeader(
                      isBn ? 'আপনার জন্য প্রস্তাবিত (AI)' : 'Recommended For You (AI)',
                      isDark,
                      icon: Icons.auto_awesome,
                      isBn: isBn,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 96,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _buildAICategoryCard(
                            isBn ? 'দেশি রুই (তাজা)' : 'Desi Rui (Fresh)',
                            isBn ? 'খামার থেকে সরাসরি' : 'Direct From Farm',
                            Icons.set_meal,
                            isDark,
                            isBn: isBn,
                          ),
                          _buildAICategoryCard(
                            isBn ? 'পদ্মার ইলিশ' : 'Padma Hilsa',
                            isBn ? 'প্রিমিয়াম কোয়ালিটি' : 'Premium Quality',
                            Icons.water,
                            isDark,
                            isBn: isBn,
                          ),
                          _buildAICategoryCard(
                            isBn ? 'গলদা চিংড়ি' : 'Giant Prawn',
                            isBn ? 'বড় সাইজ' : 'Large Size',
                            Icons.waves,
                            isDark,
                            isBn: isBn,
                          ),
                          _buildAICategoryCard(
                            isBn ? 'পাঙ্গাস (গ্রেড-১)' : 'Pangas (Grade-1)',
                            isBn ? 'পাইকারি লট' : 'Wholesale Lot',
                            Icons.bubble_chart,
                            isDark,
                            isBn: isBn,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareStatCard({
    required bool isDark,
    required bool isBn,
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 0.95,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDark ? 0.25 : 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: color.withValues(alpha: isDark ? 0.3 : 0.15),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.22 : 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: isBn
                    ? GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.1,
                      )
                    : GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.1,
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: isBn
                    ? GoogleFonts.hindSiliguri(
                        fontSize: 10.5,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      )
                    : GoogleFonts.poppins(
                        fontSize: 10,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, {IconData? icon, required bool isBn}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: const Color(0xFFFBC02D), size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: isBn
              ? GoogleFonts.hindSiliguri(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                )
              : GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
        ),
      ],
    );
  }

  Widget _buildTrendCard(
    String name,
    String price,
    String change,
    bool isUp,
    bool isDark, {
    required bool isBn,
  }) {
    final color = isUp ? Colors.green : Colors.red;
    return GestureDetector(
      onTap: () => Get.to(() => const FishMarketplaceScreen()),
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: isBn
                  ? GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: isDark ? Colors.white : Colors.black87,
                    )
                  : GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: isBn
                      ? GoogleFonts.hindSiliguri(
                          fontSize: 12,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        )
                      : GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                ),
                Row(
                  children: [
                    Icon(isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down, color: color, size: 16),
                    Text(
                      change,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAICategoryCard(
    String name,
    String subtitle,
    IconData icon,
    bool isDark, {
    required bool isBn,
  }) {
    return GestureDetector(
      onTap: () => Get.to(() => const FishMarketplaceScreen()),
      child: Container(
        width: 112,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0277BD).withValues(alpha: isDark ? 0.2 : 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF0277BD), size: 20),
            ),
            const SizedBox(height: 4),
            Text(
              name,
              style: isBn
                  ? GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.15,
                    )
                  : GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                      height: 1.15,
                    ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: isBn
                  ? GoogleFonts.hindSiliguri(
                      fontSize: 11,
                      color: const Color(0xFF0277BD),
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    )
                  : GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: const Color(0xFF0277BD),
                      fontWeight: FontWeight.w600,
                      height: 1.1,
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
}
