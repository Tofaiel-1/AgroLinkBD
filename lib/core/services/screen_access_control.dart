import '../models/user_model.dart';

/// Screen/Route Access Control - Define what screens each role can access
class ScreenAccessControl {
  /// Check if a user can access a specific screen
  static bool canAccessScreen(UserType userType, String screenRoute) {
    final allowedScreens = getAccessibleScreens(userType);
    return allowedScreens.contains(screenRoute);
  }

  /// Get all accessible screens for a user role
  static Set<String> getAccessibleScreens(UserType userType) {
    switch (userType) {
      case UserType.farmer:
        return _getFarmerScreens();
      case UserType.buyer:
        return _getBuyerScreens();
      case UserType.driver:
        return _getDriverScreens();
      case UserType.serviceProvider:
        return _getServiceProviderScreens();
      case UserType.company:
        return _getCompanyScreens();
    }
  }

  /// Get common screens accessible to all roles
  static Set<String> _getCommonScreens() {
    return {
      '/dashboard',
      '/profile',
      '/settings',
      '/notifications',
      '/wallet',
      '/chat',
      '/help',
    };
  }

  /// Farmer-specific screens
  static Set<String> _getFarmerScreens() {
    return {
      ..._getCommonScreens(),
      '/farmer/add-product',
      '/farmer/my-products',
      '/farmer/orders',
      '/farmer/analytics',
      '/farmer/inputs',
      '/farmer/kyc',
      '/farmer/sales',
      '/farmer/wallet',
      '/farmer/chat',
    };
  }

  /// Buyer-specific screens
  static Set<String> _getBuyerScreens() {
    return {
      ..._getCommonScreens(),
      '/buyer/browse',
      '/buyer/product-detail',
      '/buyer/cart',
      '/buyer/checkout',
      '/buyer/orders',
      '/buyer/saved-farmers',
      '/buyer/chat',
      '/buyer/wishlist',
    };
  }

  /// Driver-specific screens
  static Set<String> _getDriverScreens() {
    return {
      ..._getCommonScreens(),
      '/driver/jobs',
      '/driver/active-trips',
      '/driver/trip-history',
      '/driver/earnings',
      '/driver/vehicle',
      '/driver/documents',
      '/driver/chat',
      '/driver/map',
    };
  }

  /// Service Provider-specific screens
  static Set<String> _getServiceProviderScreens() {
    return {
      ..._getCommonScreens(),
      '/service/manage-services',
      '/service/bookings',
      '/service/earnings',
      '/service/reviews',
      '/service/availability',
      '/service/documents',
      '/service/chat',
    };
  }

  /// Company-specific screens
  static Set<String> _getCompanyScreens() {
    return {
      ..._getCommonScreens(),
      '/company/catalog',
      '/company/sales',
      '/company/orders',
      '/company/customers',
      '/company/analytics',
      '/company/team',
      '/company/reports',
      '/company/settings',
    };
  }

  /// Redirect to safe screen if access denied
  static String getDefaultScreenForRole(UserType userType) {
    switch (userType) {
      case UserType.farmer:
        return '/farmer/my-products';
      case UserType.buyer:
        return '/buyer/browse';
      case UserType.driver:
        return '/driver/jobs';
      case UserType.serviceProvider:
        return '/service/manage-services';
      case UserType.company:
        return '/company/catalog';
    }
  }

  /// Check if screen is restricted (requires special permissions)
  static bool isRestrictedScreen(String screenRoute) {
    const restrictedScreens = {
      '/settings',
      '/admin',
      '/reports',
      '/analytics',
      '/team',
    };
    return restrictedScreens.contains(screenRoute);
  }

  /// Get restriction reason for a screen
  static String getRestrictionReason(
    UserType userType,
    String screenRoute,
  ) {
    if (canAccessScreen(userType, screenRoute)) {
      return '';
    }

    return 'This screen is not available for your role. '
        'Please contact support if you need access.';
  }
}
