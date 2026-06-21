import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/presentation/widgets/stat_card.dart';
import 'package:agrolinkbd/presentation/widgets/price_chart.dart';
import 'package:agrolinkbd/presentation/widgets/animated_card.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/enhanced_marketplace.dart';
import 'package:agrolinkbd/presentation/screens/disease/disease_detection_screen.dart';
import 'package:agrolinkbd/presentation/screens/wallet/wallet_screen.dart';
import 'package:agrolinkbd/presentation/screens/transport/transport_rental_screen.dart';
import 'package:agrolinkbd/presentation/screens/notifications/notification_center.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/presentation/screens/auth/login_screen.dart';

class EnhancedDashboard extends StatefulWidget {
  const EnhancedDashboard({super.key});

  @override
  State<EnhancedDashboard> createState() => _EnhancedDashboardState();
}

class _EnhancedDashboardState extends State<EnhancedDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF2E7D32),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('স্বাগতম, কৃষক'),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2E7D32),
                      Colors.green.shade600,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
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
                  ],
                ),
              ),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => Get.to(() => const NotificationCenter()),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showMenu(
                    context: context,
                    position: const RelativeRect.fromLTRB(100, 80, 0, 0),
                    items: [
                      PopupMenuItem(
                        value: 'theme',
                        child: Obx(() {
                          bool isDark = Get.isDarkMode;
                          return Row(
                            children: [
                              Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                                  size: 20),
                              const SizedBox(width: 12),
                              Text(isDark ? 'Light Mode' : 'Dark Mode'),
                            ],
                          );
                        }),
                        onTap: () {
                          _toggleTheme();
                        },
                      ),
                      PopupMenuItem(
                        value: 'settings',
                        child: const Row(
                          children: [
                            Icon(Icons.settings, size: 20),
                            SizedBox(width: 12),
                            Text('Settings'),
                          ],
                        ),
                        onTap: () {
                          // Navigate to settings if needed
                        },
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: const Row(
                          children: [
                            Icon(Icons.logout, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Logout', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                        onTap: () {
                          _showLogoutConfirmation(context);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),

          // Stats Grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    title: 'মোট বিক্রয়',
                    value: '৳২৫,৪০০',
                    icon: Icons.trending_up,
                    color: Colors.green,
                    subtitle: '+১৫% এই মাসে',
                    onTap: () {},
                  ),
                  StatCard(
                    title: 'আদেশ',
                    value: '৩৪',
                    icon: Icons.shopping_bag,
                    color: Colors.blue,
                    subtitle: '৮ টি নতুন',
                    onTap: () {},
                  ),
                  StatCard(
                    title: 'পণ্য স্টক',
                    value: '১২৮',
                    icon: Icons.inventory_2,
                    color: Colors.orange,
                    onTap: () {},
                  ),
                  StatCard(
                    title: 'রেটিং',
                    value: '4.8',
                    icon: Icons.star,
                    color: Colors.amber,
                    subtitle: '২৫০+ রিভিউ',
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Price Chart
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: PriceChart(
                prices: [250, 280, 265, 290, 310, 305, 320],
                labels: ['সোম', 'মঙ্গল', 'বুধ', 'বৃহ', 'শুক্র', 'শনি', 'রবি'],
              ),
            ),
          ),

          // Quick Actions Title
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'দ্রুত কাজ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Quick Actions Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              delegate: SliverChildListDelegate([
                _buildQuickAction(
                  'বাজার',
                  Icons.shopping_cart,
                  Colors.green,
                  () => Get.to(() => const EnhancedMarketplace()),
                ),
                _buildQuickAction(
                  'রোগ শনাক্ত',
                  Icons.medical_services,
                  Colors.red,
                  () => Get.to(() => const DiseaseDetectionScreen()),
                ),
                _buildQuickAction(
                  'ওয়ালেট',
                  Icons.account_balance_wallet,
                  Colors.purple,
                  () => Get.to(() => const WalletScreen()),
                ),
                _buildQuickAction(
                  'পরিবহন',
                  Icons.local_shipping,
                  Colors.orange,
                  () => Get.to(() => const TransportRentalScreen()),
                ),
                _buildQuickAction(
                  'আবহাওয়া',
                  Icons.wb_sunny,
                  Colors.blue,
                  () {},
                ),
                _buildQuickAction(
                  'সাহায্য',
                  Icons.help_outline,
                  Colors.teal,
                  () {},
                ),
              ]),
            ),
          ),

          // Recent Activity
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'সাম্প্রতিক কার্যক্রম',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Activity List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildActivityItem(
                  'নতুন অর্ডার পেয়েছেন',
                  'আলু - ৫০ কেজি',
                  '২ ঘন্টা আগে',
                  Icons.shopping_bag,
                  Colors.green,
                );
              },
              childCount: 5,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return AnimatedCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
            'Are you sure you want to logout? You will be redirected to the login screen.'),
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
                    Provider.of<UserProvider>(dialogContext, listen: false);
                await userProvider.signOut();
                await FirebaseAuth.instance.signOut();
                Get.offAll(() => const LoginScreen());
              } catch (e) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
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

  void _toggleTheme() {
    if (Get.isDarkMode) {
      Get.changeThemeMode(ThemeMode.light);
    } else {
      Get.changeThemeMode(ThemeMode.dark);
    }
  }
}
