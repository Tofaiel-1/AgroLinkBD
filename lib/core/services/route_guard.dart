import '../models/user_model.dart';
import 'screen_access_control.dart';

/// Route Guard - Prevents unauthorized screen access across roles
class RouteGuard {
  /// Check if user can access a specific route
  static bool canAccess(UserType userType, String routeName) {
    return ScreenAccessControl.canAccessScreen(userType, routeName);
  }

  /// Get the reason why user can't access a screen
  static String getAccessDenialReason(UserType userType, String routeName) {
    if (canAccess(userType, routeName)) {
      return '';
    }
    return ScreenAccessControl.getRestrictionReason(userType, routeName);
  }

  /// Get the default route for a user's role
  static String getDefaultRoute(UserType userType) {
    switch (userType) {
      case UserType.farmer:
        return '/farmer/dashboard';
      case UserType.buyer:
        return '/buyer/dashboard';
      case UserType.driver:
        return '/driver/dashboard';
      case UserType.serviceProvider:
        return '/service-provider/dashboard';
      case UserType.company:
        return '/company/dashboard';
    }
  }

  /// Get all accessible routes for a user
  static Set<String> getAccessibleRoutes(UserType userType) {
    return ScreenAccessControl.getAccessibleScreens(userType);
  }

  /// Validate route and return safe redirect if needed
  static String validateAndGetRoute(UserType userType, String requestedRoute) {
    // If user can access, return requested route
    if (canAccess(userType, requestedRoute)) {
      return requestedRoute;
    }

    // If route is forbidden, redirect to default dashboard
    return getDefaultRoute(userType);
  }

  /// Get all role-specific navigation routes
  static Set<String> getRoleSpecificRoutes(UserType userType) {
    switch (userType) {
      case UserType.farmer:
        return {
          '/farmer/dashboard',
          '/farmer/add-product',
          '/farmer/my-products',
          '/farmer/orders',
          '/farmer/analytics',
          '/farmer/inputs',
          '/farmer/kyc',
        };
      case UserType.buyer:
        return {
          '/buyer/dashboard',
          '/buyer/browse',
          '/buyer/cart',
          '/buyer/checkout',
          '/buyer/orders',
          '/buyer/saved-farmers',
          '/buyer/wishlist',
        };
      case UserType.driver:
        return {
          '/driver/dashboard',
          '/driver/jobs',
          '/driver/active-trips',
          '/driver/trip-history',
          '/driver/earnings',
          '/driver/vehicle',
        };
      case UserType.serviceProvider:
        return {
          '/service-provider/dashboard',
          '/service-provider/manage',
          '/service-provider/bookings',
          '/service-provider/earnings',
          '/service-provider/reviews',
          '/service-provider/availability',
        };
      case UserType.company:
        return {
          '/company/dashboard',
          '/company/catalog',
          '/company/sales',
          '/company/orders',
          '/company/customers',
          '/company/analytics',
        };
    }
  }

  /// Check if route belongs to a different role
  static bool isRouteForeignRole(UserType userType, String routeName) {
    final allRoleRoutes = _getAllRoleRoutes();
    final myRoutes = getRoleSpecificRoutes(userType);

    // Check if route exists in role system but not accessible to this user
    return allRoleRoutes.contains(routeName) && !myRoutes.contains(routeName);
  }

  /// Get all role-specific routes (internal helper)
  static Set<String> _getAllRoleRoutes() {
    return {
      // Farmer routes
      '/farmer/dashboard',
      '/farmer/add-product',
      '/farmer/my-products',
      '/farmer/orders',
      '/farmer/analytics',
      '/farmer/inputs',
      '/farmer/kyc',
      // Buyer routes
      '/buyer/dashboard',
      '/buyer/browse',
      '/buyer/cart',
      '/buyer/checkout',
      '/buyer/orders',
      '/buyer/saved-farmers',
      '/buyer/wishlist',
      // Driver routes
      '/driver/dashboard',
      '/driver/jobs',
      '/driver/active-trips',
      '/driver/trip-history',
      '/driver/earnings',
      '/driver/vehicle',
      // Service Provider routes
      '/service-provider/dashboard',
      '/service-provider/manage',
      '/service-provider/bookings',
      '/service-provider/earnings',
      '/service-provider/reviews',
      '/service-provider/availability',
      // Company routes
      '/company/dashboard',
      '/company/catalog',
      '/company/sales',
      '/company/orders',
      '/company/customers',
      '/company/analytics',
    };
  }
}

/// Access Denial Reason Codes
class AccessDenialCode {
  static const String CROSS_ROLE_ACCESS = 'CROSS_ROLE_ACCESS';
  static const String PERMISSION_DENIED = 'PERMISSION_DENIED';
  static const String FEATURE_NOT_AVAILABLE = 'FEATURE_NOT_AVAILABLE';
  static const String ROLE_MISMATCH = 'ROLE_MISMATCH';
  static const String UNAUTHORIZED = 'UNAUTHORIZED';
}
