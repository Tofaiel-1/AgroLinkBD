/// Phase 2 Route Names - Add these to your navigation system
class Phase2Routes {
  // Maps Module
  static const String driverDeliveryMap = '/maps/driver_delivery';
  static const String buyerOrderTracking = '/maps/buyer_tracking';

  // Analytics Module
  static const String farmerAnalytics = '/analytics/farmer';
  static const String buyerAnalytics = '/analytics/buyer';
  static const String driverAnalytics = '/analytics/driver';
  static const String serviceProviderAnalytics = '/analytics/service_provider';
  static const String companyAnalytics = '/analytics/company';

  // Notification Module
  static const String notificationCenter = '/notifications/center';
  static const String farmerNotifications = '/notifications/farmer';
  static const String buyerNotifications = '/notifications/buyer';
  static const String driverNotifications = '/notifications/driver';
  static const String serviceProviderNotifications =
      '/notifications/service_provider';
  static const String companyNotifications = '/notifications/company';

  // Farm Management
  static const String farmManagement = '/farmer/farm_management';

  // Portfolio Gallery
  static const String portfolioGallery = '/service_provider/portfolio';

  // Team Management
  static const String teamManagement = '/company/team_management';
}

/// Phase 2 Navigation Integration Guide
///
/// Add these imports to your navigation container or main router file:
///
/// ```dart
/// import 'package:agrolinkbd/presentation/screens/maps/driver_delivery_map.dart';
/// import 'package:agrolinkbd/presentation/screens/maps/buyer_order_tracking_map.dart';
/// import 'package:agrolinkbd/presentation/screens/analytics/farmer_analytics.dart';
/// import 'package:agrolinkbd/presentation/screens/analytics/buyer_analytics.dart';
/// import 'package:agrolinkbd/presentation/screens/analytics/driver_analytics.dart';
/// import 'package:agrolinkbd/presentation/screens/analytics/service_provider_analytics.dart';
/// import 'package:agrolinkbd/presentation/screens/analytics/company_analytics.dart';
/// import 'package:agrolinkbd/presentation/screens/notifications/notification_center.dart';
/// import 'package:agrolinkbd/presentation/screens/notifications/farmer_notifications.dart';
/// import 'package:agrolinkbd/presentation/screens/notifications/buyer_notifications.dart';
/// import 'package:agrolinkbd/presentation/screens/notifications/driver_notifications.dart';
/// import 'package:agrolinkbd/presentation/screens/notifications/service_provider_notifications.dart';
/// import 'package:agrolinkbd/presentation/screens/notifications/company_notifications.dart';
/// import 'package:agrolinkbd/presentation/screens/farmer/farm_management_screen.dart';
/// import 'package:agrolinkbd/presentation/screens/service_provider/portfolio_gallery_screen.dart';
/// import 'package:agrolinkbd/presentation/screens/company/team_management_screen.dart';
/// ```
///
/// Then add routes to your GoRouter or Navigator configuration:
///
/// For GoRouter (Recommended):
/// ```dart
/// GoRoute(
///   path: Phase2Routes.driverDeliveryMap,
///   builder: (context, state) => const DriverDeliveryMapScreen(),
/// ),
/// GoRoute(
///   path: Phase2Routes.buyerOrderTracking,
///   builder: (context, state) => const BuyerOrderTrackingMapScreen(),
/// ),
/// // Add similar routes for all Phase 2 screens...
/// ```
///
/// For Navigator push:
/// ```dart
/// Navigator.of(context).pushNamed(Phase2Routes.farmerAnalytics);
/// // or
/// Navigator.of(context).push(
///   MaterialPageRoute(builder: (_) => const FarmerAnalyticsScreen()),
/// );
/// ```
///
/// Integration Points:
/// 1. Update RoleService to include Phase 2 screens in navigation items
/// 2. Update dashboard/home screens to link to new screens
/// 3. Add notification badge to notification center in app bar
/// 4. Add bottom tab navigation items for each role with Phase 2 screens
///
/// Example RoleService Extension:
/// ```dart
/// List<NavigationItem> getPhase2NavigationItems(String userRole) {
///   switch (userRole) {
///     case 'farmer':
///       return [
///         NavigationItem(
///           label: 'Analytics',
///           icon: Icons.analytics,
///           route: Phase2Routes.farmerAnalytics,
///         ),
///         NavigationItem(
///           label: 'Farms',
///           icon: Icons.agriculture,
///           route: Phase2Routes.farmManagement,
///         ),
///         NavigationItem(
///           label: 'Notifications',
///           icon: Icons.notifications,
///           route: Phase2Routes.notificationCenter,
///         ),
///       ];
///     // Similar for other roles...
///     default:
///       return [];
///   }
/// }
/// ```
