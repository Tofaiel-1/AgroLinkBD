import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/core/models/marketplace_item_model.dart';
import 'package:agrolinkbd/core/controllers/marketplace_controller.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/marketplace/sell_fish_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/auction/create_fish_auction_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/contracts/farmer_contracts_screen.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/fish_marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/fish_price_prediction_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/vip_wholesaler_directory_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/shopping_cart_screen.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class FishMarketplaceTab extends StatefulWidget {
  const FishMarketplaceTab({super.key});

  @override
  State<FishMarketplaceTab> createState() => _FishMarketplaceTabState();
}

class _FishMarketplaceTabState extends State<FishMarketplaceTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MarketplaceController _marketplaceController = Get.put(MarketplaceController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color deepAqua = Color(0xFF006064);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1218) : const Color(0xFFF1F5F8),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.storefront_rounded, color: Color(0xFF80DEEA), size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'বিগ ফিশ মার্কেট ও হোলসেল ট্রেড',
                style: GoogleFonts.hindSiliguri(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: deepAqua,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_rounded, color: Colors.white),
            onPressed: () => Get.to(() => const SellFishScreen()),
            tooltip: 'মাছ বিক্রির বিজ্ঞাপন',
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                    tooltip: 'শপিং কার্ট',
                    onPressed: () => Get.to(() => const ShoppingCartScreen()),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.deepOrange,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${cart.itemCount}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
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
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: deepAqua,
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFF80DEEA),
              indicatorWeight: 3.5,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: GoogleFonts.hindSiliguri(fontSize: 13.5, fontWeight: FontWeight.bold),
              unselectedLabelStyle: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(
                  icon: Icon(Icons.set_meal, size: 18),
                  text: 'বিগ ফিশ মার্কেট',
                ),
                Tab(
                  icon: Icon(Icons.agriculture, size: 18),
                  text: 'আমার বিক্রয় হাব',
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Full Big Fish Marketplace
          const FishMarketplaceScreen(showAppBar: false),

          // Tab 2: Farmer Selling & Commercial Hub
          _buildFarmerSellingHub(context, isDark, deepAqua),
        ],
      ),
    );
  }

  Widget _buildFarmerSellingHub(BuildContext context, bool isDark, Color deepAqua) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF004D40), Color(0xFF006064), Color(0xFF0288D1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF004D40).withValues(alpha: 0.3),
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
                    Text(
                      'লাইভ মৎস্য বিক্রয় কন্ট্রোল',
                      style: GoogleFonts.hindSiliguri(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.greenAccent.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'সারাদেশের আড়ত কানেক্টেড',
                        style: GoogleFonts.hindSiliguri(
                          color: Colors.greenAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'আপনার খামারের মাছ সরাসরি পাইকারি ও খুচরা ক্রেতাদের কাছে বিক্রি করুন। মধ্যস্বত্বভোগী ছাড়া সর্বোচ্চ লাভ নিশ্চিত করুন।',
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Get.to(() => const SellFishScreen()),
                        icon: const Icon(Icons.add_circle, size: 18, color: Color(0xFF004D40)),
                        label: Text(
                          'নতুন মাছ বিক্রি করুন',
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xFF004D40),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Get.to(() => const CreateFishAuctionScreen()),
                        icon: const Icon(Icons.gavel, size: 18, color: Colors.white),
                        label: Text(
                          'লাইভ নিলাম ডাক',
                          style: GoogleFonts.hindSiliguri(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.white,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white70, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Quick Action Hub Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    'লাইভ নিলাম ডাক',
                    'আড়তদারদের উন্মুক্ত বিড',
                    Icons.gavel_rounded,
                    const Color(0xFFD81B60),
                    () => Get.to(() => const CreateFishAuctionScreen()),
                    isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionTile(
                    'আগাম বায়না চুক্তি',
                    'হারভেস্ট কন্ট্রাক্ট বুকিং',
                    Icons.assignment_turned_in_rounded,
                    const Color(0xFF00897B),
                    () => Get.to(() => const FarmerContractsScreen()),
                    isDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionTile(
                    'দরের পূর্বাভাস AI',
                    'আগামী সপ্তাহের রেট',
                    Icons.trending_up_rounded,
                    const Color(0xFF7B1FA2),
                    () => Get.to(() => const FishPricePredictionScreen()),
                    isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildActionTile(
                    'ভিআইপি আড়তদার ডিরেক্টরি',
                    'বড় বায়ারদের সরাসরি ফোন',
                    Icons.contact_phone_rounded,
                    const Color(0xFFF57C00),
                    () => Get.to(() => const VipWholesalerDirectoryScreen()),
                    isDark,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'আপনার সক্রিয় বিজ্ঞাপিত লট সমূহ',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => Get.to(() => const SellFishScreen()),
                  icon: const Icon(Icons.add, size: 16, color: Color(0xFF006064)),
                  label: Text(
                    'নতুন লট',
                    style: GoogleFonts.hindSiliguri(
                      color: const Color(0xFF006064),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Obx(() {
          final items = _marketplaceController.items;
          if (items.isEmpty) {
            return SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16252F) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Icon(Icons.storefront_outlined, size: 70, color: Colors.teal.shade200),
                    const SizedBox(height: 12),
                    Text(
                      'এখনও কোনো মাছের লট বিজ্ঞাপিত হয়নি',
                      style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'আপনার পুকুরের মাছ সরাসরি বিগ ফিশ মার্কেটে বিক্রি করতে নিচের বাটনে ক্লিক করুন',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => Get.to(() => const SellFishScreen()),
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text('মাছ বিক্রির বিজ্ঞাপন দিন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deepAqua,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16252F) : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: deepAqua.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(Icons.set_meal, color: deepAqua, size: 30),
                      ),
                      title: Text(
                        item.fishType,
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: Text(
                        '${item.quantityKg} কেজি • গড় ওজন: ${item.avgWeightGram} গ্রাম\n৳${item.pricePerKg.toStringAsFixed(0)} /কেজি',
                        style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          'বাজারে লাইভ',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: items.length,
              ),
            ),
          );
        }),

        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildActionTile(String title, String sub, IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF16252F) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 10.5,
                      color: Colors.grey.shade600,
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
}
