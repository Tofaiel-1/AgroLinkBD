import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart' as prov;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agrolinkbd/core/providers/payment_provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/providers/driver_notification_provider.dart';
import 'package:agrolinkbd/presentation/widgets/premium_dashboard_widgets.dart';
import 'package:agrolinkbd/presentation/screens/analytics/driver_analytics.dart';
import 'package:agrolinkbd/presentation/screens/maps/driver_delivery_map.dart';
import 'package:agrolinkbd/presentation/screens/notifications/driver_notifications.dart';
import 'package:agrolinkbd/presentation/widgets/global_announcement_banner.dart';

/// Driver Role Dashboard
/// Displays trip overview, earnings, available jobs, and performance metrics
class DriverDashboard extends ConsumerStatefulWidget {
  const DriverDashboard({super.key});

  @override
  ConsumerState<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends ConsumerState<DriverDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _hasActiveTrip = false;
  Map<String, dynamic>? _activeTrip;
  bool _isLoadingPayment = false;

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
    final userProvider = prov.Provider.of<UserProvider>(context);
    final userId = userProvider.currentUser?.id ?? 'driver_mock_id';
    final walletBalanceAsync = ref.watch(walletBalanceProvider(userId));
    final pendingBalanceAsync = ref.watch(pendingBalanceProvider(userId));
    final walletBalance = walletBalanceAsync.value ?? 0.0;
    final pendingBalance = pendingBalanceAsync.value ?? 0.0;
    final unreadNotificationCount = ref.watch(unreadDriverNotificationCountProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // ============================================
            // HEADER - Driver Status & Earnings
            // ============================================
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: const Color(0xFFF57C00),
              actions: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none, color: Colors.white),
                      onPressed: () {
                        Get.to(() => const DriverNotificationsScreen());
                      },
                    ),
                    if (unreadNotificationCount > 0)
                      Positioned(
                        right: 8,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadNotificationCount',
                            style: const TextStyle(
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
                    if (value == 'logout') {
                      _showLogoutDialog(context);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, size: 18),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
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
                      colors: [
                        Color(0xFFF57C00),
                        Color(0xFFE65100),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned(
                        right: -50,
                        top: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Greeting
                            Text(
                              'স্বাগতম, চালক! 🚚',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Status
                            Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'অনলাইন - ট্রিপের জন্য প্রস্তুত',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Earnings and stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'আজকের আয়',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '৳ ${walletBalance.toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ট্রিপ সম্পন্ন',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '১২/১৫',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
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
              ),
            ),
            
            // ============================================
            // GLOBAL ANNOUNCEMENTS
            // ============================================
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: GlobalAnnouncementBanner(),
              ),
            ),

            // ============================================
            // ACTIVE TRIP STATUS
            // ============================================
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'বর্তমান ট্রিপ',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Active trip card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ট্রিপ #TR2024-05821',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'ডেলিভারিতে',
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Route info
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 20,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'শুরু : ধানমন্ডি মার্কেট',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'শেষ: গুলশান ২',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '৳ 350',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Distance and time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Icon(
                                    Icons.near_me,
                                    size: 18,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '৪.৫ কিমি',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(
                                    Icons.timer,
                                    size: 18,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '২৫ মিনিট',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Icon(
                                    Icons.speed,
                                    size: 18,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '২৮ কিমি/ঘ',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: Material(
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(() =>
                                          const DriverDeliveryMapScreen());
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF57C00)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.navigation,
                                            size: 16,
                                            color: Color(0xFFF57C00),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'মানচিত্র দেখুন',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: const Color(0xFFF57C00),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Material(
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(
                                          () => const DriverAnalyticsScreen());
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.analytics,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'বিশ্লেষণ দেখুন',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ============================================
            // PERFORMANCE METRICS
            // ============================================
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        const PremiumStatCard(
                          icon: Icons.star_rounded,
                          color: Color(0xFFFF8F00),
                          label: 'আপনার রেটিং',
                          value: '৪.৯',
                          subtitle: '৪৫টি রিভিউ',
                        ),
                        const PremiumStatCard(
                          icon: Icons.timer,
                          color: Color(0xFF1976D2),
                          label: 'সময়ানুবর্তিতা',
                          value: '৯৮%',
                          subtitle: 'এই মাসে',
                        ),
                        const PremiumStatCard(
                          icon: Icons.check_circle_outline,
                          color: Color(0xFF388E3C),
                          label: 'সম্পন্ন ট্রিপ',
                          value: '২৮৫',
                          subtitle: 'মোট ট্রিপ',
                        ),
                        PremiumStatCard(
                          icon: Icons.account_balance_wallet,
                          color: Color(0xFF7B1FA2),
                          label: 'এই মাসের আয়',
                          value: '৳ ${walletBalance.toStringAsFixed(0)}',
                          subtitle: '+১২% বৃদ্ধি',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Transactions Section
                    PremiumSectionTitle(
                      title: 'সাম্প্রতিক লেনদেন',
                      onSeeAll: () {},
                    ),
                    const PremiumTransactionCard(
                      title: 'ট্রিপ #TR2024-05810',
                      date: 'আজ, সকাল ৯:১৫',
                      amount: '৳ 1,850',
                      isCredit: true,
                      status: 'Completed',
                    ),
                    const PremiumTransactionCard(
                      title: 'তেল খরচ',
                      date: 'গতকাল, বিকেল ৫:৩০',
                      amount: '৳ 1,500',
                      isCredit: false,
                      status: 'Completed',
                    ),
                  ],
                ),
              ),
            ),

            // ============================================
            // AVAILABLE JOBS
            // ============================================
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'উপলব্ধ ট্রিপ',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '৫ নতুন',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._buildAvailableJobs(),
                  ],
                ),
              ),
            ),

            // ============================================
            // TRIP HISTORY
            // ============================================
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'আজকের ট্রিপ',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.snackbar('ইতিহাস', 'সব ট্রিপ দেখুন');
                          },
                          child: const Text('সব দেখুন'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._buildTripHistory(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build metric cards

  Widget _buildActiveTripCard(String userId) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ট্রিপ #TR2024-05821',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'ডেলিভারিতে',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 20, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('শুরু: ${_activeTrip!['pickup']}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                    const SizedBox(height: 2),
                    Text('শেষ: ${_activeTrip!['delivery']}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Text(
                _activeTrip!['pay'],
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _isLoadingPayment
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          setState(() => _isLoadingPayment = true);
                          final amountStr = _activeTrip!['pay'].toString().replaceAll(RegExp(r'[^0-9]'), '');
                          final amount = double.tryParse(amountStr) ?? 0.0;
                          final amountAfterCommission = amount * 0.95; // 5% platform fee
                          
                          final success = await ref.read(transactionNotifierProvider.notifier).releaseEscrow(
                            userId: userId,
                            amount: amountAfterCommission,
                            reason: 'Trip Completed: ${_activeTrip!['pickup']} to ${_activeTrip!['delivery']}',
                          );
                          
                          setState(() {
                            _isLoadingPayment = false;
                            if (success) {
                              _hasActiveTrip = false;
                              _activeTrip = null;
                              Get.snackbar('সফল', 'ডেলিভারি সম্পন্ন এবং পেমেন্ট ওয়ালেটে যুক্ত হয়েছে।',
                                  backgroundColor: Colors.green, colorText: Colors.white);
                            } else {
                              Get.snackbar('ত্রুটি', 'পেমেন্ট প্রসেস করতে সমস্যা হয়েছে।',
                                  backgroundColor: Colors.red, colorText: Colors.white);
                            }
                          });
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('ডেলিভারি সম্পন্ন'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
  Widget _buildMetricCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Build available jobs
  List<Widget> _buildAvailableJobs() {
    final jobs = [
      {
        'pickup': 'মতিঝিল',
        'delivery': 'তেজগাঁও',
        'distance': '৫.২ কিমি',
        'pay': '৳ ৫৫০',
        'urgency': 'দ্রুত',
        'color': Colors.red,
      },
      {
        'pickup': 'গুলশান',
        'delivery': 'বনানী',
        'distance': '৩.৮ কিমি',
        'pay': '৳ ৩৫০',
        'urgency': 'স্বাভাবিক',
        'color': Colors.blue,
      },
    ];

    return jobs
        .map((job) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                child: InkWell(
                  onTap: () {
                    Get.snackbar(
                      'ট্রিপ গৃহীত',
                      '${job['pickup']} থেকে ${job['delivery']}',
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Route icon
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: (job['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.directions_car,
                            color: job['color'] as Color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Route details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${job['pickup']} â†’ ${job['delivery']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${job['distance']} â€¢ ${job['urgency']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Pay
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              job['pay'] as String,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ))
        .toList();
  }

  // Build trip history
  List<Widget> _buildTripHistory() {
    final trips = [
      {
        'id': '#TR2024-05820',
        'route': 'ধানমন্ডি -> ফার্মগেট',
        'pay': '৳ ২৫০',
        'status': 'সম্পন্ন',
        'color': Colors.green,
      },
      {
        'id': '#TR2024-05819',
        'route': 'তেজগাঁও -> মোহাম্মদপুর',
        'pay': '৳ ৩৫০',
        'status': 'সম্পন্ন',
        'color': Colors.green,
      },
    ];

    return trips
        .map((trip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip['id'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trip['route'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          trip['pay'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (trip['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            trip['status'] as String,
                            style: GoogleFonts.poppins(
                              fontSize: 9,
                              color: trip['color'] as Color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ))
        .toList();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final userProvider =
                    prov.Provider.of<UserProvider>(context, listen: false);
                await userProvider.signOut();
                // AppRouter will detect auth state change and redirect to LoginScreen
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
