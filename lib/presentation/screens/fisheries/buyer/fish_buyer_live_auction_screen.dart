import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/models/fish_auction_model.dart';
import 'package:agrolinkbd/core/services/fish_auction_service.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';

class FishBuyerLiveAuctionScreen extends StatefulWidget {
  const FishBuyerLiveAuctionScreen({super.key});

  @override
  State<FishBuyerLiveAuctionScreen> createState() => _FishBuyerLiveAuctionScreenState();
}

class _FishBuyerLiveAuctionScreenState extends State<FishBuyerLiveAuctionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';
  Timer? _countdownTimer;

  // Selected VIP Membership Plan
  String _selectedPlan = 'season_pass'; // 'season_pass' (৳499) or 'annual_pass' (৳999)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));

    final auctionService = Get.isRegistered<FishAuctionService>()
        ? Get.find<FishAuctionService>()
        : Get.put(FishAuctionService());
    auctionService.checkCurrentUserVipStatus();

    // Timer for refreshing remaining countdowns every 30 seconds
    _countdownTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final formattedPhone = cleanPhone.startsWith('88') ? cleanPhone : '88$cleanPhone';
    final uri = Uri.parse('https://wa.me/$formattedPhone?text=${Uri.encodeComponent("হ্যালো, আমি এগ্রোলিংক লাইভ ফিশ নিলাম ডাকের ব্যাপারে জানতে আগ্রহী।")}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _handleVipPayment(BuildContext context, bool isBn) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        isBn ? 'লগইন প্রয়োজন' : 'Login Required',
        isBn ? 'লাইভ নিলাম এক্টিভ করতে দয়া করে আপনার অ্যাকাউন্টে লগইন করুন' : 'Please login to activate Live Fish Auction access',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final isAnnual = _selectedPlan == 'annual_pass';
    final double amount = isAnnual ? 999.0 : 499.0;
    final int durationDays = isAnnual ? 365 : 30;
    final String planName = isAnnual
        ? (isBn ? 'বাৎসরিক আনলিমিটেড পাইকারি পাস' : 'Annual Unlimited Wholesale Pass')
        : (isBn ? '৩০ দিনের লাইভ অকশন সিজন পাস' : '30-Day Live Auction Season Pass');

    final success = await SSLCommerzService.initiatePayment(
      context: context,
      amount: amount,
      productName: 'Fish Auction VIP - $planName',
      customerName: user.displayName ?? 'Wholesale Buyer',
      customerEmail: user.email ?? 'buyer@agrolinkbd.com',
      customerPhone: user.phoneNumber ?? '01700000000',
      customerAddress: 'Dhaka, Bangladesh',
    );

    if (success) {
      final auctionService = FishAuctionService.to;
      await auctionService.activateVipMembership(
        uid: user.uid,
        userName: user.displayName ?? 'Wholesale Buyer',
        userPhone: user.phoneNumber ?? '01700000000',
        userEmail: user.email ?? 'buyer@agrolinkbd.com',
        planId: _selectedPlan,
        planName: planName,
        price: amount,
        durationDays: durationDays,
      );

      _showActivationCelebrationDialog(context, planName, durationDays, isBn);
    }
  }

  void _showActivationCelebrationDialog(BuildContext context, String planName, int days, bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF004D40).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified_rounded, color: Color(0xFF004D40), size: 55),
            ),
            const SizedBox(height: 16),
            Text(
              isBn ? 'অভিনন্দন! VIP পাস সফল' : 'Congratulations! VIP Pass Active',
              style: GoogleFonts.hindSiliguri(fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF004D40)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isBn
                  ? 'আপনার $planName সফলভাবে সক্রিয় হয়েছে। আপনি এখন সরাসরি খামারিদের লাইভ নিলামে বিড করতে পারবেন।'
                  : 'Your $planName has been activated successfully. You can now participate and place bids in all live fish auctions.',
              style: GoogleFonts.hindSiliguri(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004D40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isBn ? 'নিলামে অংশ নিন' : 'Start Bidding Now',
                  style: GoogleFonts.hindSiliguri(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = LanguageProvider.isBn(context);
    const Color deepOcean = Color(0xFF00363A);

    final auctionService = Get.isRegistered<FishAuctionService>()
        ? Get.find<FishAuctionService>()
        : Get.put(FishAuctionService());

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1218) : const Color(0xFFF0F5F8),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: deepOcean,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Get.back(),
              ),
              actions: [
                Obx(() {
                  final isVip = auctionService.hasVipAuctionAccess.value;
                  return Container(
                    margin: const EdgeInsets.only(right: 14, top: 8, bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: isVip
                          ? const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF8F00)])
                          : LinearGradient(colors: [Colors.white.withValues(alpha: 0.2), Colors.white.withValues(alpha: 0.1)]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isVip ? Colors.amberAccent : Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isVip ? Icons.workspace_premium : Icons.lock_outline, color: isVip ? Colors.black87 : Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          isVip
                              ? (isBn ? 'VIP বিডার' : 'VIP Bidder')
                              : (isBn ? 'লকড বিডিং' : 'VIP Locked'),
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isVip ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isBn ? 'লাইভ মাছের নিলাম (হোলসেল ট্রেড)' : 'Live Fish Auction (Wholesale)',
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF002528), Color(0xFF004D40), Color(0xFF01579B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF80DEEA).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 10),
                              const SizedBox(width: 6),
                              Text(
                                isBn ? 'সরাসরি পুকুর ও ঘেরের লাইভ বিডিং' : 'Direct Live Bidding from Ponds & Ghers',
                                style: GoogleFonts.hindSiliguri(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isBn
                              ? 'খামারিদের তালিকাভুক্ত মাছের লটে সর্বোচ্চ লাইভ দর প্রস্তাব করে সেরা দামে লট কিনুন'
                              : 'Place competitive live bids on farmer-listed commercial lots to win at wholesale rates',
                          style: GoogleFonts.hindSiliguri(
                            color: Colors.white70,
                            fontSize: 11.5,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: isDark ? const Color(0xFF0A1218) : Colors.white,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: const Color(0xFF004D40),
                    indicatorWeight: 3,
                    labelColor: const Color(0xFF004D40),
                    unselectedLabelColor: Colors.grey,
                    labelStyle: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: [
                      Tab(
                        icon: const Icon(Icons.local_fire_department_rounded, size: 18),
                        text: isBn ? 'চলমান লাইভ নিলাম' : 'Active Live Lots',
                      ),
                      Tab(
                        icon: const Icon(Icons.history_edu_rounded, size: 18),
                        text: isBn ? 'আমার বিড ও জেতা লট' : 'My Bids & Won Lots',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildActiveAuctionsTab(context, auctionService, isDark, isBn),
            _buildMyBidsTab(context, auctionService, isDark, isBn),
          ],
        ),
      ),
    );
  }

  // TAB 1: Active Live Auctions
  Widget _buildActiveAuctionsTab(
    BuildContext context,
    FishAuctionService auctionService,
    bool isDark,
    bool isBn,
  ) {
    return Obx(() {
      final isVip = auctionService.hasVipAuctionAccess.value;
      final allAuctions = auctionService.auctions;

      final filteredAuctions = allAuctions.where((a) {
        if (_selectedCategory == 'river') {
          return a.fishSpecies.contains('ইলিশ') || a.fishSpecies.contains('নদী') || a.fishSpecies.contains('Hilsa');
        } else if (_selectedCategory == 'live') {
          return a.condition == FishCondition.liveInWater;
        } else if (_selectedCategory == 'shrimp') {
          return a.fishSpecies.contains('চিংড়ি') || a.fishSpecies.contains('বাগদা') || a.fishSpecies.contains('গলদা') || a.fishSpecies.contains('Shrimp');
        } else if (_selectedCategory == 'carp') {
          return a.fishSpecies.contains('রুই') || a.fishSpecies.contains('কাতলা') || a.fishSpecies.contains('মৃগেল');
        }
        return true;
      }).toList();

      return ListView(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 30),
        physics: const BouncingScrollPhysics(),
        children: [
          // If NOT VIP, Display the Ultra-Premium SSLCommerz Paywall Banner
          if (!isVip)
            _buildVipActivationPaywall(context, isDark, isBn)
          else
            _buildVipActiveBanner(context, auctionService, isDark, isBn),

          const SizedBox(height: 14),

          // Category Chips
          _buildCategoryFilterRow(isBn),

          const SizedBox(height: 14),

          // Header stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? '🔥 চলমান লাইভ লট (${filteredAuctions.length}টি)' : '🔥 Live Bidding Lots (${filteredAuctions.length})',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.fiber_manual_record, color: Colors.redAccent, size: 10),
                    const SizedBox(width: 4),
                    Text(
                      isBn ? 'রিয়েলটাইম আপডেট' : 'Real-time Sync',
                      style: GoogleFonts.hindSiliguri(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Auction Cards List
          if (filteredAuctions.isEmpty)
            _buildEmptyAuctionsState(isBn)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredAuctions.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final auction = filteredAuctions[index];
                return _buildAuctionCard(context, auction, isVip, isDark, isBn);
              },
            ),
        ],
      );
    });
  }

  // VIP Activation Paywall with SSLCommerz Button
  Widget _buildVipActivationPaywall(BuildContext context, bool isDark, bool isBn) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00363A), Color(0xFF004D40), Color(0xFF006064)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF004D40).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.6), width: 1.5),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.stars_rounded, color: Colors.black87, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'VIP পাইকারি বিডার এক্সেস এক্টিভ করুন' : 'Unlock VIP Wholesale Bidding Access',
                      style: GoogleFonts.hindSiliguri(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                      ),
                    ),
                    Text(
                      isBn ? 'সরাসরি খামারিদের ডাক থেকে পাইকারি মূল্যে মাছ কিনুন' : 'Bid directly on commercial farm harvests at wholesale rates',
                      style: GoogleFonts.hindSiliguri(color: const Color(0xFF80DEEA), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // VIP Features Highlights
          _buildPaywallFeatureItem(
            Icons.speed_rounded,
            isBn ? 'রিয়েলটাইম লাইভ বিডিং রুম ও অটোমেটিক বিড অপশন' : 'Real-time Live Bid Rooms with Fast Bid Presets',
          ),
          _buildPaywallFeatureItem(
            Icons.airport_shuttle_rounded,
            isBn ? 'খামার থেকে লাইভ অক্সিজেন ভ্যানে সরাসরি নিরাপদ ডেলিভারি' : 'Direct Live Oxygen Van Cold-Chain Dispatch',
          ),
          _buildPaywallFeatureItem(
            Icons.verified_user_rounded,
            isBn ? '১০০% ফরমালিন মুক্ত সার্টিফাইড ও এগ্রোলিংক এসক্রো প্রটেকশন' : '100% Formalin-Free Certified & Escrow Protection',
          ),

          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),

          // Plan Selection: Season Pass vs Annual Pass
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedPlan = 'season_pass'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedPlan == 'season_pass' ? Colors.white : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedPlan == 'season_pass' ? Colors.amberAccent : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isBn ? '৩০ দিনের সিজন পাস' : '30-Day Season Pass',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _selectedPlan == 'season_pass' ? Colors.black87 : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '৳ ৪৯৯',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _selectedPlan == 'season_pass' ? const Color(0xFF004D40) : Colors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedPlan = 'annual_pass'),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _selectedPlan == 'annual_pass' ? Colors.white : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedPlan == 'annual_pass' ? Colors.amberAccent : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isBn ? 'বাৎসরিক আনলিমিটেড' : 'Annual VIP Pass',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _selectedPlan == 'annual_pass' ? Colors.black87 : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '৳ ৯৯৯',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _selectedPlan == 'annual_pass' ? const Color(0xFF004D40) : Colors.amberAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Pay with SSLCommerz Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _handleVipPayment(context, isBn),
              icon: const Icon(Icons.payment_rounded, color: Colors.black87, size: 20),
              label: Text(
                isBn ? 'SSLCommerz দিয়ে লাইভ অকশন এক্টিভ করুন' : 'Activate Live Auction via SSLCommerz',
                style: GoogleFonts.hindSiliguri(
                  color: Colors.black87,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amberAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaywallFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          Icon(icon, color: Colors.amberAccent, size: 15),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }

  // VIP Active Status Banner
  Widget _buildVipActiveBanner(BuildContext context, FishAuctionService service, bool isDark, bool isBn) {
    final expiry = service.vipExpiryDate.value;
    final planName = service.vipPlanName.value.isNotEmpty
        ? service.vipPlanName.value
        : (isBn ? 'VIP Wholesale Bidder' : 'VIP Wholesale Bidder');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF004D40).withValues(alpha: 0.15),
            const Color(0xFF006064).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF004D40).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF004D40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.amberAccent, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      planName,
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: isDark ? Colors.white : const Color(0xFF004D40),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.green.shade600,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isBn ? 'এক্টিভ' : 'ACTIVE',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Text(
                  expiry != null
                      ? (isBn ? 'মেয়াদ শেষ: ${expiry.day}/${expiry.month}/${expiry.year}' : 'Valid until: ${expiry.day}/${expiry.month}/${expiry.year}')
                      : (isBn ? 'আনলিমিটেড বিডিং সুবিধা চালু আছে' : 'Unlimited live bidding enabled'),
                  style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Category Filter Row
  Widget _buildCategoryFilterRow(bool isBn) {
    final categories = [
      {'key': 'all', 'labelBn': 'সব মাছের লট', 'labelEn': 'All Lots'},
      {'key': 'river', 'labelBn': 'পদ্মার ইলিশ ও নদীর মাছ', 'labelEn': 'River & Hilsa'},
      {'key': 'live', 'labelBn': 'জ্যান্ত অক্সিজেন ট্যাংক', 'labelEn': 'Live Oxygen'},
      {'key': 'shrimp', 'labelBn': 'বাগদা ও গলদা চিংড়ি', 'labelEn': 'Prawn & Shrimp'},
      {'key': 'carp', 'labelBn': 'বড় রুই ও কাতলা', 'labelEn': 'Rui & Katla'},
    ];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat['key'];
          final label = isBn ? cat['labelBn']! : cat['labelEn']!;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              selectedColor: const Color(0xFF004D40),
              backgroundColor: Theme.of(context).cardColor,
              labelStyle: GoogleFonts.hindSiliguri(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black87,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF004D40) : Colors.grey.shade300,
                ),
              ),
              onSelected: (val) => setState(() => _selectedCategory = cat['key']!),
            ),
          );
        },
      ),
    );
  }

  // Auction Card
  Widget _buildAuctionCard(
    BuildContext context,
    FishAuctionModel auction,
    bool isVip,
    bool isDark,
    bool isBn,
  ) {
    final currentBid = auction.currentHighestBidPerKg ?? auction.startingPricePerKg;
    final totalLotValue = currentBid * auction.estimatedTotalKg;
    final remaining = auction.remainingTime;
    final remainingText = remaining.inHours > 0
        ? (isBn ? '${remaining.inHours} ঘণ্টা ${remaining.inMinutes % 60} মিনিট বাকি' : '${remaining.inHours}h ${remaining.inMinutes % 60}m left')
        : (isBn ? '${remaining.inMinutes} মিনিট বাকি' : '${remaining.inMinutes}m left');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16252F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF004D40).withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with Badges
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: CachedNetworkImage(
                  imageUrl: auction.images.isNotEmpty ? auction.images.first : 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788504670/images_qbleou.jpg',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (c, u) => Container(color: Colors.grey.shade200),
                  errorWidget: (c, u, e) => Container(color: const Color(0xFF004D40)),
                ),
              ),
              // Live Red Status Badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.red.withValues(alpha: 0.4), blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
                      const SizedBox(width: 4),
                      Text(
                        isBn ? 'LIVE বিডিং' : 'LIVE BIDDING',
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              // Remaining Time Badge
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.amberAccent, size: 13),
                      const SizedBox(width: 4),
                      Text(
                        remainingText,
                        style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
              // Oxygen / Iced Tag
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF004D40).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    auction.condition == FishCondition.liveInWater
                        ? (isBn ? '🐟 জ্যান্ত অক্সিজেন ভ্যান' : '🐟 Live Oxygen Tank')
                        : (isBn ? '🧊 বরফ তাজা লট' : '🧊 Iced Fresh Lot'),
                    style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  auction.lotTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),

                // Farmer & Location
                Row(
                  children: [
                    Icon(Icons.person_pin_circle_rounded, size: 14, color: Colors.teal.shade700),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${auction.farmerName} • ${auction.farmLocation}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.hindSiliguri(fontSize: 11.5, color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Quantity & Weight stats
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A1218) : const Color(0xFFF7FAFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMiniStat(isBn ? 'মোট পরিমাণ' : 'Total Quantity', '${auction.estimatedTotalKg.toInt()} কেজি', isDark),
                      Container(height: 20, width: 1, color: Colors.grey.shade300),
                      _buildMiniStat(isBn ? 'গড় ওজন/পিস' : 'Avg Weight', '${(auction.avgWeightGram / 1000).toStringAsFixed(1)} কেজি', isDark),
                      Container(height: 20, width: 1, color: Colors.grey.shade300),
                      _buildMiniStat(isBn ? 'মোট বিড' : 'Total Bids', '${auction.bids.length} টি', isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Pricing Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'সর্বোচ্চ বর্তমান বিড:' : 'Current Highest Bid:',
                          style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                        ),
                        Row(
                          children: [
                            Text(
                              '৳ ${currentBid.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF00695C),
                              ),
                            ),
                            Text(
                              isBn ? ' /কেজি' : ' /kg',
                              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        Text(
                          '${isBn ? "মোট সম্ভাব্য মূল্য" : "Lot Total"}: ৳${totalLotValue.toStringAsFixed(0)}',
                          style: GoogleFonts.poppins(fontSize: 10.5, color: Colors.teal.shade800, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),

                    // Bid Room Action Button
                    ElevatedButton.icon(
                      onPressed: () {
                        if (!isVip) {
                          _showVipRequiredPrompt(context, isBn);
                        } else {
                          _openLiveBiddingRoom(context, auction, isDark, isBn);
                        }
                      },
                      icon: Icon(isVip ? Icons.gavel_rounded : Icons.lock_outline, size: 16, color: Colors.white),
                      label: Text(
                        isVip ? (isBn ? 'লাইভ বিড রুম' : 'Enter Bid Room') : (isBn ? 'আনলক করুন' : 'Unlock VIP'),
                        style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: isDark ? Colors.white : const Color(0xFF004D40),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.hindSiliguri(fontSize: 9.5, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  void _showVipRequiredPrompt(BuildContext context, bool isBn) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amberAccent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.stars_rounded, color: Color(0xFF004D40), size: 40),
            ),
            const SizedBox(height: 12),
            Text(
              isBn ? 'লাইভ বিডিংয়ে অংশগ্রহণে VIP পাস প্রয়োজন' : 'VIP Pass Required to Place Bids',
              style: GoogleFonts.hindSiliguri(fontSize: 17, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              isBn
                  ? 'সরাসরি খামারিদের লাইভ নিলামে বিড করতে এবং জ্যান্ত মাছের লট পেতে SSLCommerz দিয়ে VIP পাস এক্টিভ করুন।'
                  : 'To place live bids and procure direct pond harvests, please activate your VIP Auction Pass via SSLCommerz.',
              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600, height: 1.3),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  _handleVipPayment(context, isBn);
                },
                icon: const Icon(Icons.flash_on, color: Colors.black87),
                label: Text(
                  isBn ? 'SSLCommerz দিয়ে এক্টিভ করুন (৳৪৯৯)' : 'Activate via SSLCommerz (৳499)',
                  style: GoogleFonts.hindSiliguri(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Interactive Live Bidding Room BottomSheet
  void _openLiveBiddingRoom(
    BuildContext context,
    FishAuctionModel auction,
    bool isDark,
    bool isBn,
  ) {
    double currentPrice = auction.currentHighestBidPerKg ?? auction.startingPricePerKg;
    double proposedBid = currentPrice + auction.minBidIncrement;
    final TextEditingController customBidController = TextEditingController(text: proposedBid.toStringAsFixed(0));

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setRoomState) {
          final double totalBidCalculated = proposedBid * auction.estimatedTotalKg;
          final user = FirebaseAuth.instance.currentUser;

          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Room Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.fiber_manual_record, color: Colors.white, size: 10),
                                const SizedBox(width: 4),
                                Text(
                                  isBn ? 'লাইভ বিডিং রুম' : 'LIVE ROOM',
                                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            auction.fishSpecies,
                            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Lot info card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16252F) : const Color(0xFFF4F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.teal.shade200.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: auction.images.isNotEmpty ? auction.images.first : 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788504670/images_qbleou.jpg',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                auction.lotTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                '${isBn ? "মোট:" : "Total:"} ${auction.estimatedTotalKg.toInt()} কেজি • ${auction.farmerName}',
                                style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                              ),
                              Text(
                                '${isBn ? "প্রারম্ভিক দর:" : "Starting Price:"} ৳${auction.startingPricePerKg.toStringAsFixed(0)}/কেজি',
                                style: GoogleFonts.hindSiliguri(fontSize: 11, color: const Color(0xFF004D40), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Current Highest Bid Trophy Showcase
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF1B2E35), const Color(0xFF0F1E24)]
                            : [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF00695C), width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  isBn ? 'সর্বোচ্চ বর্তমান লাইভ দর' : 'Highest Live Bid',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF004D40),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '৳ ${currentPrice.toStringAsFixed(0)} /কেজি',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF004D40),
                              ),
                            ),
                            Text(
                              auction.highestBidderName != null
                                  ? '${isBn ? "প্রস্তাবক:" : "Bidder:"} ${auction.highestBidderName}'
                                  : (isBn ? 'এখনও কোনো বিড পড়েনি' : 'No bids yet'),
                              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isBn ? 'লটের মোট মূল্য' : 'Lot Total',
                              style: GoogleFonts.hindSiliguri(fontSize: 10.5, color: Colors.grey.shade600),
                            ),
                            Text(
                              '৳ ${(currentPrice * auction.estimatedTotalKg).toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Increment Bid Buttons (+5, +10, +20, +50)
                  Text(
                    isBn ? 'দ্রুত বিড ইনক্রিমেন্ট নির্বাচন করুন:' : 'Select Quick Bid Increment:',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [5, 10, 20, 50].map((inc) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: OutlinedButton(
                            onPressed: () {
                              setRoomState(() {
                                proposedBid = currentPrice + inc;
                                customBidController.text = proposedBid.toStringAsFixed(0);
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: BorderSide(
                                color: (proposedBid == currentPrice + inc) ? const Color(0xFF004D40) : Colors.grey.shade300,
                                width: (proposedBid == currentPrice + inc) ? 2 : 1,
                              ),
                              backgroundColor: (proposedBid == currentPrice + inc)
                                  ? const Color(0xFF004D40).withValues(alpha: 0.1)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text(
                              '+৳$inc',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: const Color(0xFF004D40),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Proposed Bid Display & Custom input
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16252F) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'আপনার নতুন প্রস্তাবিত দর:' : 'Your Proposed Bid Rate:',
                              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            Text(
                              '৳ ${proposedBid.toStringAsFixed(0)} /কেজি',
                              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF004D40)),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              isBn ? 'মোট প্রদেয় মূল্য:' : 'Total Lot Value:',
                              style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                            ),
                            Text(
                              '৳ ${totalBidCalculated.toStringAsFixed(0)}',
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Submit Bid CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (proposedBid <= currentPrice) {
                          Get.snackbar(
                            isBn ? 'অবৈধ বিড' : 'Invalid Bid',
                            isBn
                                ? 'আপনার বিড বর্তমান সর্বোচ্চ দরের চেয়ে অন্তত ৳${auction.minBidIncrement.toInt()} বেশি হতে হবে'
                                : 'Your bid must be at least ৳${auction.minBidIncrement.toInt()} higher than current highest bid',
                            backgroundColor: Colors.red.shade100,
                            colorText: Colors.red.shade900,
                          );
                          return;
                        }

                        final buyerName = user?.displayName ?? 'Wholesale Buyer (পাইকার)';
                        final buyerPhone = user?.phoneNumber ?? '01700000000';

                        final service = FishAuctionService.to;
                        final success = await service.placeBid(
                          auctionId: auction.id,
                          bidderId: user?.uid ?? 'buyer_${DateTime.now().millisecondsSinceEpoch}',
                          bidderName: buyerName,
                          bidderPhone: buyerPhone,
                          bidderOrganization: 'এগ্রোলিংক রেজিস্টার্ড পাইকার',
                          bidAmountPerKg: proposedBid,
                        );

                        if (success) {
                          Get.back();
                          Get.snackbar(
                            isBn ? 'বিড সফল হয়েছে! 🎉' : 'Bid Placed Successfully! 🎉',
                            isBn
                                ? 'আপনার ৳${proposedBid.toStringAsFixed(0)}/কেজি দর সফলভাবে নথিভুক্ত হয়েছে।'
                                : 'Your bid of ৳${proposedBid.toStringAsFixed(0)}/kg has been registered in the live auction.',
                            backgroundColor: const Color(0xFF004D40),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                            margin: const EdgeInsets.all(16),
                          );
                        }
                      },
                      icon: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
                      label: Text(
                        isBn ? '🔥 বিড সাবমিট করুন (Place Bid)' : '🔥 Submit Live Bid',
                        style: GoogleFonts.hindSiliguri(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Contact Farmer Directly
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => _makePhoneCall(auction.farmerPhone),
                        icon: const Icon(Icons.call, size: 16, color: Colors.green),
                        label: Text(
                          isBn ? 'খামারির সাথে কল' : 'Call Farmer',
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        onPressed: () => _openWhatsApp(auction.farmerPhone),
                        icon: const Icon(Icons.chat_bubble_outline, size: 16, color: Color(0xFF004D40)),
                        label: Text(
                          isBn ? 'হোয়াটসঅ্যাপে মেসেজ' : 'WhatsApp Chat',
                          style: GoogleFonts.hindSiliguri(fontSize: 12, color: const Color(0xFF004D40), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  // TAB 2: My Bids & Won Lots
  Widget _buildMyBidsTab(
    BuildContext context,
    FishAuctionService auctionService,
    bool isDark,
    bool isBn,
  ) {
    return Obx(() {
      final user = FirebaseAuth.instance.currentUser;
      final currentUid = user?.uid;
      final allAuctions = auctionService.auctions;

      final myParticipatedAuctions = allAuctions.where((a) {
        if (currentUid == null) return a.bids.isNotEmpty;
        return a.bids.any((b) => b.bidderId == currentUid) || a.highestBidderId == currentUid;
      }).toList();

      if (myParticipatedAuctions.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gavel_outlined, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  isBn ? 'আপনি এখনও কোনো নিলামে বিড করেননি' : 'You have not placed bids in any auctions yet',
                  style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  isBn
                      ? 'চলমান লাইভ নিলাম ট্যাব থেকে পছন্দের মাছের লট বেছে নিয়ে বিড করুন।'
                      : 'Choose lots from the active live auctions tab and place your bids.',
                  style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(14),
        physics: const BouncingScrollPhysics(),
        itemCount: myParticipatedAuctions.length,
        separatorBuilder: (c, i) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final auction = myParticipatedAuctions[index];
          final isHighest = auction.highestBidderId == currentUid;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF16252F) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isHighest ? Colors.green.shade400 : Colors.grey.shade300,
                width: isHighest ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isHighest ? Colors.green.shade50 : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isHighest ? Colors.green.shade300 : Colors.orange.shade300),
                      ),
                      child: Text(
                        isHighest
                            ? (isBn ? '🏆 আপনি সর্বোচ্চ বিডার (Winning)' : '🏆 You are Winning')
                            : (isBn ? '⚠️ উচ্চতর বিড পড়েছে (Outbid)' : '⚠️ Outbid'),
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isHighest ? Colors.green.shade800 : Colors.orange.shade800,
                        ),
                      ),
                    ),
                    Text(
                      '${auction.estimatedTotalKg.toInt()} কেজি লট',
                      style: GoogleFonts.hindSiliguri(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  auction.lotTitle,
                  style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  '${isBn ? "খামারি:" : "Farmer:"} ${auction.farmerName} (${auction.farmLocation})',
                  style: GoogleFonts.hindSiliguri(fontSize: 11.5, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${isBn ? "সর্বোচ্চ দর:" : "Current Bid:"} ৳${(auction.currentHighestBidPerKg ?? auction.startingPricePerKg).toStringAsFixed(0)}/কেজি',
                      style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF004D40)),
                    ),
                    ElevatedButton(
                      onPressed: () => _openLiveBiddingRoom(context, auction, isDark, isBn),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF004D40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      child: Text(
                        isBn ? 'আবার বিড করুন' : 'Re-bid',
                        style: GoogleFonts.hindSiliguri(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  Widget _buildEmptyAuctionsState(bool isBn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.set_meal_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              isBn ? 'এই ক্যাটাগরিতে কোনো লাইভ নিলাম নেই' : 'No live auctions in this category',
              style: GoogleFonts.hindSiliguri(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              isBn ? 'সব মাছের ক্যাটাগরি নির্বাচন করে দেখুন' : 'Try selecting All Lots category',
              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
