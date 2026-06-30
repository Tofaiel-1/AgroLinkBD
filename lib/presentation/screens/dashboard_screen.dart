import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/presentation/screens/bazaar/bazaar_home.dart';
import 'package:agrolinkbd/presentation/screens/transport/transport_rental_screen.dart';
import 'package:agrolinkbd/presentation/screens/disease/disease_detection_screen.dart';
import 'package:agrolinkbd/presentation/screens/wallet/wallet_screen.dart';
import 'package:agrolinkbd/presentation/screens/profile/profile_screen.dart';
import 'package:agrolinkbd/presentation/screens/ai/ai_assistant_screen.dart';
import 'package:agrolinkbd/presentation/screens/crops/crop_management_screen.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import 'package:agrolinkbd/core/providers/admin_provider.dart';
import 'package:agrolinkbd/presentation/screens/sokol_card/card_preview_screen.dart' as agrolinkbd;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final userController = Get.find<UserController>();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
        title: const Text(
          'ড্যাশবোর্ড',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.credit_card),
            onPressed: () => Get.to(() => const agrolinkbd.CardPreviewScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Get.to(() => const ProfileScreen()),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isSuperAdmin) {
            return _buildSuperAdminDashboard();
          }
          return _buildRegularUserDashboard();
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Super Admin Dashboard
  Widget _buildSuperAdminDashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade700,
                  Colors.purple.shade500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: Colors.white,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'স্বাগতম, পরিচালক!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'সিস্টেম পরিচালনা প্যানেল',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🔐 সম্পূর্ণ সিস্টেম নিয়ন্ত্রণ',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // System Statistics Grid
          _buildAdminStatsGrid(),

          const SizedBox(height: 12),

          // Admin Management Section
          _buildAdminManagementSection(),

          const SizedBox(height: 12),

          // Quick Admin Actions
          _buildAdminQuickActions(),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Regular User Dashboard
  Widget _buildRegularUserDashboard() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Today's Tasks
          _buildTodaysTasks(),

          const SizedBox(height: 16),

          // My Crops
          _buildMyCrops(),

          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActions(),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Admin Statistics Grid
  Widget _buildAdminStatsGrid() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: [
          _buildStatCard(
            title: 'মোট ব্যবহারকারী',
            value: '৫,২৪৮',
            icon: Icons.people,
            color: Colors.blue,
          ),
          _buildStatCard(
            title: 'সক্রিয় বিক্রেতা',
            value: '১,২৪৫',
            icon: Icons.storefront,
            color: Colors.green,
          ),
          _buildStatCard(
            title: 'সক্রিয় ক্রেতা',
            value: '৩,৮৬৫',
            icon: Icons.shopping_cart,
            color: Colors.orange,
          ),
          _buildStatCard(
            title: 'মোট অর্ডার',
            value: '১২,৫৬৪',
            icon: Icons.receipt_long,
            color: Colors.purple,
          ),
          _buildStatCard(
            title: 'এডমিন',
            value: '১২',
            icon: Icons.security,
            color: Colors.indigo,
          ),
          _buildStatCard(
            title: 'মডারেটর',
            value: '২৫',
            icon: Icons.verified_user,
            color: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Admin Management Section
  Widget _buildAdminManagementSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'প্রশাসক পরিচালনা',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAdminActionButton(
            icon: Icons.person_add,
            title: 'নতুন এডমিন যোগ করুন',
            color: Colors.blue,
            onTap: () {
              // TODO: Navigate to admin management screen
            },
          ),
          const SizedBox(height: 8),
          _buildAdminActionButton(
            icon: Icons.history,
            title: 'কার্যকলাপ লগ',
            color: Colors.orange,
            onTap: () {
              // TODO: Navigate to audit logs screen
            },
          ),
          const SizedBox(height: 8),
          _buildAdminActionButton(
            icon: Icons.analytics,
            title: 'বিশ্লেষণ ড্যাশবোর্ড',
            color: Colors.green,
            onTap: () {
              // TODO: Navigate to analytics dashboard
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // Admin Quick Actions Grid
  Widget _buildAdminQuickActions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'দ্রুত কর্ম',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _buildQuickActionTile(
                icon: Icons.block,
                label: 'সন্দেহজনক অ্যাকাউন্ট',
                color: Colors.red,
              ),
              _buildQuickActionTile(
                icon: Icons.flag,
                label: 'রিপোর্ট করা বিষয়',
                color: Colors.amber,
              ),
              _buildQuickActionTile(
                icon: Icons.mail,
                label: 'ঘোষণা পাঠান',
                color: Colors.blue,
              ),
              _buildQuickActionTile(
                icon: Icons.settings,
                label: 'সিস্টেম সেটিংস',
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysTasks() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'আজার কাজ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'আজ: ধানিতে সার প্রয়োগ করুন। কীটনাশক স্প্রে',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'সম্পূর্ণ',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Text(
                'আরও দেখুন',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.green.shade700),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyCrops() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Crops',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => Get.to(() => const CropManagementScreen()),
                child: const Text('সব দেখুন'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCropCard('আমন ধান - বৃদ্ধি পর্যায়'),
                _buildCropCard('টমেটো - ফুল'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCropCard(String name) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.grass, color: Colors.green.shade700, size: 32),
          const Spacer(),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.green.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Obx(() {
      final actions = userController.getQuickActions();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: actions.length > 6 ? 6 : actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
              action['title'],
              _getIconData(action['icon']),
              () => _navigateToScreen(action['route']),
            );
          },
        ),
      );
    });
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'agriculture': Icons.agriculture,
      'store': Icons.store,
      'local_shipping': Icons.local_shipping,
      'camera_alt': Icons.camera_alt,
      'shopping_cart': Icons.shopping_cart,
      'gavel': Icons.gavel,
      'receipt': Icons.receipt,
      'trending_up': Icons.trending_up,
      'show_chart': Icons.show_chart,
      'support_agent': Icons.support_agent,
      'health_and_safety': Icons.health_and_safety,
      'science': Icons.science,
      'school': Icons.school,
      'account_balance_wallet': Icons.account_balance_wallet,
      'smart_toy': Icons.smart_toy,
      'cloud': Icons.cloud,
    };
    return iconMap[iconName] ?? Icons.help_outline;
  }

  void _navigateToScreen(String route) {
    switch (route) {
      case 'marketplace':
      case 'buy':
      case 'sell':
        Get.to(() => const BazaarHome());
        break;
      case 'crops':
        Get.to(() => const CropManagementScreen());
        break;
      case 'transport':
      case 'machinery':
        Get.to(() => const TransportRentalScreen());
        break;
      case 'disease':
        Get.to(() => const DiseaseDetectionScreen());
        break;
      case 'ai':
        Get.to(() => const AIAssistantScreen());
        break;
      case 'wallet':
        Get.to(() => const WalletScreen());
        break;
      default:
        Get.snackbar('আসছে শীঘ্রই', 'এই ফিচারটি শীঘ্রই যুক্ত করা হবে');
    }
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.green.shade700, size: 36),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() => _selectedIndex = index);
        if (index == 1) {
          Get.to(() => const BazaarHome());
        } else if (index == 2) {
          Get.to(() => const AIAssistantScreen());
        } else if (index == 3) {
          Get.to(() => const WalletScreen());
        }
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF2E7D32),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'হোম'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag), label: 'মার্কেট'),
        BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'AI'),
        BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet), label: 'ওয়ালেট'),
      ],
    );
  }
}
