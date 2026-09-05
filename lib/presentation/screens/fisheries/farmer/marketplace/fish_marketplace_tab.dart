import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/models/marketplace_item_model.dart';
import 'package:agrolinkbd/core/controllers/marketplace_controller.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/marketplace/sell_fish_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/auction/create_fish_auction_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/contracts/farmer_contracts_screen.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/fish_marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/fish_price_prediction_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/vip_wholesaler_directory_screen.dart';
import 'package:agrolinkbd/presentation/widgets/farmer_market_price_advisory_card.dart';
import 'package:agrolinkbd/core/services/market_price_advisory_service.dart';
import 'package:agrolinkbd/core/models/market_price_model.dart';

class FishMarketplaceTab extends StatefulWidget {
  const FishMarketplaceTab({super.key});

  @override
  State<FishMarketplaceTab> createState() => _FishMarketplaceTabState();
}

class _FishMarketplaceTabState extends State<FishMarketplaceTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MarketplaceController _marketplaceController = Get.put(MarketplaceController());
  String _selectedHubView = 'active'; // 'active' or 'history'

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
    final isBn = LanguageProvider.isBn(context);
    const Color deepAqua = Color(0xFF004D40);

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
                isBn ? 'বিগ ফিশ মার্কেট ও হোলসেল ট্রেড' : 'Big Fish Market & Wholesale Trade',
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
            icon: const Icon(Icons.trending_up_rounded, color: Color(0xFF80DEEA)),
            onPressed: () => Get.to(() => const FishPricePredictionScreen()),
            tooltip: isBn ? 'দরের পূর্বাভাস AI' : 'Price Forecast AI',
          ),
          IconButton(
            icon: const Icon(Icons.add_business_rounded, color: Colors.white),
            onPressed: () => Get.to(() => const SellFishScreen()),
            tooltip: isBn ? 'মাছ বিক্রির বিজ্ঞাপন' : 'Post Fish Listing',
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
              tabs: [
                Tab(
                  icon: const Icon(Icons.set_meal, size: 18),
                  text: isBn ? 'বিগ ফিশ মার্কেট' : 'Big Fish Market',
                ),
                Tab(
                  icon: const Icon(Icons.agriculture, size: 18),
                  text: isBn ? 'আমার বিক্রয় হাব' : 'My Selling Hub',
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

          // Tab 2: Farmer Selling & Commercial Hub (High Professional Super-Class Design)
          _buildFarmerSellingHub(context, isDark, deepAqua, isBn),
        ],
      ),
    );
  }

  Widget _buildFarmerSellingHub(BuildContext context, bool isDark, Color deepAqua, bool isBn) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // 1. Hero Commercial Command Card
        SliverToBoxAdapter(
          child: _buildHeroCommercialBanner(context, isDark, deepAqua, isBn),
        ),

        // 2. Commercial Action Toolkit 2x2
        SliverToBoxAdapter(
          child: _buildCommercialToolsSection(context, isDark, isBn),
        ),

        // 3. Segmented Switcher between Active Lots and Sales History
        SliverToBoxAdapter(
          child: _buildHubSectionSwitcher(isDark, deepAqua, isBn),
        ),

        // 4. Dynamic Content: Active Lots or Sales History
        if (_selectedHubView == 'active') ...[
          SliverToBoxAdapter(
            child: FarmerMarketPriceAdvisoryCard(
              farmerId: _marketplaceController.currentUserId,
              isFishFarmer: true,
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildMarketAdvisoryBanner(context, isDark, isBn),
          ),
          SliverToBoxAdapter(
            child: _buildActiveLotsSection(context, isDark, deepAqua, isBn),
          ),
        ] else ...[
          SliverToBoxAdapter(
            child: _buildSalesHistorySection(context, isDark, deepAqua, isBn),
          ),
        ],

        // 5. Safe Bottom Spacing
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildHubSectionSwitcher(bool isDark, Color deepAqua, bool isBn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Obx(() {
        final activeCount = _marketplaceController.myActiveLots.length;
        final historyCount = _marketplaceController.mySoldHistory.length;

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16252F) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.teal.shade200.withValues(alpha: isDark ? 0.2 : 0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Active Lots Segment
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedHubView = 'active'),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedHubView == 'active' ? deepAqua : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_rounded,
                          size: 16,
                          color: _selectedHubView == 'active' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isBn ? 'সক্রিয় লট সমূহ' : 'Active Lots',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _selectedHubView == 'active' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _selectedHubView == 'active'
                                ? Colors.white.withValues(alpha: 0.25)
                                : deepAqua.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$activeCount',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _selectedHubView == 'active' ? Colors.white : deepAqua,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Sales History Segment
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedHubView = 'history'),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedHubView == 'history' ? deepAqua : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_edu_rounded,
                          size: 16,
                          color: _selectedHubView == 'history' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isBn ? 'বিক্রয় ইতিহাস' : 'Sales History',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _selectedHubView == 'history' ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _selectedHubView == 'history'
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.green.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$historyCount',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _selectedHubView == 'history' ? Colors.white : Colors.green.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroCommercialBanner(BuildContext context, bool isDark, Color deepAqua, bool isBn) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF002B2E), Color(0xFF004D40), Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF80DEEA).withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D40).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Chips Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF80DEEA).withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isBn ? 'লাইভ বিক্রয় ড্যাশবোর্ড' : 'Live Selling Command',
                      style: GoogleFonts.hindSiliguri(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                ),
                child: Text(
                  isBn ? 'সারাদেশের আড়ত সক্রিয়' : 'Depots Live 24/7',
                  style: GoogleFonts.hindSiliguri(
                    color: Colors.greenAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Main Catchy Header
          Text(
            isBn ? 'সরাসরি খামার থেকে পাইকারি ও খুচরা বিক্রয়' : 'Direct Farm-to-Buyer Fishery Trade Hub',
            style: GoogleFonts.hindSiliguri(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isBn
                ? 'মধ্যস্বত্বভোগী ছাড়া সারা দেশের অনুমোদিত আড়তদার ও সরাসরি ক্রেতাদের কাছে মাছ বিক্রি করে সর্বোচ্চ লাভ নিশ্চিত করুন।'
                : 'Sell your live aquaculture harvest directly to verified wholesalers and bulk buyers nationwide without middlemen.',
            style: GoogleFonts.hindSiliguri(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),

          // 3 Feature Badges
          Row(
            children: [
              _buildMiniFeatureCapsule(Icons.percent_rounded, isBn ? '০% কমিশন' : '0% Commission'),
              const SizedBox(width: 8),
              _buildMiniFeatureCapsule(Icons.verified_user_rounded, isBn ? 'সুরক্ষিত এস্ক্রো' : 'Escrow Secured'),
              const SizedBox(width: 8),
              _buildMiniFeatureCapsule(Icons.local_shipping_rounded, isBn ? 'অক্সিজেন ভ্যান' : 'Live Logistics'),
            ],
          ),
          const SizedBox(height: 18),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => const SellFishScreen()),
                  icon: const Icon(Icons.add_circle, size: 18, color: Color(0xFF004D40)),
                  label: Text(
                    isBn ? 'নতুন মাছ বিক্রি করুন' : 'Sell New Fish',
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: const Color(0xFF004D40),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF004D40),
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.to(() => const CreateFishAuctionScreen()),
                  icon: const Icon(Icons.gavel_rounded, size: 18, color: Colors.white),
                  label: Text(
                    isBn ? 'লাইভ নিলাম ডাক' : 'Live Auction',
                    style: GoogleFonts.hindSiliguri(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF80DEEA), width: 1.5),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniFeatureCapsule(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF80DEEA), size: 13),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: GoogleFonts.hindSiliguri(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommercialToolsSection(BuildContext context, bool isDark, bool isBn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBn ? 'বাণিজ্যিক বিক্রয় টুলস ও সেবা' : 'Commercial Sales Toolkit',
            style: GoogleFonts.hindSiliguri(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  isBn ? 'লাইভ মাছের নিলাম' : 'Live Fish Auction',
                  isBn ? 'আড়তদারদের উন্মুক্ত বিড' : 'Instant wholesaler bidding',
                  Icons.gavel_rounded,
                  const Color(0xFFD81B60),
                  () => Get.to(() => const CreateFishAuctionScreen()),
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionTile(
                  isBn ? 'আগাম বায়না চুক্তি' : 'Forward Contract',
                  isBn ? 'হারভেস্ট চুক্তি বুকিং' : 'Pre-harvest price locking',
                  Icons.assignment_turned_in_rounded,
                  const Color(0xFF00897B),
                  () => Get.to(() => const FarmerContractsScreen()),
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  isBn ? 'দরের পূর্বাভাস AI' : 'Price Forecast AI',
                  isBn ? '৭ দিনের বাজারদর বিশ্লেষণ' : 'Next 7-day rate forecast',
                  Icons.trending_up_rounded,
                  const Color(0xFF7B1FA2),
                  () => Get.to(() => const FishPricePredictionScreen()),
                  isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildActionTile(
                  isBn ? 'ভিআইপি আড়তদার' : 'VIP Wholesalers',
                  isBn ? 'শীর্ষ বায়ারদের সরাসরি ফোন' : 'Direct bulk buyer contacts',
                  Icons.contact_phone_rounded,
                  const Color(0xFFE65100),
                  () => Get.to(() => const VipWholesalerDirectoryScreen()),
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketAdvisoryBanner(BuildContext context, bool isDark, bool isBn) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E2F2B), const Color(0xFF16252F)]
              : [const Color(0xFFE0F2F1), const Color(0xFFE8F5E9)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade300.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'স্মার্ট বিক্রয় পরামর্শ' : 'Smart Selling Advisory',
                  style: GoogleFonts.hindSiliguri(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.tealAccent : const Color(0xFF004D40),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isBn
                      ? 'ভোর ৫:০০ - সকাল ৮:০০ টার মধ্যে মাছের লট তালিকাভুক্ত করলে আড়তদারদের থেকে ৩০% দ্রুত রেসপন্স ও সেরা পাইকারি দর নিশ্চিত হয়।'
                      : 'Listing your harvest between 5:00 AM - 8:00 AM yields 30% faster wholesale bids and premium rates.',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11.5,
                    color: isDark ? Colors.white70 : Colors.grey.shade800,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveLotsSection(BuildContext context, bool isDark, Color deepAqua, bool isBn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'আপনার সক্রিয় বিজ্ঞাপিত লট সমূহ' : 'Your Active Listed Lots',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              TextButton.icon(
                onPressed: () => Get.to(() => const SellFishScreen()),
                icon: const Icon(Icons.add_circle_outline, size: 16, color: Color(0xFF004D40)),
                label: Text(
                  isBn ? 'নতুন লট' : 'New Lot',
                  style: GoogleFonts.hindSiliguri(
                    color: const Color(0xFF004D40),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Reactive items list safely inside box adapter
          Obx(() {
            if (_marketplaceController.isLoading.value && _marketplaceController.items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: CircularProgressIndicator(color: deepAqua),
                ),
              );
            }

            final activeLots = _marketplaceController.myActiveLots;

            if (activeLots.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16252F) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200.withValues(alpha: isDark ? 0.2 : 0.8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: deepAqua.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.storefront_rounded, size: 48, color: deepAqua),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isBn ? 'বর্তমানে কোনো সক্রিয় মাছের লট নেই' : 'No active fish lots listed right now',
                      style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isBn
                          ? 'আপনার পুকুর বা ঘেরের মাছ সরাসরি বিগ ফিশ মার্কেটে বিক্রি করতে নিচের বাটনে ক্লিক করে নতুন লট তৈরি করুন।'
                          : 'List your live harvest directly to the Big Fish Market to start receiving wholesale buyer offers.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      onPressed: () => Get.to(() => const SellFishScreen()),
                      icon: const Icon(Icons.add, color: Colors.white, size: 18),
                      label: Text(
                        isBn ? 'নতুন মাছের লট তৈরি করুন' : 'Post New Fish Lot',
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: deepAqua,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activeLots.length,
              itemBuilder: (context, index) {
                final item = activeLots[index];
                final double totalLotPrice = item.quantityKg * item.pricePerKg;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF16252F) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.teal.shade200.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Row
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: deepAqua.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(Icons.set_meal_rounded, color: deepAqua, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.fishType,
                                  style: GoogleFonts.hindSiliguri(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  isBn
                                      ? '${item.quantityKg.toStringAsFixed(0)} কেজি • গড় ওজন: ${item.avgWeightGram.toStringAsFixed(0)} গ্রাম'
                                      : '${item.quantityKg.toStringAsFixed(0)} kg • Avg Weight: ${item.avgWeightGram.toStringAsFixed(0)} g',
                                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isBn ? 'বাজারে সক্রিয়' : 'Active',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 11,
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      if (item.location.isNotEmpty || (item.description != null && item.description!.isNotEmpty)) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF101B22) : const Color(0xFFF7FBF9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 14, color: Colors.teal.shade700),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${item.location.isNotEmpty ? item.location : (isBn ? 'খামার এলাকা' : 'Farm Location')}${item.description != null && item.description!.isNotEmpty ? " • ${item.description}" : ""}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 11.5,
                                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),

                      // Price & Total Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn ? 'দর প্রতি কেজি' : 'Rate / kg',
                                style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                              ),
                              Text(
                                '৳${item.pricePerKg.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: deepAqua),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isBn ? 'লটের মোট বিক্রয়মূল্য' : 'Total Lot Value',
                                style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                              ),
                              Text(
                                '৳${totalLotPrice.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF00695C)),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Super Admin Benchmark Comparison & 1-tap Price Sync
                      _buildLotMarketPriceSyncWidget(item, isDark, isBn),

                      const SizedBox(height: 14),

                      // Action Buttons: Edit, Mark Sold, Delete
                      Row(
                        children: [
                          // Edit Button
                          Expanded(
                            flex: 3,
                            child: OutlinedButton.icon(
                              onPressed: () => Get.to(() => SellFishScreen(itemToEdit: item)),
                              icon: const Icon(Icons.edit_note_rounded, size: 16, color: Color(0xFF004D40)),
                              label: Text(
                                isBn ? 'এডিট' : 'Edit',
                                style: GoogleFonts.hindSiliguri(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: const Color(0xFF004D40),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF004D40)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Mark as Sold Button
                          Expanded(
                            flex: 5,
                            child: ElevatedButton.icon(
                              onPressed: () => _showMarkAsSoldDialog(context, item, isBn, isDark),
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
                              label: Text(
                                isBn ? 'বিক্রয় সম্পন্ন' : 'Mark Sold',
                                style: GoogleFonts.hindSiliguri(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00796B),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Delete Button
                          IconButton(
                            onPressed: () => _showDeleteDialog(context, item, isBn, isDark),
                            icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                            tooltip: isBn ? 'লট মুছে ফেলুন' : 'Delete Lot',
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.red.withValues(alpha: 0.08),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSalesHistorySection(BuildContext context, bool isDark, Color deepAqua, bool isBn) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lifetime Revenue Summary Card
          Obx(() {
            final totalRevenue = _marketplaceController.totalLifetimeRevenue;
            final totalWeight = _marketplaceController.totalKgSold;
            final count = _marketplaceController.mySoldHistory.length;

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00382E), Color(0xFF005B4D), Color(0xFF00796B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
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
                        isBn ? 'সর্বমোট বিক্রয় ও বাণিজ্য সারসংক্ষেপ' : 'Lifetime Sales & Revenue Summary',
                        style: GoogleFonts.hindSiliguri(
                          color: const Color(0xFF80DEEA),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 18),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '৳${totalRevenue.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isBn ? 'ফায়ারবেস ডেটাবেস থেকে অর্জিত মোট বিক্রয়মূল্য' : 'Total Revenue Recorded in Database',
                    style: GoogleFonts.hindSiliguri(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.scale_rounded, color: Color(0xFF80DEEA), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            isBn ? 'মোট বিক্রিত: ${totalWeight.toStringAsFixed(0)} কেজি' : 'Sold: ${totalWeight.toStringAsFixed(0)} kg',
                            style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Icon(Icons.task_alt_rounded, color: Colors.greenAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            isBn ? 'সম্পন্ন লট: $count টি' : 'Completed Lots: $count',
                            style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // Previous Activity Title
          Text(
            isBn ? 'পূর্ববর্তী বিক্রয় কার্যক্রম ও ডেটাবেস ইতিহাস' : 'Previous Sales Activity & Trade Records',
            style: GoogleFonts.hindSiliguri(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 10),

          // Sold Items List
          Obx(() {
            final soldLots = _marketplaceController.mySoldHistory;

            if (soldLots.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16252F) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200.withValues(alpha: isDark ? 0.2 : 0.8)),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.history_rounded, size: 44, color: Colors.green),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isBn ? 'এখনও কোনো বিক্রয় সম্পন্ন হয়নি' : 'No completed sales records yet',
                      style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isBn
                          ? 'আপনার বিজ্ঞাপিত মাছ বিক্রি হলে "বিক্রয় সম্পন্ন" বাটনে ক্লিক করুন। সেটি স্বয়ংক্রিয়ভাবে সক্রিয় তালিকা থেকে সরে গিয়ে এখানে ডেটাবেস হিস্ট্রিতে যুক্ত হবে।'
                          : 'When you mark an active lot as sold, it will automatically vanish from active listings and appear here as completed sales history.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: soldLots.length,
              itemBuilder: (context, index) {
                final item = soldLots[index];
                final finalSoldPrice = item.soldPrice ?? (item.quantityKg * item.pricePerKg);
                final dateStr = item.soldAt != null
                    ? DateFormat('dd MMM yyyy, hh:mm a').format(item.soldAt!)
                    : DateFormat('dd MMM yyyy').format(item.createdAt);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF16252F) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.green.shade200.withValues(alpha: 0.5)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
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
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.fishType,
                                    style: GoogleFonts.hindSiliguri(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.5,
                                    ),
                                  ),
                                  Text(
                                    isBn
                                        ? '${item.quantityKg.toStringAsFixed(0)} কেজি • গড় ওজন: ${item.avgWeightGram.toStringAsFixed(0)} গ্রাম'
                                        : '${item.quantityKg.toStringAsFixed(0)} kg • Avg: ${item.avgWeightGram.toStringAsFixed(0)} g',
                                    style: GoogleFonts.hindSiliguri(fontSize: 11.5, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.green.shade300),
                            ),
                            child: Text(
                              isBn ? 'বিক্রয় সম্পন্ন' : 'Sold & Delivered',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 10.5,
                                color: Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Divider(height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBn ? 'ক্রেতা / চ্যানেল' : 'Buyer / Channel',
                                style: GoogleFonts.hindSiliguri(fontSize: 10.5, color: Colors.grey.shade600),
                              ),
                              Text(
                                item.soldTo ?? (isBn ? 'সরাসরি পাইকার / আড়ত' : 'Direct Buyer'),
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                isBn ? 'মোট প্রাপ্ত মূল্য' : 'Final Sold Amount',
                                style: GoogleFonts.hindSiliguri(fontSize: 10.5, color: Colors.grey.shade600),
                              ),
                              Text(
                                '৳${finalSoldPrice.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'তারিখ: $dateStr' : 'Date: $dateStr',
                            style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.grey.shade500),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // Re-list as new lot
                              Get.to(() => SellFishScreen(
                                    itemToEdit: item.copyWith(
                                      id: 'LOT_${DateTime.now().millisecondsSinceEpoch}',
                                      status: 'active',
                                    ),
                                  ));
                            },
                            icon: const Icon(Icons.replay_rounded, size: 14, color: Color(0xFF004D40)),
                            label: Text(
                              isBn ? 'পুনরায় লট ছাড়ুন' : 'Re-list Lot',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF004D40),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  void _showMarkAsSoldDialog(BuildContext context, MarketplaceItemModel item, bool isBn, bool isDark) {
    final priceController = TextEditingController(
      text: (item.quantityKg * item.pricePerKg).toStringAsFixed(0),
    );
    final buyerController = TextEditingController(
      text: isBn ? 'আড়তদার / সরাসরি পাইকার' : 'Wholesaler / Direct Buyer',
    );

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF16252F) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isBn ? 'বিক্রয় সম্পন্ন নিশ্চিত করুন' : 'Confirm Lot Sale',
                      style: GoogleFonts.hindSiliguri(fontSize: 16.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                isBn
                    ? '${item.fishType} (${item.quantityKg.toStringAsFixed(0)} কেজি) বিক্রয় সম্পন্ন হলে এটি সক্রিয় তালিকা থেকে সরে স্বয়ংক্রিয়ভাবে বিক্রয় ইতিহাসে যুক্ত হবে।'
                    : '${item.fishType} (${item.quantityKg.toStringAsFixed(0)} kg) will be moved from active listings to completed sales history.',
                style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                isBn ? 'চূড়ান্ত মোট বিক্রয়মূল্য (টাকা):' : 'Final Total Sold Amount (৳):',
                style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.monetization_on_rounded, color: Colors.green),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF101B22) : const Color(0xFFF1F5F8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isBn ? 'ক্রেতা বা আড়তের নাম:' : 'Buyer or Wholesaler Name:',
                style: GoogleFonts.hindSiliguri(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: buyerController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.person_rounded, color: Colors.teal),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF101B22) : const Color(0xFFF1F5F8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      isBn ? 'বাতিল' : 'Cancel',
                      style: GoogleFonts.hindSiliguri(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final finalPrice = double.tryParse(priceController.text) ?? (item.quantityKg * item.pricePerKg);
                      final buyer = buyerController.text.trim();

                      Get.back();
                      final success = await _marketplaceController.markLotAsSold(
                        item.id,
                        finalPrice: finalPrice,
                        buyerName: buyer,
                      );

                      if (success) {
                        Get.snackbar(
                          isBn ? 'বিক্রয় সফল!' : 'Sale Recorded!',
                          isBn ? 'লটটি সফলভাবে বিক্রয় সম্পন্ন হিসেবে ইতিহাসে সংরক্ষিত হয়েছে।' : 'Lot moved to sales history successfully.',
                          backgroundColor: const Color(0xFF004D40),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00796B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      isBn ? 'সম্পন্ন করুন' : 'Confirm Sale',
                      style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, MarketplaceItemModel item, bool isBn, bool isDark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF16252F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          isBn ? 'লট মুছে ফেলতে চান?' : 'Delete Fish Lot?',
          style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isBn
              ? '${item.fishType} (${item.quantityKg.toStringAsFixed(0)} কেজি) বিজ্ঞাপিত লটটি ফায়ারবেস ডেটাবেস থেকে স্থায়ীভাবে মুছে ফেলা হবে।'
              : 'This fish lot will be permanently deleted from the database.',
          style: GoogleFonts.hindSiliguri(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              isBn ? 'না' : 'Cancel',
              style: GoogleFonts.hindSiliguri(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await _marketplaceController.deleteLot(item.id);
              if (success) {
                Get.snackbar(
                  isBn ? 'মুছে ফেলা হয়েছে' : 'Deleted',
                  isBn ? 'লটটি ডেটাবেস থেকে মুছে ফেলা হয়েছে।' : 'Lot was deleted from database.',
                  backgroundColor: Colors.red.shade700,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              isBn ? 'হ্যাঁ, মুছুন' : 'Delete',
              style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, String sub, IconData icon, Color color, VoidCallback onTap, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF16252F) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.25)),
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
      ),
    );
  }

  Widget _buildLotMarketPriceSyncWidget(MarketplaceItemModel item, bool isDark, bool isBn) {
    return StreamBuilder<List<MarketPriceModel>>(
      stream: MarketPriceAdvisoryService().streamBenchmarks(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final benchmarks = snapshot.data!;
        final matched = MarketPriceAdvisoryService().findMatchingBenchmark(
          item.fishType,
          benchmarks,
          category: 'fish',
        );

        if (matched == null || matched.currentPrice <= 0) return const SizedBox.shrink();

        final bench = matched.currentPrice;
        final currentRate = item.pricePerKg;
        final diff = (currentRate - bench) / bench;

        if (diff.abs() <= 0.05) {
          return Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline, size: 14, color: Colors.green),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isBn
                        ? '✓ বর্তমান বাজারদর (৳${bench.toStringAsFixed(0)}/কেজি) অনুযায়ী অপটিমাল'
                        : '✓ Optimal rate matched with market (৳${bench.toStringAsFixed(0)}/kg)',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final isHigh = diff > 0.05;
        final diffAmount = (currentRate - bench).abs().toStringAsFixed(0);
        final badgeColor = isHigh ? Colors.amber.shade900 : const Color(0xFF0284C7);
        final bgColor = isHigh
            ? (isDark ? const Color(0xFF2A2010) : const Color(0xFFFFF8E1))
            : (isDark ? const Color(0xFF0C2433) : const Color(0xFFE0F2FE));

        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(
                isHigh ? Icons.trending_down_rounded : Icons.trending_up_rounded,
                size: 16,
                color: badgeColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isHigh
                          ? (isBn ? 'বাজারের চেয়ে ৳$diffAmount বেশি (কমানোর সুপারিশ)' : '৳$diffAmount above market (Decrease advised)')
                          : (isBn ? 'বাজারের চেয়ে ৳$diffAmount কম (বাড়ানোর সুযোগ)' : '৳$diffAmount below market (Increase advised)'),
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: badgeColor,
                      ),
                    ),
                    Text(
                      isBn
                          ? 'বর্তমান বেঞ্চমার্ক রেট: ৳${bench.toStringAsFixed(0)}/কেজি'
                          : 'Benchmark Rate: ৳${bench.toStringAsFixed(0)}/kg',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 10,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton(
                onPressed: () async {
                  final ok = await MarketPriceAdvisoryService().applySuggestedPrice(
                    itemId: item.id,
                    newPrice: bench,
                    isFishLot: true,
                  );
                  if (ok) {
                    Get.snackbar(
                      isBn ? 'দর আপডেট হয়েছে' : 'Rate Updated',
                      isBn
                          ? '${item.fishType}-এর দর ৳${bench.toStringAsFixed(0)}/কেজি নির্ধারণ করা হয়েছে'
                          : 'Updated rate to ৳${bench.toStringAsFixed(0)}/kg',
                      backgroundColor: const Color(0xFF004D40),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: badgeColor,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text(
                  isBn ? '৳${bench.toStringAsFixed(0)} করুন' : 'Set ৳${bench.toStringAsFixed(0)}',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
