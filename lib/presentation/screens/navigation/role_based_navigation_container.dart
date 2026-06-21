import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/services/role_service.dart';
import 'package:agrolinkbd/core/services/route_guard.dart';

// Role-specific navigation stacks
import 'package:agrolinkbd/presentation/screens/farmer/farmer_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/dashboard/buyer_dashboard_screen.dart';
import 'package:agrolinkbd/presentation/screens/driver/driver_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/company/company_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/company/company_orders_screen.dart';
import 'package:agrolinkbd/presentation/screens/company/company_contracts_screen.dart';

// Generic screens (available to all roles)
import 'package:agrolinkbd/presentation/screens/notifications/notification_center.dart';
import 'package:agrolinkbd/presentation/screens/bazaar/bazaar_home.dart';
import 'package:agrolinkbd/presentation/screens/profile/profile_settings.dart';

// Buyer-specific screens
import 'package:agrolinkbd/presentation/screens/marketplace/marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/shopping_cart_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/buyer_orders_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/buyer_profile_screen.dart';

// Phase 2 Screens - Maps
import 'package:agrolinkbd/presentation/screens/maps/driver_delivery_map.dart';
import 'package:agrolinkbd/presentation/screens/maps/buyer_order_tracking_map.dart';

// Phase 2 Screens - Analytics
import 'package:agrolinkbd/presentation/screens/analytics/farmer_analytics.dart';
import 'package:agrolinkbd/presentation/screens/analytics/buyer_analytics.dart';
import 'package:agrolinkbd/presentation/screens/analytics/driver_analytics.dart';
import 'package:agrolinkbd/presentation/screens/analytics/service_provider_analytics.dart';
import 'package:agrolinkbd/presentation/screens/analytics/company_analytics.dart';

// Phase 2 Screens - Management
import 'package:agrolinkbd/presentation/screens/farmer/farm_management_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_products_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_orders_screen.dart';
import 'package:agrolinkbd/presentation/screens/company/team_management_screen.dart';

/// Role-Based Navigation Container
///
/// ARCHITECTURE: Each user role gets a COMPLETELY SEPARATE navigation stack.
/// This ensures ZERO cross-role feature leakage:
///
/// - Farmer sees ONLY farmer screens + common screens
/// - Buyer sees ONLY buyer screens + common screens
/// - Driver sees ONLY driver screens + common screens
/// - Service Provider sees ONLY service provider screens + common screens
/// - Company sees ONLY company screens + common screens (on web only)
///
/// Any attempt to access another role's screens results in redirect + access denied toast.
class RoleBasedNavigationContainer extends StatefulWidget {
  final UserModel user;

  const RoleBasedNavigationContainer({
    super.key,
    required this.user,
  });

  @override
  State<RoleBasedNavigationContainer> createState() =>
      _RoleBasedNavigationContainerState();
}

class _RoleBasedNavigationContainerState
    extends State<RoleBasedNavigationContainer> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the appropriate navigation stack for this role
    final navigationStack = _getNavigationStack();
    final navigationItems =
        RoleService.getNavigationItems(widget.user.userType);

    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        drawer: _buildDrawer(context, widget.user),
        body: IndexedStack(
          index: _currentIndex,
          children: navigationStack,
        ),
        bottomNavigationBar: _buildRoleSpecificBottomNav(navigationItems),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, UserModel user) {
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
              child: user.name == null || user.name!.isEmpty
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

  /// Get the navigation stack specific to user's role
  /// Each role has a completely separate set of screens
  List<Widget> _getNavigationStack() {
    switch (widget.user.userType) {
      case UserType.farmer:
        return [
          const FarmerDashboard(),
          const FarmManagementScreen(),
          const FarmerAnalyticsScreen(),
          const BazaarHome(),
          const ProfileSettings(),
        ];

      case UserType.buyer:
        return [
          const BuyerDashboardScreen(),
          const MarketplaceScreen(),
          const ShoppingCartScreen(),
          const BuyerOrdersScreen(),
          const BuyerProfileScreen(),
        ];

      case UserType.driver:
        return [
          const DriverDashboard(),
          const DriverDeliveryMapScreen(),
          const DriverAnalyticsScreen(),
          const BazaarHome(),
          const ProfileSettings(),
        ];

      case UserType.serviceProvider:
        return [
          const ServiceProviderDashboard(),
          const ServiceProviderProductsScreen(),
          const ServiceProviderOrdersScreen(),
          const BazaarHome(),
          const ProfileSettings(),
        ];

      case UserType.company:
        return [
          const CompanyDashboard(),
          const TeamManagementScreen(),
          const CompanyAnalyticsScreen(),
          const CompanyOrdersScreen(),
          const CompanyContractsScreen(),
        ];
    }
  }

  /// Build role-specific bottom navigation with role's color
  Widget _buildRoleSpecificBottomNav(List<Map<String, dynamic>> navItems) {
    final roleColor = RoleService.getRoleColor(widget.user.userType);
    final items = navItems
        .map((item) => BottomNavigationBarItem(
              icon: Icon(item['icon'] as IconData),
              label: item['label'] as String,
            ))
        .toList();

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _currentIndex,
      selectedItemColor: roleColor,
      unselectedItemColor: Colors.grey,
      onTap: _handleNavigation,
      items: items,
    );
  }

  /// Handle bottom navigation tap with role verification
  void _handleNavigation(int index) {
    // Ensure index is within bounds
    if (index >= _getNavigationStack().length) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  /// Handle back button press
  Future<bool> _handleBackPress() async {
    if (_currentIndex != 0) {
      // If not on first tab, go to first tab instead of exiting
      setState(() {
        _currentIndex = 0;
      });
      return false;
    }

    // Show confirmation dialog before exiting
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App?'),
        content: const Text('Are you sure you want to exit AgroLinkBD?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }
}

/// Role-Specific Navigation State Controller
/// Provides functions to manage navigation with role verification
class RoleNavigationController extends GetxController {
  final UserModel user;
  final Rx<int> currentIndex = Rx(0);

  RoleNavigationController({required this.user});

  /// Navigate to a specific index with role verification
  void navigateTo(int index) {
    if (index < 0 || index > 4) {
      // Out of bounds
      Get.snackbar(
        'Invalid Navigation',
        'Cannot navigate to that tab',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    currentIndex.value = index;
  }

  /// Navigate to a route with cross-role protection
  void navigateToRoute(String routeName) {
    // Validate route access
    final validRoute = RouteGuard.validateAndGetRoute(user.userType, routeName);

    if (validRoute != routeName) {
      // Access denied - show reason
      final reason = RouteGuard.getAccessDenialReason(user.userType, routeName);
      Get.snackbar(
        '🚫 Access Denied',
        reason,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      // Redirect to default route
      Get.offAllNamed(validRoute);
      return;
    }

    // Route is allowed, navigate
    Get.toNamed(routeName);
  }

  /// Reset navigation to default dashboard
  void resetToDefault() {
    currentIndex.value = 0;
    Get.offAllNamed(RouteGuard.getDefaultRoute(user.userType));
  }
}

/// Navigation Interceptor - Prevents unauthorized navigation
class NavigationInterceptor {
  static final NavigationInterceptor _instance =
      NavigationInterceptor._internal();

  factory NavigationInterceptor() {
    return _instance;
  }

  NavigationInterceptor._internal();

  /// Intercept navigation and check permissions
  static Future<bool> shouldAllow(UserType userType, String routeName) async {
    // Check if user can access this route
    if (!RouteGuard.canAccess(userType, routeName)) {
      return false;
    }

    return true;
  }

  /// Get the safe route to navigate to
  static String getSafeRoute(UserType userType, String requestedRoute) {
    return RouteGuard.validateAndGetRoute(userType, requestedRoute);
  }
}
