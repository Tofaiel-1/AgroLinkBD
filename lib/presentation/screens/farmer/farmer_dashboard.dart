import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/presentation/screens/disease/disease_detection_screen.dart';
import 'package:agrolinkbd/presentation/screens/farmer/add_product_screen.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/localization/farmer_translations.dart';
import 'package:agrolinkbd/presentation/screens/card/card_preview_screen.dart' as agrolinkbd;
import 'package:agrolinkbd/presentation/screens/payment/direct_transfer_screen.dart';
import 'package:agrolinkbd/presentation/screens/microfinance/microfinance_kyc_screen.dart';
import 'package:agrolinkbd/presentation/screens/transport/upazila_transport_screen.dart';
import 'package:agrolinkbd/core/services/transaction_service.dart';
import 'package:agrolinkbd/presentation/screens/wallet/wallet_screen.dart';
import 'package:agrolinkbd/presentation/widgets/secure_balance_widget.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/presentation/widgets/global_announcement_banner.dart';
import 'package:agrolinkbd/presentation/widgets/report_generation_card.dart';
import 'package:agrolinkbd/presentation/screens/agri_info/agri_info_hub_screen.dart';
import 'package:agrolinkbd/presentation/screens/agri_info/saved_agri_data_screen.dart';
import 'package:agrolinkbd/presentation/widgets/weather_card_widget.dart';
import 'package:agrolinkbd/presentation/screens/agri_info/emergency_weather_services_screen.dart';
import 'package:agrolinkbd/presentation/screens/notifications/farmer_notifications.dart';
import 'package:agrolinkbd/presentation/screens/home/widgets/premium_agro_services_section.dart';
import 'package:agrolinkbd/presentation/screens/analytics/farmer_analytics.dart';
import 'package:agrolinkbd/presentation/screens/farmer/tools/farm_smart_calculator_sheet.dart';
import 'package:agrolinkbd/presentation/screens/hub/upazila_hub_network_screen.dart';
import 'package:agrolinkbd/presentation/screens/hub/union_hub_network_screen.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _tickerScrollController;

  // Mock Tasks State
  final List<Map<String, dynamic>> _tasks = [
    {'title': 'ধান ক্ষেতে সার প্রয়োগ করা', 'titleEN': 'Apply fertilizer to rice field', 'completed': false},
    {'title': 'টমেটো গাছে কীটনাশক স্প্রে করা', 'titleEN': 'Spray pesticide on tomato plants', 'completed': false},
    {'title': 'পুকুরের মাছের খাবার দেওয়া', 'titleEN': 'Feed pond fish', 'completed': true},
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

  String _getTimeGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return FarmerTranslations.tr(context, 'good_morning');
    } else if (hour >= 12 && hour < 16) {
      return FarmerTranslations.tr(context, 'good_afternoon');
    } else if (hour >= 16 && hour < 19) {
      return FarmerTranslations.tr(context, 'good_evening');
    } else {
      return FarmerTranslations.tr(context, 'good_night');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isBn = LanguageProvider.isBn(context);

    // Nature inspired dynamic color palette
    final Color emeraldGreen = isDark ? const Color(0xFF66BB6A) : const Color(0xFF2E7D32);
    final Color earthyBrown = isDark ? const Color(0xFFA1887F) : const Color(0xFF795548);
    final Color screenBg = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final Color headerBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color primaryText = isDark ? Colors.white : Colors.black87;
    final Color secondaryText = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: headerBg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Get.to(() => const agrolinkbd.CardPreviewScreen());
                  },
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: emeraldGreen, width: 2),
                        ),
                        child: Consumer<UserProvider>(
                          builder: (context, up, _) {
                            final photo = up.currentUser?.profileImage;
                            return CircleAvatar(
                              radius: 20,
                              backgroundColor: emeraldGreen.withValues(alpha: 0.15),
                              backgroundImage: (photo != null && photo.isNotEmpty)
                                  ? NetworkImage(photo) as ImageProvider
                                  : null,
                              child: (photo == null || photo.isEmpty)
                                  ? Icon(Icons.person, color: emeraldGreen, size: 22)
                                  : null,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, _) {
                          final user = userProvider.currentUser;
                          final userName = user?.name ?? FarmerTranslations.tr(context, 'farmer');
                          String upa = user?.upazila ?? '';
                          String dist = user?.district ?? '';
                          if (dist.toLowerCase() == 'joypurhat' || (upa.isEmpty && dist.isEmpty)) {
                            upa = isBn ? 'গুরুদাসপুর' : 'Gurudaspur';
                            dist = isBn ? 'নাটোর' : 'Natore';
                          }
                          if (upa.isEmpty && user?.address != null) {
                            final addr = user!.address!.toLowerCase();
                            if (addr.contains('gurudaspur') || addr.contains('গুরুদাসপুর')) {
                              upa = isBn ? 'গুরুদাসপুর' : 'Gurudaspur';
                              dist = isBn ? 'নাটোর' : 'Natore';
                            } else if (addr.contains('singra') || addr.contains('সিংড়া')) {
                              upa = isBn ? 'সিংড়া' : 'Singra';
                              dist = isBn ? 'নাটোর' : 'Natore';
                            } else if (addr.contains('natore') || addr.contains('নাটোর')) {
                              upa = isBn ? 'নাটোর সদর' : 'Natore Sadar';
                              dist = isBn ? 'নাটোর' : 'Natore';
                            }
                          }
                          final locText = upa.isNotEmpty
                              ? '$upa, $dist'
                              : (dist.isNotEmpty ? dist : (isBn ? 'গুরুদাসপুর, নাটোর' : 'Gurudaspur, Natore'));

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${_getTimeGreeting(context)},',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 12,
                                  color: secondaryText,
                                ),
                              ),
                              Text(
                                userName,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: primaryText,
                                  height: 1.1,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.location_on, size: 12, color: emeraldGreen),
                                  const SizedBox(width: 3),
                                  Text(
                                    locText,
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: emeraldGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    GestureDetector(
                  onTap: () {
                    Get.to(() => WalletScreen(userId: _userId))?.then((_) => _fetchBalance());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: emeraldGreen.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: emeraldGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet, size: 16, color: emeraldGreen),
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
                              textColor: emeraldGreen,
                              fontSize: 14.0,
                              label: FarmerTranslations.tr(context, 'tap_to_view'),
                            );
                          }
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Get.to(() => const FarmerNotificationsScreen()),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(_userId)
                        .collection('notifications')
                        .where('isRead', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snap) {
                      final count = snap.hasData ? snap.data!.docs.length : 0;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Icon(Icons.notifications_outlined, color: primaryText, size: 28),
                          if (count > 0)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  count > 9 ? '9+' : '$count',
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Global Announcements Banner
                    const GlobalAnnouncementBanner(),
                    const SizedBox(height: 12),
                    
                    // 1. Sleek & Compact Weather Card
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        final user = userProvider.currentUser;
                        return WeatherCardWidget(
                          customDistrict: user?.district,
                          customUpazila: user?.upazila,
                          isCompact: true,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Masterclass Live Farm Analytics Bento Card
                    GestureDetector(
                      onTap: () => Get.to(() => const FarmerAnalyticsScreen()),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                : [const Color(0xFF006A4E), const Color(0xFF1B5E20)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF006A4E).withValues(alpha: 0.28),
                              blurRadius: 14,
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
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 22),
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isBn ? 'খামার বিশ্লেষণ ও স্মার্ট ইনসাইটস 📊' : 'Farm Analytics & Insights 📊',
                                          style: GoogleFonts.hindSiliguri(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          isBn ? 'রিয়েল-টাইম আয়, ব্যয়, ফলন ও এআই বাজার পূর্বাভাস' : 'Real-time ROI, Yield & AI Market Forecast',
                                          style: GoogleFonts.hindSiliguri(
                                            fontSize: 11,
                                            color: Colors.white.withValues(alpha: 0.85),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Text(isBn ? 'স্বাস্থ্য সূচক' : 'Health Score', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
                                      const SizedBox(height: 2),
                                      Text(isBn ? '৮৮% (চমৎকার)' : '88% (Optimal)', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                                    ],
                                  ),
                                  Container(height: 24, width: 1, color: Colors.white.withValues(alpha: 0.25)),
                                  Column(
                                    children: [
                                      Text(isBn ? 'চলতি লাভ মার্জিন' : 'Profit Margin', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
                                      const SizedBox(height: 2),
                                      Text('+39.5% 🚀', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                                    ],
                                  ),
                                  Container(height: 24, width: 1, color: Colors.white.withValues(alpha: 0.25)),
                                  Column(
                                    children: [
                                      Text(isBn ? 'পিডিএফ রিপোর্ট' : 'PDF Statement', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.white.withValues(alpha: 0.8))),
                                      const SizedBox(height: 2),
                                      Text(isBn ? 'সার্টিফাইড ✓' : 'Certified ✓', style: GoogleFonts.hindSiliguri(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.lightGreenAccent)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // 2. Quick Actions Grid
                    Text(
                      FarmerTranslations.tr(context, 'quick_actions'),
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActionsGrid(context, emeraldGreen, earthyBrown),
                    const SizedBox(height: 24),

                    // Premium Agro Services Section
                    PremiumAgroServicesSection(
                      isBn: isBn,
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),

                    // 3. Today's Tasks
                    Text(
                      FarmerTranslations.tr(context, 'daily_tasks'),
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTasksChecklist(emeraldGreen, isDark),
                    const SizedBox(height: 24),

                    // 4. Market Price Ticker
                    Text(
                      FarmerTranslations.tr(context, 'live_market_price'),
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMarketPriceTicker(isDark),
                    const SizedBox(height: 24),
                    
                    // 5. Activity Report Generation
                    Text(
                      FarmerTranslations.tr(context, 'activity_report'),
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        return ReportGenerationCard(
                          userName: userProvider.currentUser?.name ?? FarmerTranslations.tr(context, 'farmer'),
                          userId: _userId,
                          userRole: 'farmer',
                          amount1Label: FarmerTranslations.tr(context, 'total_income'),
                          amount2Label: FarmerTranslations.tr(context, 'total_expense'),
                          color: emeraldGreen,
                        );
                      }
                    ),
                    
                    const SizedBox(height: 80), // Bottom padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, Color emeraldGreen, Color earthyBrown) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.76,
      children: [
        // Row 1
        _ActionCard(
          title: FarmerTranslations.tr(context, 'sell_crop'),
          icon: Icons.storefront,
          color: emeraldGreen,
          onTap: () => Get.to(() => const AddProductScreen()),
        ),
        _ActionCard(
          title: FarmerTranslations.tr(context, 'emergency'),
          icon: Icons.emergency_rounded,
          color: Colors.red.shade700,
          onTap: () => Get.to(() => const EmergencyWeatherServicesScreen()),
        ),
        _ActionCard(
          title: FarmerTranslations.tr(context, 'disease_check'),
          icon: Icons.biotech,
          color: Colors.teal.shade700,
          onTap: () => Get.to(() => const DiseaseDetectionScreen()),
        ),
        _ActionCard(
          title: FarmerTranslations.tr(context, 'crop_suitability'),
          icon: Icons.agriculture,
          color: Colors.green.shade600,
          onTap: () => Get.to(() => const AgriInfoHubScreen(initialFeature: 'suitability')),
        ),
        _ActionCard(
          title: FarmerTranslations.tr(context, 'fertilizer_rec'),
          icon: Icons.science,
          color: Colors.lightGreen.shade700,
          onTap: () => Get.to(() => const AgriInfoHubScreen(initialFeature: 'fertilizer')),
        ),
        // Row 2
        _ActionCard(
          title: FarmerTranslations.tr(context, 'crop_zone'),
          icon: Icons.map,
          color: Colors.blue.shade600,
          onTap: () => Get.to(() => const AgriInfoHubScreen(initialFeature: 'zone')),
        ),
        _ActionCard(
          title: FarmerTranslations.tr(context, 'crop_pattern'),
          icon: Icons.view_module,
          color: Colors.orange.shade600,
          onTap: () => Get.to(() => const AgriInfoHubScreen(initialFeature: 'pattern')),
        ),
        _ActionCard(
          title: FarmerTranslations.tr(context, 'saved_data'),
          icon: Icons.bookmark,
          color: Colors.indigo.shade500,
          onTap: () => Get.to(() => const SavedAgriDataScreen()),
        ),
        _ActionCard(
          title: FarmerTranslations.tr(context, 'soil_health'),
          icon: Icons.landscape,
          color: earthyBrown,
          onTap: () => Get.to(() => const AgriInfoHubScreen(initialFeature: 'soil')),
        ),
        // Row 3
        _ActionCard(
          title: FarmerTranslations.tr(context, 'agri_expert'),
          icon: Icons.support_agent,
          color: Colors.indigo.shade600,
          onTap: () => Get.to(() => const AgriInfoHubScreen(initialFeature: 'disease')),
        ),
        _ActionCard(
          title: FarmerTranslations.tr(context, 'transport'),
          icon: Icons.local_shipping,
          color: earthyBrown,
          onTap: () => Get.to(() => const UpazilaTransportScreen()),
        ),
        _ActionCard(
          title: FarmerTranslations.tr(context, 'payment'),
          icon: Icons.payment,
          color: Colors.orange.shade700,
          onTap: () => Get.to(() => DirectTransferScreen(senderId: _userId)),
        ),
        _ActionCard(
          title: FarmerTranslations.tr(context, 'agri_loan'),
          icon: Icons.account_balance_rounded,
          color: Colors.blue.shade700,
          onTap: () {
            Get.to(() => const MicrofinanceKycScreen(userRole: 'farmer', loanType: 'Farmer Crop Loan'));
          },
        ),
        _ActionCard(
          title: LanguageProvider.isBn(context) ? 'স্মার্ট ক্যালকুলেটর' : 'Smart Tools',
          icon: Icons.calculate_rounded,
          color: const Color(0xFF006A4E),
          onTap: () => FarmSmartCalculatorSheet.show(context),
        ),
        _ActionCard(
          title: LanguageProvider.isBn(context) ? 'উপজেলা হাব ও QC' : 'Upazila Hub & QC',
          icon: Icons.hub,
          color: const Color(0xFF15803D),
          onTap: () => Get.to(() => const UpazilaHubNetworkScreen()),
        ),
        _ActionCard(
          title: LanguageProvider.isBn(context) ? '🏡 ইউনিয়ন হাব' : '🏡 Union Hub',
          icon: Icons.account_balance,
          color: const Color(0xFF166534),
          onTap: () => Get.to(() => const UnionHubNetworkScreen()),
        ),
        _ActionCard(
          title: LanguageProvider.isBn(context) ? 'Gemini এআই সহকারী' : 'Gemini AI Bot',
          icon: Icons.auto_awesome,
          color: Colors.amber.shade800,
          onTap: () => Get.to(() => const FarmerAnalyticsScreen()),
        ),
      ],
    );
  }

  Widget _buildTasksChecklist(Color emeraldGreen, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: _tasks.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> task = entry.value;
          return Column(
            children: [
              Material(
                color: Colors.transparent,
                child: CheckboxListTile(
                  value: task['completed'],
                  activeColor: emeraldGreen,
                  checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  title: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      color: task['completed'] ? Colors.grey : (isDark ? Colors.white : Colors.black87),
                      decoration: task['completed'] ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                    child: Text(LanguageProvider.isBn(context) ? task['title'] : (task['titleEN'] ?? task['title'])),
                  ),
                  onChanged: (bool? val) {
                    setState(() {
                      _tasks[index]['completed'] = val ?? false;
                    });
                  },
                ),
              ),
              if (index < _tasks.length - 1)
                Divider(height: 1, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMarketPriceTicker(bool isDark) {
    final List<Map<String, dynamic>> prices = [
      {'crop': 'বোরো ধান', 'cropEN': 'Boro Rice', 'price': '৳১২০০/মণ', 'priceEN': '৳1200/maund', 'trend': 'up', 'color': Colors.green},
      {'crop': 'আলু', 'cropEN': 'Potato', 'price': '৳৩৫/কেজি', 'priceEN': '৳35/kg', 'trend': 'down', 'color': Colors.red},
      {'crop': 'পেঁয়াজ', 'cropEN': 'Onion', 'price': '৳৯০/কেজি', 'priceEN': '৳90/kg', 'trend': 'up', 'color': Colors.green},
      {'crop': 'টমেটো', 'cropEN': 'Tomato', 'price': '৳৩০/কেজি', 'priceEN': '৳30/kg', 'trend': 'down', 'color': Colors.red},
      {'crop': 'রসুন', 'cropEN': 'Garlic', 'price': '৳১৮০/কেজি', 'priceEN': '৳180/kg', 'trend': 'up', 'color': Colors.green},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _tickerScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (context, i) {
          final item = prices[i % prices.length];
          final isUp = item['trend'] == 'up';
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
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
                  LanguageProvider.isBn(context) ? item['crop']! : (item['cropEN'] ?? item['crop']!),
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LanguageProvider.isBn(context) ? item['price']! : (item['priceEN'] ?? item['price']!),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                      ),
                    ),
                    Icon(
                      isUp ? Icons.arrow_upward : Icons.arrow_downward,
                      color: item['color'] as Color,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class _ActionCard extends StatefulWidget {
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
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.color.withValues(alpha: isDark ? 0.35 : 0.15),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: isDark ? 0.2 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(widget.icon, size: 22, color: widget.color),
                ),
                const SizedBox(height: 5),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
