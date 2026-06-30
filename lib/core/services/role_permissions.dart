import '../models/user_model.dart';

/// Role-Based Permissions - Define what each role can access
class RolePermissions {
  /// Permission identifiers
  static const String
      // Farmer permissions
      CAN_LIST_PRODUCTS = 'can_list_products',
      CAN_MANAGE_ORDERS = 'can_manage_orders',
      CAN_VIEW_ANALYTICS = 'can_view_analytics',
      CAN_ACCESS_INPUTS_STORE = 'can_access_inputs_store',
      CAN_UPLOAD_DOCUMENTS = 'can_upload_documents',
      // Buyer permissions
      CAN_BROWSE_PRODUCTS = 'can_browse_products',
      CAN_CREATE_ORDERS = 'can_create_orders',
      CAN_CHECKOUT = 'can_checkout',
      CAN_SAVE_FAVORITES = 'can_save_favorites',
      CAN_RATE_PRODUCTS = 'can_rate_products',
      // Driver permissions
      CAN_VIEW_JOBS = 'can_view_jobs',
      CAN_ACCEPT_JOBS = 'can_accept_jobs',
      CAN_TRACK_LOCATION = 'can_track_location',
      CAN_VIEW_EARNINGS = 'can_view_earnings',
      // Service Provider permissions
      CAN_MANAGE_SERVICES = 'can_manage_services',
      CAN_VIEW_BOOKINGS = 'can_view_bookings',
      CAN_SET_AVAILABILITY = 'can_set_availability',
      CAN_RECEIVE_RATINGS = 'can_receive_ratings',
      // Company permissions
      CAN_MANAGE_CATALOG = 'can_manage_catalog',
      CAN_VIEW_SALES_REPORT = 'can_view_sales_report',
      CAN_MANAGE_TEAM = 'can_manage_team';

  /// Get permissions for a specific role
  static Set<String> getPermissionsByRole(UserType userType) {
    switch (userType) {
      case UserType.farmer:
        return _getFarmerPermissions();
      case UserType.buyer:
        return _getBuyerPermissions();
      case UserType.driver:
        return _getDriverPermissions();
      case UserType.serviceProvider:
        return _getServiceProviderPermissions();
      case UserType.company:
        return _getCompanyPermissions();
      case UserType.seller:
        return _getCompanyPermissions();
    }
  }

  /// Check if user has specific permission
  static bool hasPermission(UserType userType, String permission) {
    return getPermissionsByRole(userType).contains(permission);
  }

  /// Get all permissions by role with descriptions
  static Map<String, String> getPermissionsWithDescriptions(UserType userType) {
    final permissions = getPermissionsByRole(userType);
    final descriptions = _getPermissionDescriptions();

    return {
      for (var perm in permissions)
        perm: descriptions[perm] ?? 'Unknown permission'
    };
  }

  // ====== FARMER PERMISSIONS ======
  static Set<String> _getFarmerPermissions() {
    return {
      CAN_LIST_PRODUCTS,
      CAN_MANAGE_ORDERS,
      CAN_VIEW_ANALYTICS,
      CAN_ACCESS_INPUTS_STORE,
      CAN_UPLOAD_DOCUMENTS,
    };
  }

  // ====== BUYER PERMISSIONS ======
  static Set<String> _getBuyerPermissions() {
    return {
      CAN_BROWSE_PRODUCTS,
      CAN_CREATE_ORDERS,
      CAN_CHECKOUT,
      CAN_SAVE_FAVORITES,
      CAN_RATE_PRODUCTS,
    };
  }

  // ====== DRIVER PERMISSIONS ======
  static Set<String> _getDriverPermissions() {
    return {
      CAN_VIEW_JOBS,
      CAN_ACCEPT_JOBS,
      CAN_TRACK_LOCATION,
      CAN_VIEW_EARNINGS,
    };
  }

  // ====== SERVICE PROVIDER PERMISSIONS ======
  static Set<String> _getServiceProviderPermissions() {
    return {
      CAN_MANAGE_SERVICES,
      CAN_VIEW_BOOKINGS,
      CAN_SET_AVAILABILITY,
      CAN_RECEIVE_RATINGS,
    };
  }

  // ====== COMPANY PERMISSIONS ======
  static Set<String> _getCompanyPermissions() {
    return {
      CAN_MANAGE_CATALOG,
      CAN_VIEW_SALES_REPORT,
      CAN_MANAGE_TEAM,
      CAN_CREATE_ORDERS,
      CAN_VIEW_ANALYTICS,
    };
  }

  /// Get permission descriptions in English and Bengali
  static Map<String, String> _getPermissionDescriptions() {
    return {
      CAN_LIST_PRODUCTS: 'List and manage products',
      CAN_MANAGE_ORDERS: 'Accept and manage orders',
      CAN_VIEW_ANALYTICS: 'View sales and performance analytics',
      CAN_ACCESS_INPUTS_STORE: 'Purchase agricultural inputs',
      CAN_UPLOAD_DOCUMENTS: 'Upload and verify documents',
      CAN_BROWSE_PRODUCTS: 'Browse available products',
      CAN_CREATE_ORDERS: 'Create and place orders',
      CAN_CHECKOUT: 'Checkout and complete purchases',
      CAN_SAVE_FAVORITES: 'Save favorite products and sellers',
      CAN_RATE_PRODUCTS: 'Rate products and sellers',
      CAN_VIEW_JOBS: 'View available delivery jobs',
      CAN_ACCEPT_JOBS: 'Accept and manage jobs',
      CAN_TRACK_LOCATION: 'Share location during delivery',
      CAN_VIEW_EARNINGS: 'View earnings and payment history',
      CAN_MANAGE_SERVICES: 'Add and manage services',
      CAN_VIEW_BOOKINGS: 'View and manage service bookings',
      CAN_SET_AVAILABILITY: 'Set service availability hours',
      CAN_RECEIVE_RATINGS: 'Receive customer ratings',
      CAN_MANAGE_CATALOG: 'Manage product catalog',
      CAN_VIEW_SALES_REPORT: 'View sales reports and analytics',
      CAN_MANAGE_TEAM: 'Manage team members',
    };
  }
}
