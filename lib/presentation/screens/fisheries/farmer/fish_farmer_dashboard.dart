import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/services/transaction_service.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/presentation/widgets/secure_balance_widget.dart';
import 'package:agrolinkbd/presentation/widgets/global_announcement_banner.dart';
import 'package:agrolinkbd/presentation/widgets/report_generation_card.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/pond_management/pond_management_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/ai_doctor/ai_fish_doctor_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/feed_management/feed_management_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/marketplace/sell_fish_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/water_testing/water_testing_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/expert_advice/expert_advice_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/transport/fish_transport_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/market_price/fish_market_price_screen.dart';
import 'package:agrolinkbd/presentation/screens/card/card_preview_screen.dart' as agrolinkbd;
import 'package:agrolinkbd/core/utils/responsive_helper.dart';
import 'package:agrolinkbd/presentation/widgets/responsive_web_wrapper.dart';
import 'package:agrolinkbd/presentation/widgets/weather_card_widget.dart';

class FishFarmerDashboard extends StatefulWidget {
  const FishFarmerDashboard({super.key});

  @override
  State<FishFarmerDashboard> createState() => _FishFarmerDashboardState();
}

class _FishFarmerDashboardState extends State<FishFarmerDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _tickerScrollController;

  // Mock Tasks State
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'পুকুর-১ এ মাছের খাবার দেওয়া', 'completed': false},
    {'title': 'পুকুর-২ এর পানি পরীক্ষা করা', 'completed': false},
    {'title': 'নতুন পোনা ছাড়ার প্রস্তুতি', 'completed': true},
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
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
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
                                    final userName = userProvider.currentUser?.name ?? 'মৎস্য চাষী';
                                    return Text(
                                      'স্বাগতম, $userName',
                                      style: GoogleFonts.hindSiliguri(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : deepAqua,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  }
                                ),
                                const SizedBox(height: 8),
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
                                            fontSize: 14.0,
                                            label: 'Tap to view',
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
                              Icon(Icons.notifications_outlined, color: isDark ? Colors.white : Colors.black87, size: 28),
                              Positioned(
                                right: -2,
                                top: -2,
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
                      
                      const SizedBox(height: 24),

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

                      const SizedBox(height: 24),

                      // Quick Actions Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'জরুরী সেবা',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildQuickActionsGrid(oceanBlue, deepAqua),
                      ),

                      const SizedBox(height: 24),

                      // Tasks Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'আজকের কাজ',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'সব দেখুন',
                              style: GoogleFonts.hindSiliguri(
                                color: oceanBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ..._tasks.map((task) => _buildTaskItem(
                        task['title'], 
                        task['completed'], 
                        oceanBlue
                      )).toList(),

                      const SizedBox(height: 24),

                      // Activity Report Generation
                      Text(
                        'অ্যাক্টিভিটি রিপোর্ট',
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
                            userName: userProvider.currentUser?.name ?? 'মৎস্য চাষী',
                            userId: _userId,
                            userRole: 'fishFarmer',
                            amount1Label: 'মোট আয়',
                            amount2Label: 'মোট ব্যয়',
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

  Widget _buildWaterQualityAlertCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF29B6F6), Color(0xFF0277BD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0277BD).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'পুকুরের পানির গুণমান',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'pH 7.2',
                    style: GoogleFonts.poppins(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Text(
                      'স্বাভাবিক',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'পুকুর-২ এ অ্যামোনিয়া বেশি',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          const Icon(Icons.water_drop, size: 70, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(Color oceanBlue, Color deepAqua) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: ResponsiveHelper.isPhone(context) ? 4 : (ResponsiveHelper.isTablet(context) ? 6 : 8),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: ResponsiveHelper.isPhone(context) ? 0.85 : 1.1,
      children: [
        // Row 1
        _ActionCard(
          title: 'পুকুর ব্যবস্থাপনা',
          icon: Icons.pool,
          color: oceanBlue,
          onTap: () => Get.to(() => const PondManagementScreen()),
        ),
        _ActionCard(
          title: 'এআই মাছের ডাক্তার',
          icon: Icons.health_and_safety,
          color: Colors.teal.shade600,
          onTap: () => Get.to(() => const AIFishDoctorScreen()),
        ),
        _ActionCard(
          title: 'খাদ্য ব্যবস্থাপনা',
          icon: Icons.inventory_2,
          color: Colors.orange.shade600,
          onTap: () => Get.to(() => const FeedManagementScreen()),
        ),
        _ActionCard(
          title: 'মাছ বিক্রি',
          icon: Icons.storefront,
          color: Colors.green.shade600,
          onTap: () => Get.to(() => const SellFishScreen()),
        ),
        
        // Row 2
        _ActionCard(
          title: 'পানি পরীক্ষা',
          icon: Icons.science,
          color: Colors.cyan.shade600,
          onTap: () => Get.to(() => const WaterTestingScreen()),
        ),
        _ActionCard(
          title: 'বিশেষজ্ঞ পরামর্শ',
          icon: Icons.support_agent,
          color: Colors.indigo.shade600,
          onTap: () => Get.to(() => const ExpertAdviceScreen()),
        ),
        _ActionCard(
          title: 'পরিবহন',
          icon: Icons.local_shipping,
          color: deepAqua,
          onTap: () => Get.to(() => const FishTransportScreen()),
        ),
        _ActionCard(
          title: 'বাজার দর',
          icon: Icons.show_chart,
          color: Colors.purple.shade500,
          onTap: () => Get.to(() => const FishMarketPriceScreen()),
        ),
      ],
    );
  }

  Widget _buildTaskItem(String title, bool completed, Color activeColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            fontSize: 15,
            decoration: completed ? TextDecoration.lineThrough : null,
            color: completed ? Colors.grey : (isDark ? Colors.white : Colors.black87),
          ),
        ),
        trailing: Icon(Icons.more_vert, color: Colors.grey.shade400),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.hindSiliguri(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
