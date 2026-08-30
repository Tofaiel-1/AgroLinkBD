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

  @override
  Widget build(BuildContext context) {
    // Nature inspired color palette
    const Color emeraldGreen = Color(0xFF2E7D32);
    const Color earthyBrown = Color(0xFF795548);
    const Color cleanWhite = Color(0xFFFFFFFF);
    const Color lightBackground = Color(0xFFF5F7FA);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: lightBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: cleanWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                              backgroundColor: emeraldGreen.withOpacity(0.15),
                              backgroundImage: (photo != null && photo.isNotEmpty)
                                  ? NetworkImage(photo) as ImageProvider
                                  : null,
                              child: (photo == null || photo.isEmpty)
                                  ? const Icon(Icons.person, color: Color(0xFF2E7D32), size: 22)
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
                            upa = 'গুরুদাসপুর';
                            dist = 'নাটোর';
                          }
                          if (upa.isEmpty && user?.address != null) {
                            final addr = user!.address!.toLowerCase();
                            if (addr.contains('gurudaspur') || addr.contains('গুরুদাসপুর')) {
                              upa = 'গুরুদাসপুর';
                              dist = 'নাটোর';
                            } else if (addr.contains('singra') || addr.contains('সিংড়া')) {
                              upa = 'সিংড়া';
                              dist = 'নাটোর';
                            } else if (addr.contains('natore') || addr.contains('নাটোর')) {
                              upa = 'নাটোর সদর';
                              dist = 'নাটোর';
                            }
                          }
                          final locText = upa.isNotEmpty
                              ? '$upa, $dist'
                              : (dist.isNotEmpty ? dist : 'গুরুদাসপুর, নাটোর');

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${FarmerTranslations.tr(context, 'good_morning')},',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                userName,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
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
                          color: emeraldGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: emeraldGreen.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.account_balance_wallet, size: 16, color: emeraldGreen),
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
                                  label: 'Tap to view',
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
                              const Icon(Icons.notifications_outlined, color: Colors.black87, size: 28),
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
                    // 1. Hire a Truck Transport Banner
                    InkWell(
                      onTap: () => Get.to(() => const UpazilaTransportScreen()),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.orange.shade700.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.shade700.withValues(alpha: 0.08),
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
                                color: Colors.orange.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.local_shipping, color: Colors.orange.shade800, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LanguageProvider.isBn(context) ? 'জরুরি ট্রাক ও পরিবহন ভাড়া 🚛' : 'Hire a Truck Transport 🚛',
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange.shade900,
                                    ),
                                  ),
                                  Text(
                                    FarmerTranslations.tr(context, 'emergency_transport'),
                                    style: GoogleFonts.hindSiliguri(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange.shade800),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Global Announcements Banner
                    const GlobalAnnouncementBanner(),
                    const SizedBox(height: 12),
                    
                    // 2. Sleek & Compact Weather Card
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
                    
                    // 2. Quick Actions Grid
                    Text(
                      FarmerTranslations.tr(context, 'quick_actions'),
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActionsGrid(context, emeraldGreen, earthyBrown),
                    const SizedBox(height: 24),

                    // Premium Agro Services Section (Right below Quick Actions)
                    PremiumAgroServicesSection(
                      isBn: LanguageProvider.isBn(context),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 24),

                    // 3. Today's Tasks
                    Text(
                      LanguageProvider.isBn(context) ? 'আজকের কাজ (Daily Tasks)' : 'Daily Tasks',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTasksChecklist(emeraldGreen),
                    const SizedBox(height: 24),

                    // 4. Market Price Ticker
                    Text(
                      LanguageProvider.isBn(context) ? 'লাইভ বাজার দর' : 'Live Market Price',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMarketPriceTicker(),
                    const SizedBox(height: 24),
                    
                    // 5. Activity Report Generation
                    Text(
                      LanguageProvider.isBn(context) ? 'অ্যাক্টিভিটি রিপোর্ট' : 'Activity Report',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        return ReportGenerationCard(
                          userName: userProvider.currentUser?.name ?? 'কৃষক',
                          userId: _userId,
                          userRole: 'farmer',
                          amount1Label: LanguageProvider.isBn(context) ? 'মোট আয়' : 'Total Income',
                          amount2Label: LanguageProvider.isBn(context) ? 'মোট খরচ' : 'Total Expense',
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
    final bool isBn = LanguageProvider.isBn(context);
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 4,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        // Row 1
        _ActionCard(
          title: isBn ? 'ফসল বিক্রি' : 'Sell Crop',
          icon: Icons.storefront,
          color: emeraldGreen,
          onTap: () => Get.to(() => const AddProductScreen()),
        ),
        _ActionCard(
          title: isBn ? 'জরুরি সেবা' : 'Emergency',
          icon: Icons.emergency_rounded,
          color: Colors.red.shade700,
          onTap: () => Get.to(() => const EmergencyWeatherServicesScreen()),
        ),
        _ActionCard(
          title: isBn ? 'রোগ নির্ণয়' : 'Disease Check',
          icon: Icons.biotech,
          color: Colors.teal.shade700,
          onTap: () => Get.to(() => const DiseaseDetectionScreen()),
        ),
        _ActionCard(
          title: isBn ? 'ফসল উপযোগিতা' : 'Suitability',
          icon: Icons.agriculture,
          color: Colors.green.shade600,
          onTap: () => Get.to(() => const AgriInfoHubScreen(initialFeature: 'suitability')),
        ),
        _ActionCard(
          title: isBn ? 'সার সুপারিশ' : 'Fertilizer',
          icon: Icons.science,
          color: Colors.lightGreen.shade700,
          onTap: () => Get.to(() => const AgriInfoHubScreen(initialFeature: 'fertilizer')),
        ),
        // Row 2
        _ActionCard(
          title: isBn ? 'ফসল জোন' : 'Crop Zone',
          icon: Icons.map,
          color: Colors.blue.shade600,
          onTap: () => Get.to(() => const AgriInfoHubScreen(initialFeature: 'zone')),
        ),
        _ActionCard(
          title: isBn ? 'ফসল বিন্যাস' : 'Crop Pattern',
          icon: Icons.view_module,
          color: Colors.orange.shade600,
          onTap: () => Get.to(() => const AgriInfoHubScreen(initialFeature: 'pattern')),
        ),
        _ActionCard(
          title: isBn ? 'সংরক্ষিত' : 'Saved Data',
          icon: Icons.bookmark,
          color: Colors.indigo.shade500,
          onTap: () => Get.to(() => const SavedAgriDataScreen()),
        ),
        _ActionCard(
          title: isBn ? 'মাটির গুণাগুণ' : 'Soil Health',
          icon: Icons.landscape,
          color: earthyBrown,
          onTap: () => Get.to(() => const AgriInfoHubScreen(initialFeature: 'soil')),
        ),
        // Row 3
        _ActionCard(
          title: isBn ? 'বিশেষজ্ঞ' : 'Expert',
          icon: Icons.support_agent,
          color: Colors.indigo.shade600,
          onTap: () => Get.to(() => const AgriInfoHubScreen(initialFeature: 'disease')),
        ),
        _ActionCard(
          title: isBn ? 'পরিবহন' : 'Transport',
          icon: Icons.local_shipping,
          color: earthyBrown,
          onTap: () => Get.to(() => const UpazilaTransportScreen()),
        ),
        _ActionCard(
          title: isBn ? 'পেমেন্ট' : 'Payment',
          icon: Icons.payment,
          color: Colors.orange.shade700,
          onTap: () => Get.to(() => DirectTransferScreen(senderId: _userId)),
        ),
        _ActionCard(
          title: isBn ? 'লোন/ঋণ' : 'Agri Loan',
          icon: Icons.account_balance_rounded,
          color: Colors.blue.shade700,
          onTap: () {
            Get.to(() => MicrofinanceKycScreen(userRole: 'farmer', loanType: 'Farmer Crop Loan'));
          },
        ),
      ],
    );
  }

  Widget _buildTasksChecklist(Color emeraldGreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                      color: task['completed'] ? Colors.grey : Colors.black87,
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
                Divider(height: 1, color: Colors.grey.shade200, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMarketPriceTicker() {
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
                    color: Colors.black87,
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
                        color: Colors.grey.shade700,
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 26, color: widget.color),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
