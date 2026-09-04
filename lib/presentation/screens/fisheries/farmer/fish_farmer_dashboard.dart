import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/services/transaction_service.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/presentation/widgets/secure_balance_widget.dart';
import 'package:agrolinkbd/presentation/widgets/global_announcement_banner.dart';
import 'package:agrolinkbd/presentation/widgets/report_generation_card.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/pond_management/pond_management_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/ai_doctor/ai_fish_doctor_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/feed_management/feed_management_screen.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/fish_marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/water_testing/water_testing_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/expert_advice/expert_advice_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/transport/fish_transport_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/market_price/fish_market_price_screen.dart';
import 'package:agrolinkbd/core/utils/responsive_helper.dart';
import 'package:agrolinkbd/presentation/widgets/weather_card_widget.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/auction/create_fish_auction_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/contracts/farmer_contracts_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/fcr_calculator/fish_growth_fcr_simulator_screen.dart';
import 'package:agrolinkbd/presentation/screens/subscription/vip_subscription_paywall_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/fish_price_prediction_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/satellite_pond_radar_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/bank_project_report_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/vip_wholesaler_directory_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/fish_water_telemetry_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/fish_fingerling_calculator_screen.dart';

class FishFarmerDashboard extends StatefulWidget {
  const FishFarmerDashboard({super.key});

  @override
  State<FishFarmerDashboard> createState() => _FishFarmerDashboardState();
}

class _FishFarmerDashboardState extends State<FishFarmerDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _tickerScrollController;

  // Interactive Tasks State
  final List<Map<String, dynamic>> _tasks = [
    {
      'titleBn': 'পুকুর-১ এ সকালের মাছের খাবার দেওয়া',
      'titleEn': 'Morning feeding at Pond-1',
      'completed': false,
    },
    {
      'titleBn': 'পুকুর-২ এর পানি ও পিএইচ পরীক্ষা করা',
      'titleEn': 'Test water & pH level in Pond-2',
      'completed': false,
    },
    {
      'titleBn': 'নতুন পোনা ছাড়ার জন্য ট্যাংক প্রস্তুতি',
      'titleEn': 'Prepare tank for fingerling stocking',
      'completed': true,
    },
    {
      'titleBn': 'অ্যারেটর ও অক্সিজেন মাত্রা চেক করা',
      'titleEn': 'Check aerators & dissolved oxygen',
      'completed': false,
    },
  ];

  final TransactionService _transactionService = TransactionService();
  double _balance = 0.0;
  late String _userId;

  @override
  void initState() {
    super.initState();
    final userController = Get.isRegistered<UserController>()
        ? Get.find<UserController>()
        : Get.put(UserController());
    _userId = userController.userId.isNotEmpty 
        ? userController.userId 
        : (FirebaseAuth.instance.currentUser?.uid ?? 'farmer_demo');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _tickerScrollController = ScrollController();
    _animationController.forward();
    
    // Auto scroll ticker
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });

    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    final balance = await _transactionService.getWalletBalance(_userId);
    if (mounted) {
      setState(() {
        _balance = balance;
      });
    }
  }

  void _startAutoScroll() async {
    while (mounted) {
      if (_tickerScrollController.hasClients) {
        double maxExtent = _tickerScrollController.position.maxScrollExtent;
        await _tickerScrollController.animateTo(
          maxExtent,
          duration: Duration(seconds: (maxExtent / 20).round()),
          curve: Curves.linear,
        );
        if (mounted && _tickerScrollController.hasClients) {
          _tickerScrollController.jumpTo(0);
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tickerScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBn = LanguageProvider.isBn(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color oceanBlue = Color(0xFF0288D1); // Primary Fisheries Color
    const Color deepAqua = Color(0xFF006064);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            const GlobalAnnouncementBanner(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 18),
                      
                      // User Header with Balance & Notifications
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Consumer<UserProvider>(
                                  builder: (context, userProvider, _) {
                                    final userName = userProvider.currentUser?.name ?? (isBn ? 'মৎস্য চাষী' : 'Fish Farmer');
                                    return Text(
                                      isBn ? 'স্বাগতম, $userName' : 'Welcome, $userName',
                                      style: GoogleFonts.hindSiliguri(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : deepAqua,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                      )
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.account_balance_wallet, size: 16, color: oceanBlue),
                                      const SizedBox(width: 4),
                                      StreamBuilder<DocumentSnapshot>(
                                        stream: FirebaseFirestore.instance.collection('cards').doc(_userId).snapshots(),
                                        builder: (context, snapshot) {
                                          String? walletPin;
                                          if (snapshot.hasData && snapshot.data!.data() != null) {
                                            walletPin = (snapshot.data!.data() as Map<String, dynamic>)['walletPin'];
                                          }
                                          
                                          return SecureBalanceWidget(
                                            balance: _balance,
                                            pin: walletPin,
                                            pinFieldType: 'walletBalance',
                                            textColor: oceanBlue,
                                            fontSize: 13.5,
                                            label: isBn ? 'ব্যালেন্স দেখতে ট্যাপ করুন' : 'Tap to view',
                                          );
                                        }
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black87, size: 26),
                                onPressed: () {},
                              ),
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    '2',
                                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),

                      // Weather & Water Alert Card
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                            final user = userProvider.currentUser;
                            return WeatherCardWidget(
                              isFisheriesTheme: true,
                              customDistrict: user?.district,
                              customUpazila: user?.upazila,
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ============================================
                      // 1. জরুরী মৎস্য সেবা (QUICK ACTIONS GRID)
                      // ============================================
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: deepAqua.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.flash_on_rounded, color: deepAqua, size: 20),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isBn ? 'জরুরী মৎস্য সেবা' : 'Emergency Fishery Services',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildQuickActionsGrid(oceanBlue, deepAqua, isBn, isDark),
                      ),

                      const SizedBox(height: 22),

                      // ============================================
                      // 2. ULTRA PRO COMMERCIAL & INCOME GENERATION HUB
                      // ============================================
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF004D40), Color(0xFF00695C), Color(0xFF00897B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF004D40).withValues(alpha: 0.35),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.stars, color: Colors.amberAccent, size: 22),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          isBn ? 'মাছ বাণিজ্য ও মুনাফা হাব' : 'Fish Commerce & Profit Hub',
                                          style: GoogleFonts.hindSiliguri(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.amberAccent.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.amberAccent),
                                  ),
                                  child: Text(
                                    'Ultra Pro Max',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amberAccent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isBn 
                                  ? 'সরাসরি পাইকারদের লাইভ ডাক ও আগাম বুকিং চুক্তির মাধ্যমে সর্বোচ্চ আয় নিশ্চিত করুন।'
                                  : 'Maximize revenue with live wholesaler bidding & forward booking contracts.',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                // Action 1: Live Auction
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Get.to(() => const CreateFishAuctionScreen()),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.gavel, color: Colors.amberAccent, size: 24),
                                          const SizedBox(height: 6),
                                          Text(
                                            isBn ? 'লাইভ ডাক তুলুন' : 'Live Auction',
                                            style: GoogleFonts.hindSiliguri(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            isBn ? 'নিলামে বিক্রি' : 'Bidding Sale',
                                            style: GoogleFonts.hindSiliguri(
                                              color: Colors.white70,
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Action 2: Advance Futures
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Get.to(() => const FarmerContractsScreen()),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.assignment_turned_in, color: Colors.cyanAccent, size: 24),
                                          const SizedBox(height: 6),
                                          Text(
                                            isBn ? 'আগাম বিক্রয় চুক্তি' : 'Futures Contract',
                                            style: GoogleFonts.hindSiliguri(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            isBn ? '২৫% অগ্রিম ক্যাশ' : '25% Advance Cash',
                                            style: GoogleFonts.hindSiliguri(
                                              color: Colors.white70,
                                              fontSize: 10,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Action 3: FCR & Profit Simulator
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Get.to(() => const FishGrowthFcrSimulatorScreen()),
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.insights, color: Colors.orangeAccent, size: 24),
                                          const SizedBox(height: 6),
                                          Text(
                                            isBn ? 'FCR ও লাভ সিমুলেটর' : 'FCR & Profit Sim',
                                            style: GoogleFonts.hindSiliguri(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            isBn ? 'ফিড খরচ নিয়ন্ত্রণ' : 'Feed Optimizer',
                                            style: GoogleFonts.hindSiliguri(
                                              color: Colors.white70,
                                              fontSize: 10,
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // ============================================
                      // 3. VIP PRO INTELLIGENCE & SATELLITE HUB (VIP PASS)
                      // ============================================
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE65100), Color(0xFFF57C00), Color(0xFFFF9800)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE65100).withValues(alpha: 0.35),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.workspace_premium, color: Colors.white, size: 22),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          isBn ? 'ভিআইপি ইন্টেলিজেন্স ও রাডার' : 'VIP Intelligence & Radar',
                                          style: GoogleFonts.hindSiliguri(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Get.to(() => const VipSubscriptionPaywallScreen()),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'VIP PASS 👑',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFE65100),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isBn 
                                  ? 'এআই প্রাইজ প্রেডিকশন, স্যাটেলাইট ওভারফ্লো রাডার ও ব্যাংক লোন ডসিয়ার সুবিধা।'
                                  : 'AI price forecast, satellite pond radar, and bank loan project dossiers.',
                              style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.white.withValues(alpha: 0.95)),
                            ),
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                // 1. AI Price Forecast
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Get.to(() => const FishPricePredictionScreen()),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white30),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.trending_up, color: Colors.white, size: 22),
                                          const SizedBox(height: 4),
                                          Text(
                                            isBn ? '১৪-দিনের দর' : '14-Day Price', 
                                            style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            isBn ? 'এআই পূর্বাভাস' : 'AI Forecast', 
                                            style: GoogleFonts.hindSiliguri(fontSize: 9.5, color: Colors.white70),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // 2. Satellite Radar
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Get.to(() => const SatellitePondRadarScreen()),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white30),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.satellite_alt, color: Colors.white, size: 22),
                                          const SizedBox(height: 4),
                                          Text(
                                            isBn ? 'স্যাটেলাইট রাডার' : 'Satellite Radar', 
                                            style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            isBn ? 'শেওলা ও অতিবৃষ্টি' : 'Algae & Flood', 
                                            style: GoogleFonts.hindSiliguri(fontSize: 9.5, color: Colors.white70),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // 3. Bank Loan Dossier
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Get.to(() => const BankProjectReportScreen()),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white30),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.account_balance, color: Colors.white, size: 22),
                                          const SizedBox(height: 4),
                                          Text(
                                            isBn ? 'ব্যাংক লোন ফাইল' : 'Bank Loan File', 
                                            style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            isBn ? 'প্রজেক্ট ডসিয়ার' : 'Project Dossier', 
                                            style: GoogleFonts.hindSiliguri(fontSize: 9.5, color: Colors.white70),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // 4. Mokam Wholesaler Hotline
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Get.to(() => const VipWholesalerDirectoryScreen()),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white30),
                                      ),
                                      child: Column(
                                        children: [
                                          const Icon(Icons.phone_in_talk, color: Colors.white, size: 22),
                                          const SizedBox(height: 4),
                                          Text(
                                            isBn ? 'আড়তদার ডিরেক্টরি' : 'Wholesalers', 
                                            style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            isBn ? 'ভিআইপি হটলাইন' : 'VIP Hotline', 
                                            style: GoogleFonts.hindSiliguri(fontSize: 9.5, color: Colors.white70),
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
                                // 5. Water Quality & Oxygen Telemetry
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Get.to(() => const FishWaterTelemetryScreen()),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white30),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.water_drop, color: Colors.cyanAccent, size: 20),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isBn ? 'ওয়াটার কোয়ালিটি' : 'Water Telemetry', 
                                                  style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  isBn ? 'অক্সিজেন ও পিএইচ লাইভ' : 'DO & pH Live Sensors', 
                                                  style: GoogleFonts.hindSiliguri(fontSize: 9.5, color: Colors.white70),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // 6. Fry & Fingerling Stocking Calculator
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Get.to(() => const FishFingerlingCalculatorScreen()),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white30),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.calculate, color: Colors.amberAccent, size: 20),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isBn ? 'পোনা ক্যালকুলেটর' : 'Fingerling Calculator', 
                                                  style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  isBn ? 'শতকে মজুদ সংখ্যা' : 'Stocking Density', 
                                                  style: GoogleFonts.hindSiliguri(fontSize: 9.5, color: Colors.white70),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Tasks Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'আজকের কাজ' : "Today's Work",
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              isBn ? 'সব দেখুন' : 'View All',
                              style: GoogleFonts.hindSiliguri(
                                color: oceanBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ..._tasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final task = entry.value;
                        final title = isBn ? task['titleBn']! : task['titleEn']!;
                        final completed = task['completed'] as bool;

                        return _buildTaskItem(
                          title, 
                          completed, 
                          oceanBlue,
                          onToggle: () {
                            setState(() {
                              _tasks[index]['completed'] = !completed;
                            });
                          },
                        );
                      }).toList(),

                      const SizedBox(height: 24),

                      // Activity Report Generation
                      Text(
                        isBn ? 'অ্যাক্টিভিটি রিপোর্ট' : 'Activity Report',
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, _) {
                          return ReportGenerationCard(
                            userName: userProvider.currentUser?.name ?? (isBn ? 'মৎস্য চাষী' : 'Fish Farmer'),
                            userId: _userId,
                            userRole: 'fishFarmer',
                            amount1Label: isBn ? 'মোট আয়' : 'Total Revenue',
                            amount2Label: isBn ? 'মোট ব্যয়' : 'Total Expense',
                            color: oceanBlue,
                          );
                        }
                      ),
                      
                      const SizedBox(height: 80), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(Color oceanBlue, Color deepAqua, bool isBn, bool isDark) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: ResponsiveHelper.isPhone(context) ? 4 : (ResponsiveHelper.isTablet(context) ? 6 : 8),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: ResponsiveHelper.isPhone(context) ? 0.82 : 1.05,
      children: [
        // Row 1
        _ActionCard(
          title: isBn ? 'পুকুর ব্যবস্থাপনা' : 'Pond Manager',
          icon: Icons.pool,
          color: oceanBlue,
          onTap: () => Get.to(() => const PondManagementScreen()),
        ),
        _ActionCard(
          title: isBn ? 'এআই মাছের ডাক্তার' : 'AI Fish Doctor',
          icon: Icons.health_and_safety,
          color: Colors.teal.shade600,
          onTap: () => Get.to(() => const AIFishDoctorScreen()),
        ),
        _ActionCard(
          title: isBn ? 'খাদ্য ব্যবস্থাপনা' : 'Feed Manager',
          icon: Icons.inventory_2,
          color: Colors.orange.shade700,
          onTap: () => Get.to(() => const FeedManagementScreen()),
        ),
        _ActionCard(
          title: isBn ? 'মাছের বাজার' : 'Fish Market',
          icon: Icons.storefront,
          color: deepAqua,
          onTap: () => Get.to(() => const FishMarketplaceScreen()),
        ),
        
        // Row 2
        _ActionCard(
          title: isBn ? 'পানি পরীক্ষা' : 'Water Testing',
          icon: Icons.science,
          color: Colors.cyan.shade700,
          onTap: () => Get.to(() => const WaterTestingScreen()),
        ),
        _ActionCard(
          title: isBn ? 'বিশেষজ্ঞ পরামর্শ' : 'Expert Advice',
          icon: Icons.support_agent,
          color: Colors.indigo.shade600,
          onTap: () => Get.to(() => const ExpertAdviceScreen()),
        ),
        _ActionCard(
          title: isBn ? 'মাছ পরিবহন' : 'Fish Transport',
          icon: Icons.local_shipping,
          color: deepAqua,
          onTap: () => Get.to(() => const FishTransportScreen()),
        ),
        _ActionCard(
          title: isBn ? 'বাজার দর' : 'Market Price',
          icon: Icons.show_chart,
          color: Colors.purple.shade500,
          onTap: () => Get.to(() => const FishMarketPriceScreen()),
        ),
      ],
    );
  }

  Widget _buildTaskItem(String title, bool completed, Color activeColor, {required VoidCallback onToggle}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: completed ? activeColor : Colors.transparent,
                border: Border.all(
                  color: completed ? activeColor : Colors.grey.shade400,
                  width: 2,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: completed ? Colors.white : Colors.transparent,
              ),
            ),
            title: Text(
              title,
              style: GoogleFonts.hindSiliguri(
                fontSize: 14.5,
                decoration: completed ? TextDecoration.lineThrough : null,
                color: completed ? Colors.grey : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            trailing: Icon(Icons.touch_app, color: Colors.grey.shade400, size: 18),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.22 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                  height: 1.15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
