import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:agrolinkbd/core/providers/user_provider.dart';
import 'package:agrolinkbd/core/models/user_model.dart';
import 'package:agrolinkbd/core/services/role_service.dart';
import 'package:agrolinkbd/core/services/route_guard.dart';
import 'package:agrolinkbd/presentation/widgets/responsive_web_wrapper.dart';
import 'dart:async';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/services/notification_service.dart';

// Role-specific navigation stacks
import 'package:agrolinkbd/presentation/screens/farmer/farmer_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/fish_farmer_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/marketplace/fish_marketplace_tab.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/analytics/fisheries_analytics_tab.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/pond_management/pond_management_screen.dart';
import 'package:agrolinkbd/presentation/screens/service_provider/service_provider_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/card/card_preview_screen.dart' as agrolinkbd;
import 'package:agrolinkbd/presentation/screens/agri_info/emergency_weather_services_screen.dart';
import 'package:agrolinkbd/presentation/screens/dashboard/buyer_dashboard_screen.dart';
import 'package:agrolinkbd/presentation/screens/driver/driver_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/driver/load_board/load_board_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/driver/fish_driver_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/driver/fish_driver_deliveries_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/driver/fish_driver_analytics_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/driver/fish_driver_job_board_screen.dart';
import 'package:agrolinkbd/presentation/screens/company/company_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/company/company_orders_screen.dart';
import 'package:agrolinkbd/presentation/screens/company/company_contracts_screen.dart';

// Generic screens (available to all roles)
import 'package:agrolinkbd/presentation/screens/bazaar/bazaar_home.dart';
import 'package:agrolinkbd/presentation/screens/profile/profile_settings.dart';

// Buyer-specific screens
import 'package:agrolinkbd/presentation/screens/marketplace/marketplace_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/shopping_cart_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';
import 'package:agrolinkbd/presentation/buyer/screens/buyer_orders_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/buyer_profile_screen.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_dashboard.dart';
import 'package:agrolinkbd/presentation/screens/marketplace/fish_marketplace_screen.dart';

// Phase 2 Screens - Maps
import 'package:agrolinkbd/presentation/screens/maps/driver_delivery_map.dart';

// Phase 2 Screens - Analytics
import 'package:agrolinkbd/presentation/screens/analytics/farmer_analytics.dart';
import 'package:agrolinkbd/presentation/screens/analytics/driver_analytics.dart';
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
  StreamSubscription? _orderSubscription;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _setupFarmerOrderListener();
  }

  void _setupFarmerOrderListener() {
    if (widget.user.userType == UserType.farmer || widget.user.userType == UserType.fishFarmer) {
      _orderSubscription = OrderService().listenToNewFarmerOrders(widget.user.id).listen((order) {
        // Show local notification
        NotificationService().showNotification(
          title: 'নতুন অর্ডার পেয়েছেন!',
          body: '${order.productName} এর জন্য একটি নতুন অর্ডার এসেছে। পরিমাণ: ${order.quantity}',
        );
      });
    }
  }

  @override
  void dispose() {
    _orderSubscription?.cancel();
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
        body: ResponsiveWebWrapper.content(
          child: IndexedStack(
            index: _currentIndex,
            children: navigationStack,
          ),
        ),
        bottomNavigationBar: _buildRoleSpecificBottomNav(navigationItems),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, UserModel user) {
    final roleString = user.userType.toString().split('.').last.toLowerCase();
    String roleDisplay = 'ব্যবহারকারী';
    if (roleString == 'farmer') roleDisplay = 'কৃষক';
    if (roleString == 'buyer') roleDisplay = 'ক্রেতা';
    if (roleString == 'driver') roleDisplay = 'চালক';
    if (roleString == 'serviceprovider') roleDisplay = 'সেবা প্রদানকারী';
    if (roleString == 'company') roleDisplay = 'কোম্পানি';
    if (roleString == 'fishfarmer') roleDisplay = 'মৎস্য চাষী';
    if (roleString == 'fishbuyer') roleDisplay = 'মৎস্য ক্রেতা';
    if (roleString == 'fishdriver') roleDisplay = 'মৎস্য পরিবহন';
    if (roleString == 'hatchery') roleDisplay = 'হ্যাচারি মালিক';
    if (roleString == 'fishexpert') roleDisplay = 'মৎস্য বিশেষজ্ঞ';

    final roleColor = RoleService.getRoleColor(user.userType);
    final darkRoleColor = HSLColor.fromColor(roleColor)
        .withLightness((HSLColor.fromColor(roleColor).lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [roleColor, darkRoleColor],
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
            currentAccountPicture: GestureDetector(
              onTap: () {
                // Import if not already imported, but we can use Get.to if Get is available
                // Let's use Navigator to be safe, but Get.to is already imported in this file
                Get.to(() => const agrolinkbd.CardPreviewScreen());
              },
              child: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: const NetworkImage('https://randomuser.me/api/portraits/men/44.jpg'),
                child: user.name == null || user.name!.isEmpty
                    ? Text(roleDisplay[0], style: TextStyle(fontSize: 24, color: roleColor))
                    : null,
              ),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(LanguageProvider.isBn(context) ? 'ডার্ক / লাইট মোড' : 'Dark / Light Mode'),
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
            title: Text(LanguageProvider.isBn(context) ? 'ভাষা' : 'Language'),
            subtitle: Text(LanguageProvider.isBn(context) ? 'বাংলা' : 'English'),
            onTap: () {
              Provider.of<LanguageProvider>(context, listen: false).toggleLanguage();
              Get.snackbar(
                LanguageProvider.isBn(context) ? 'ভাষা পরিবর্তন' : 'Language Changed',
                LanguageProvider.isBn(context) ? 'বাংলা ভাষা নির্বাচন করা হয়েছে' : 'English language selected',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning_amber_rounded, color: Colors.red),
            title: Text(LanguageProvider.isBn(context) ? 'জরুরি সেবা ও আবহাওয়া কেন্দ্র' : 'Emergency & Weather Center', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => const EmergencyWeatherServicesScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(LanguageProvider.isBn(context) ? 'সাহায্য ও সাপোর্ট' : 'Help & Support'),
            onTap: () {
              Get.snackbar(
                LanguageProvider.isBn(context) ? 'সাপোর্ট' : 'Support',
                LanguageProvider.isBn(context) ? 'হেল্পলাইন: 16123' : 'Helpline: 16123',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(LanguageProvider.isBn(context) ? 'গোপনীয়তা নীতি' : 'Privacy Policy'),
            onTap: () {
              Get.snackbar(
                LanguageProvider.isBn(context) ? 'গোপনীয়তা' : 'Privacy Policy',
                LanguageProvider.isBn(context) ? 'গোপনীয়তা নীতি লোড হচ্ছে...' : 'Loading privacy policy...',
              );
            },
          ),
          
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(LanguageProvider.isBn(context) ? 'লগ আউট' : 'Logout', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
        title: Text(
          LanguageProvider.isBn(context) ? 'লগ আউট' : 'Logout',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(LanguageProvider.isBn(context) ? 'আপনি কি নিশ্চিত যে আপনি লগ আউট করতে চান?' : 'Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(LanguageProvider.isBn(context) ? 'বাতিল' : 'Cancel', style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                await userProvider.signOut();
              } catch (e) {
                Get.snackbar('Error', LanguageProvider.isBn(context) ? 'লগ আউট করতে সমস্যা হয়েছে: $e' : 'Logout failed: $e');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(LanguageProvider.isBn(context) ? 'লগ আউট' : 'Logout', style: const TextStyle(color: Colors.white)),
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
          const LoadBoardScreen(), // New Job Board for Driver
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
      case UserType.seller:
        return [
          const CompanyDashboard(),
          const TeamManagementScreen(),
          const CompanyAnalyticsScreen(),
          const CompanyOrdersScreen(),
          const CompanyContractsScreen(),
        ];
      case UserType.fishFarmer:
        return [
          const FishFarmerDashboard(), // 0: Home
          const PondManagementScreen(), // 1: Farms
          const FisheriesAnalyticsTab(), // 2: Analytics
          const FishMarketplaceTab(), // 3: Marketplace
          const ProfileSettings(), // 4: Settings
        ];
      case UserType.fishBuyer:
        return [
          const FishBuyerDashboard(),
          const FishMarketplaceScreen(),
          const ShoppingCartScreen(),
          const FishBuyerOrdersScreen(),
          const ProfileSettings(),
        ];
      case UserType.fishDriver:
        return [
          const FishDriverDashboard(),
          const FishDriverDeliveriesScreen(),
          const FishDriverAnalyticsScreen(),
          const FishDriverJobBoardScreen(),
          const ProfileSettings(),
        ];
      case UserType.fishServiceProvider:
      case UserType.fishCompany:
      case UserType.fishExpert:
      case UserType.hatchery:
      case UserType.expert:
        return [
          Scaffold(body: Center(child: Text('Fisheries Dashboard (${widget.user.userType.name})'))),
          const Scaffold(body: Center(child: Text('Marketplace/Catalog'))),
          const Scaffold(body: Center(child: Text('Analytics'))),
          const Scaffold(body: Center(child: Text('Orders/Bookings'))),
          const ProfileSettings(),
        ];
    }
  }

  /// Build role-specific bottom navigation with role's color
  Widget _buildRoleSpecificBottomNav(List<Map<String, dynamic>> navItems) {
    final isBn = LanguageProvider.isBn(context);
    final roleColor = RoleService.getRoleColor(widget.user.userType);
    final items = navItems
        .map((item) => BottomNavigationBarItem(
              icon: Icon(item['icon'] as IconData),
              label: isBn
                  ? (item['labelBN'] as String? ?? item['label'] as String)
                  : (item['label'] as String),
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
        title: Text(LanguageProvider.isBn(context) ? 'অ্যাপ থেকে বের হবেন?' : 'Exit App?'),
        content: Text(LanguageProvider.isBn(context) ? 'আপনি কি নিশ্চিত যে আপনি AgroLinkBD থেকে বের হতে চান?' : 'Are you sure you want to exit AgroLinkBD?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(LanguageProvider.isBn(context) ? 'বাতিল' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(LanguageProvider.isBn(context) ? 'বের হোন' : 'Exit'),
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
