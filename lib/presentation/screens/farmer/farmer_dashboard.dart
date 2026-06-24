import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/presentation/screens/disease/disease_detection_screen.dart';
import 'package:agrolinkbd/presentation/screens/farmer/add_product_screen.dart';
import 'package:agrolinkbd/presentation/screens/payment/direct_transfer_screen.dart';
import 'package:agrolinkbd/core/services/transaction_service.dart';
import 'package:agrolinkbd/presentation/screens/wallet/wallet_screen.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/presentation/widgets/global_announcement_banner.dart';

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
    {'title': 'ধান ক্ষেতে সার প্রয়োগ করা', 'completed': false},
    {'title': 'টমেটো গাছে কীটনাশক স্প্রে করা', 'completed': false},
    {'title': 'পুকুরের মাছের খাবার দেওয়া', 'completed': true},
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
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: emeraldGreen, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 20,
                        backgroundImage: NetworkImage('https://randomuser.me/api/portraits/men/44.jpg'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        final userName = userProvider.currentUser?.name ?? 'কৃষক';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'শুভ সকাল,',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              userName,
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
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
                            Text(
                              '৳ $_balance',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: emeraldGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_outlined, color: Colors.black87, size: 28),
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
                              '3',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
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
                    // Global Announcements
                    const GlobalAnnouncementBanner(),
                    const SizedBox(height: 16),
                    
                    // 1. Weather Alert Card
                    _buildWeatherAlertCard(),
                    const SizedBox(height: 24),
                    
                    // 2. Quick Actions Grid
                    Text(
                      'জরুরী সেবাসমূহ',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildQuickActionsGrid(emeraldGreen, earthyBrown),
                    const SizedBox(height: 24),

                    // 3. Today's Tasks
                    Text(
                      'আজকের কাজ (Daily Tasks)',
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
                      'লাইভ বাজার দর',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMarketPriceTicker(),
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

  Widget _buildWeatherAlertCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF0288D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0288D1).withOpacity(0.3),
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
                'আজকের আবহাওয়া',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '২৮°C',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'আজ বৃষ্টির সম্ভাবনা আছে',
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
          const Icon(Icons.cloudy_snowing, size: 80, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(Color emeraldGreen, Color earthyBrown) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _ActionCard(
          title: 'ফসল বিক্রি',
          icon: Icons.eco,
          color: emeraldGreen,
          onTap: () => Get.to(() => const AddProductScreen()),
        ),
        _ActionCard(
          title: 'এআই প্ল্যান্ট ডাক্তার',
          icon: Icons.camera_alt,
          color: Colors.teal.shade700,
          onTap: () => Get.to(() => const DiseaseDetectionScreen()),
        ),
        _ActionCard(
          title: 'বিশেষজ্ঞ পরামর্শ',
          icon: Icons.support_agent,
          color: Colors.indigo.shade600,
          onTap: () => Get.snackbar('বিশেষজ্ঞ পরামর্শ', 'শীঘ্রই যুক্ত করা হবে!'),
        ),
        _ActionCard(
          title: 'পরিবহন (Transport)',
          icon: Icons.local_shipping,
          color: earthyBrown,
          onTap: () => Get.snackbar('পরিবহন সেবা', 'ট্রাক বুকিং শীঘ্রই আসছে!'),
        ),
        _ActionCard(
          title: 'পেমেন্ট (Payment)',
          icon: Icons.payment,
          color: Colors.orange.shade700,
          onTap: () => Get.to(() => DirectTransferScreen(senderId: _userId)),
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
              CheckboxListTile(
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
                  child: Text(task['title']),
                ),
                onChanged: (bool? val) {
                  setState(() {
                    _tasks[index]['completed'] = val ?? false;
                  });
                },
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
      {'crop': 'বোরো ধান', 'price': '৳১২০০/মণ', 'trend': 'up', 'color': Colors.green},
      {'crop': 'আলু', 'price': '৳৩৫/কেজি', 'trend': 'down', 'color': Colors.red},
      {'crop': 'পেঁয়াজ', 'price': '৳৯০/কেজি', 'trend': 'up', 'color': Colors.green},
      {'crop': 'টমেটো', 'price': '৳৩০/কেজি', 'trend': 'down', 'color': Colors.red},
      {'crop': 'রসুন', 'price': '৳১৮০/কেজি', 'trend': 'up', 'color': Colors.green},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        controller: _tickerScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 20, // Looping items artificially
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
                  item['crop']!,
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
                      item['price']!,
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
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 36, color: widget.color),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.hindSiliguri(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
