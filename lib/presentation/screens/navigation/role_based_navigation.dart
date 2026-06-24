import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';

// Role-specific dashboards
import 'package:agrolinkbd/presentation/screens/farmer/farmer_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/buyer/buyer_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/driver/driver_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/driver/load_board/load_board_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_dashboard.dart';

// Fallback screens
import 'package:agrolinkbd/presentation/screens/dashboard/enhanced_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/profile/profile_settings.dart';
import 'package:agrolinkbd/presentation/screens/notifications/notification_center.dart';
import 'package:agrolinkbd/presentation/screens/notifications/driver_notifications.dart';
import 'package:agrolinkbd/presentation/screens/bazaar/bazaar_home.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_products_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_orders_screen.dart';

/// Role-Based Navigation
/// Routes users to their role-specific dashboard + generic screens
class RoleBasedNavigation extends StatefulWidget {
  const RoleBasedNavigation({super.key});

  @override
  State<RoleBasedNavigation> createState() => _RoleBasedNavigationState();
}

class _RoleBasedNavigationState extends State<RoleBasedNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Get screens based on user role
    final roleString = user.userType.toString().split('.').last;
    final screens = _getScreensByRole(roleString);

    return Scaffold(
      drawer: _buildDrawer(context, user),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar:
          _buildBottomNavigation(user.userType.toString().split('.').last),
    );
  }

  /// Get dashboard screens based on user role
  List<Widget> _getScreensByRole(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return [
          const FarmerDashboard(),
          const EnhancedDashboard(), // Analytics/Stats
          const BazaarHome(), // Marketplace for inputs
          const NotificationCenter(),
          const ProfileSettings(),
        ];

      case 'buyer':
        return [
          const BuyerDashboard(),
          const EnhancedDashboard(), // Orders/Cart view
          const BazaarHome(), // Browse marketplace
          const NotificationCenter(),
          const ProfileSettings(),
        ];

      case 'driver':
        return [
          const DriverDashboard(),
          const EnhancedDashboard(), // Trip history/stats
          const LoadBoardScreen(), // New Trip Marketplace
          const DriverNotificationsScreen(),
          const ProfileSettings(),
        ];

      case 'serviceprovider':
        return [
          const ServiceProviderDashboard(),
          const ServiceProviderProductsScreen(), // My Products
          const ServiceProviderOrdersScreen(), // Orders
          const NotificationCenter(),
          const ProfileSettings(),
        ];

      default:
        return [
          const EnhancedDashboard(),
          const EnhancedDashboard(),
          const BazaarHome(),
          const NotificationCenter(),
          const ProfileSettings(),
        ];
    }
  }

  /// Build bottom navigation based on user role
  Widget _buildBottomNavigation(String role) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: _getRoleColor(role),
        unselectedItemColor: Colors.grey,
        items: _getNavItems(role),
      ),
    );
  }

  /// Get navigation items based on user role
  List<BottomNavigationBarItem> _getNavItems(String role) {
    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined),
        activeIcon: const Icon(Icons.home),
        label: _getRoleLabel(role, 0),
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.assessment_outlined),
        activeIcon: const Icon(Icons.assessment),
        label: _getRoleLabel(role, 1),
      ),
      BottomNavigationBarItem(
        icon: Icon(role.toLowerCase() == 'driver' ? Icons.local_shipping_outlined : Icons.store_outlined),
        activeIcon: Icon(role.toLowerCase() == 'driver' ? Icons.local_shipping : Icons.store),
        label: _getRoleLabel(role, 2),
      ),
      BottomNavigationBarItem(
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications_outlined),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: const Text(
                  '২',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        activeIcon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.notifications),
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 14,
                  minHeight: 14,
                ),
                child: const Text(
                  '২',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        label: 'বিজ্ঞপ্তি',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'প্রোফাইল',
      ),
    ];
  }

  /// Get role-specific label for navigation items
  String _getRoleLabel(String role, int index) {
    switch (role.toLowerCase()) {
      case 'farmer':
        switch (index) {
          case 0:
            return 'ড্যাশবোর্ড';
          case 1:
            return 'বিক্রয়';
          case 2:
            return 'ইনপুট';
          default:
            return '';
        }

      case 'buyer':
        switch (index) {
          case 0:
            return 'হোম';
          case 1:
            return 'আমার অর্ডার';
          case 2:
            return 'কেনাকাটা';
          default:
            return '';
        }

      case 'driver':
        switch (index) {
          case 0:
            return 'ট্রিপ';
          case 1:
            return 'ইতিহাস';
          case 2:
            return 'নতুন কাজ';
          default:
            return '';
        }

      case 'serviceprovider':
        switch (index) {
          case 0:
            return 'দোকান';
          case 1:
            return 'পণ্য';
          case 2:
            return 'অর্ডার';
          default:
            return '';
        }

      default:
        return '';
    }
  }

  /// Get role-specific color
  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return const Color(0xFF2E7D32); // Green
      case 'buyer':
        return const Color(0xFF1976D2); // Blue
      case 'driver':
        return const Color(0xFFF57C00); // Orange
      case 'serviceprovider':
        return Colors.indigo;
      default:
        return Colors.blue;
    }
  }

  Widget _buildDrawer(BuildContext context, dynamic user) {
    final roleString = user.userType.toString().split('.').last;
    String roleDisplay = 'ব্যবহারকারী';
    if (roleString.toLowerCase() == 'farmer') roleDisplay = 'কৃষক';
    if (roleString.toLowerCase() == 'buyer') roleDisplay = 'ক্রেতা';
    if (roleString.toLowerCase() == 'driver') roleDisplay = 'চালক';
    if (roleString.toLowerCase() == 'serviceprovider') roleDisplay = 'সেবা প্রদানকারী';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              user.name ?? 'AgroLinkBD User',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            accountEmail: Text(
              '$roleDisplay | ${user.phone ?? ""}',
              style: const TextStyle(fontSize: 14),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: const NetworkImage('https://randomuser.me/api/portraits/men/44.jpg'),
              child: user.name == null
                  ? Text(roleDisplay[0], style: const TextStyle(fontSize: 24, color: Colors.green))
                  : null,
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('ডার্ক / লাইট মোড'),
            trailing: Switch(
              value: Get.isDarkMode,
              onChanged: (value) {
                Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                setState(() {});
              },
            ),
          ),
          const Divider(),
          
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('ভাষা (Language)'),
            subtitle: const Text('বাংলা'),
            onTap: () {
              Get.snackbar('ভাষা পরিবর্তন', 'শীঘ্রই আসছে...');
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('সাহায্য ও সাপোর্ট'),
            onTap: () {
              Get.snackbar('সাপোর্ট', 'হেল্পলাইন: 16123');
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('গোপনীয়তা নীতি'),
            onTap: () {
              Get.snackbar('গোপনীয়তা', 'গোপনীয়তা নীতি লোড হচ্ছে...');
            },
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('লগ আউট', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context); // Close drawer
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'লগ আউট',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('আপনি কি নিশ্চিত যে আপনি লগ আউট করতে চান?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('বাতিল', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                await userProvider.signOut();
              } catch (e) {
                Get.snackbar('Error', 'লগ আউট করতে সমস্যা হয়েছে: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('লগ আউট', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
