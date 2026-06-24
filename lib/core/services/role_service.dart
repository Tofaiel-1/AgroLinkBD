import 'package:flutter/material.dart';
import '../models/user_model.dart';

/// Role-Based Feature Definition
class RoleFeature {
  final String id;
  final String title;
  final String titleBN;
  final String description;
  final IconData icon;
  final Color color;
  final String routeName;
  final bool isAvailable;
  final String? requiredPermission;

  RoleFeature({
    required this.id,
    required this.title,
    required this.titleBN,
    required this.description,
    required this.icon,
    required this.color,
    required this.routeName,
    this.isAvailable = true,
    this.requiredPermission,
  });
}

/// Role-Based Service - Manages personalized content for each role
class RoleService {
  /// Get features for specific user role
  static List<RoleFeature> getFeaturesByRole(UserType userType) {
    switch (userType) {
      case UserType.farmer:
        return _getFarmerFeatures();
      case UserType.buyer:
        return _getBuyerFeatures();
      case UserType.driver:
        return _getDriverFeatures();
      case UserType.serviceProvider:
        return _getServiceProviderFeatures();
      case UserType.company:
        return _getCompanyFeatures();
    }
  }

  /// Get dashboard navigation items for specific role
  static List<Map<String, dynamic>> getNavigationItems(UserType userType) {
    switch (userType) {
      case UserType.farmer:
        return [
          {'label': 'Home', 'labelBN': 'হোম', 'icon': Icons.home},
          {'label': 'Farms', 'labelBN': 'খামার', 'icon': Icons.agriculture},
          {
            'label': 'Analytics',
            'labelBN': 'বিশ্লেষণ',
            'icon': Icons.analytics
          },
          {'label': 'Marketplace', 'labelBN': 'বাজার', 'icon': Icons.shop},
          {
            'label': 'Settings',
            'labelBN': 'সেটিংস',
            'icon': Icons.settings
          },
        ];
      case UserType.buyer:
        return [
          {'label': 'Home', 'labelBN': 'হোম', 'icon': Icons.home},
          {
            'label': 'Marketplace',
            'labelBN': 'বাজার',
            'icon': Icons.storefront
          },
          {
            'label': 'Cart',
            'labelBN': 'কার্ট',
            'icon': Icons.shopping_cart
          },
          {
            'label': 'Orders',
            'labelBN': 'অর্ডার',
            'icon': Icons.receipt_long
          },
          {
            'label': 'Settings',
            'labelBN': 'সেটিংস',
            'icon': Icons.settings
          },
        ];
      case UserType.driver:
        return [
          {'label': 'Home', 'labelBN': 'হোম', 'icon': Icons.home},
          {
            'label': 'Deliveries',
            'labelBN': 'ডেলিভারি',
            'icon': Icons.delivery_dining
          },
          {
            'label': 'Analytics',
            'labelBN': 'বিশ্লেষণ',
            'icon': Icons.analytics
          },
          {'label': 'Job Board', 'labelBN': 'নতুন কাজ', 'icon': Icons.local_shipping},
          {
            'label': 'Settings',
            'labelBN': 'সেটিংস',
            'icon': Icons.settings
          },
        ];
      case UserType.serviceProvider:
        return [
          {'label': 'Home', 'labelBN': 'হোম', 'icon': Icons.home},
          {'label': 'Portfolio', 'labelBN': 'পোর্টফোলিও', 'icon': Icons.image},
          {
            'label': 'Analytics',
            'labelBN': 'বিশ্লেষণ',
            'icon': Icons.analytics
          },
          {'label': 'Marketplace', 'labelBN': 'বাজার', 'icon': Icons.shop},
          {
            'label': 'Settings',
            'labelBN': 'সেটিংস',
            'icon': Icons.settings
          },
        ];
      case UserType.company:
        return [
          {
            'label': 'ড্যাশবোর্ড',
            'labelBN': 'ড্যাশবোর্ড',
            'icon': Icons.dashboard
          },
          {'label': 'টিম', 'labelBN': 'টিম', 'icon': Icons.people},
          {
            'label': 'বিশ্লেষণ',
            'labelBN': 'বিশ্লেষণ',
            'icon': Icons.analytics
          },
          {'label': 'অর্ডার', 'labelBN': 'অর্ডার', 'icon': Icons.shopping_bag},
          {'label': 'চুক্তি', 'labelBN': 'চুক্তি', 'icon': Icons.assignment},
        ];
    }
  }

  /// Get role display name
  static String getRoleName(UserType userType) {
    switch (userType) {
      case UserType.farmer:
        return 'Farmer';
      case UserType.buyer:
        return 'Buyer';
      case UserType.driver:
        return 'Driver';
      case UserType.serviceProvider:
        return 'Service Provider';
      case UserType.company:
        return 'Company';
    }
  }

  /// Get role display name in Bengali
  static String getRoleNameBN(UserType userType) {
    switch (userType) {
      case UserType.farmer:
        return 'কৃষক';
      case UserType.buyer:
        return 'ক্রেতা';
      case UserType.driver:
        return 'চালক';
      case UserType.serviceProvider:
        return 'সেবা প্রদানকারী';
      case UserType.company:
        return 'কোম্পানি';
    }
  }

  /// Get role color
  static Color getRoleColor(UserType userType) {
    switch (userType) {
      case UserType.farmer:
        return const Color(0xFF2E7D32); // Green
      case UserType.buyer:
        return const Color(0xFF1976D2); // Blue
      case UserType.driver:
        return const Color(0xFFF57C00); // Orange
      case UserType.serviceProvider:
        return const Color(0xFF7B1FA2); // Purple
      case UserType.company:
        return const Color(0xFF0D47A1); // Dark Blue
    }
  }

  // ====== FARMER FEATURES ======
  static List<RoleFeature> _getFarmerFeatures() {
    return [
      RoleFeature(
        id: 'add_product',
        title: 'Add Product',
        titleBN: 'পণ্য যোগ করুন',
        description: 'List your crops and products',
        icon: Icons.add_circle,
        color: Colors.green,
        routeName: '/farmer/add-product',
      ),
      RoleFeature(
        id: 'my_products',
        title: 'My Products',
        titleBN: 'আমার পণ্য',
        description: 'Manage your inventory',
        icon: Icons.inventory,
        color: Colors.teal,
        routeName: '/farmer/my-products',
      ),
      RoleFeature(
        id: 'orders_received',
        title: 'Orders Received',
        titleBN: 'প্রাপ্ত অর্ডার',
        description: 'View and manage orders',
        icon: Icons.receipt,
        color: Colors.blue,
        routeName: '/farmer/orders',
      ),
      RoleFeature(
        id: 'sales_analytics',
        title: 'Sales Analytics',
        titleBN: 'বিক্রয় বিশ্লেষণ',
        description: 'Track your sales performance',
        icon: Icons.bar_chart,
        color: Colors.orange,
        routeName: '/farmer/analytics',
      ),
      RoleFeature(
        id: 'inputs_store',
        title: 'Inputs Store',
        titleBN: 'ইনপুট স্টোর',
        description: 'Buy agricultural inputs',
        icon: Icons.store,
        color: Colors.purple,
        routeName: '/farmer/inputs',
      ),
      RoleFeature(
        id: 'kyc_verification',
        title: 'KYC Verification',
        titleBN: 'কেওয়াইসি যাচাইকরণ',
        description: 'Complete your profile verification',
        icon: Icons.verified_user,
        color: Colors.indigo,
        routeName: '/farmer/kyc',
      ),
    ];
  }

  // ====== BUYER FEATURES ======
  static List<RoleFeature> _getBuyerFeatures() {
    return [
      RoleFeature(
        id: 'browse_products',
        title: 'Browse Products',
        titleBN: 'পণ্য ব্রাউজ করুন',
        description: 'Explore available products',
        icon: Icons.shopping_bag,
        color: Colors.blue,
        routeName: '/buyer/browse',
      ),
      RoleFeature(
        id: 'shopping_cart',
        title: 'Shopping Cart',
        titleBN: 'কেনাকাটার ঝুড়ি',
        description: 'Manage your shopping cart',
        icon: Icons.shopping_cart,
        color: Colors.orange,
        routeName: '/buyer/cart',
      ),
      RoleFeature(
        id: 'my_orders',
        title: 'My Orders',
        titleBN: 'আমার অর্ডার',
        description: 'Track your orders',
        icon: Icons.receipt_long,
        color: Colors.green,
        routeName: '/buyer/orders',
      ),
      RoleFeature(
        id: 'saved_farmers',
        title: 'Saved Farmers',
        titleBN: 'সংরক্ষিত কৃষক',
        description: 'View your favorite farmers',
        icon: Icons.favorite,
        color: Colors.red,
        routeName: '/buyer/saved-farmers',
      ),
      RoleFeature(
        id: 'payment_methods',
        title: 'Payment Methods',
        titleBN: 'পেমেন্ট পদ্ধতি',
        description: 'Manage payment options',
        icon: Icons.payment,
        color: Colors.purple,
        routeName: '/buyer/payments',
      ),
    ];
  }

  // ====== DRIVER FEATURES ======
  static List<RoleFeature> _getDriverFeatures() {
    return [
      RoleFeature(
        id: 'available_jobs',
        title: 'Available Jobs',
        titleBN: 'উপলব্ধ কাজ',
        description: 'Find delivery jobs',
        icon: Icons.work,
        color: Colors.blue,
        routeName: '/driver/jobs',
      ),
      RoleFeature(
        id: 'active_trips',
        title: 'Active Trips',
        titleBN: 'সক্রিয় ট্রিপ',
        description: 'Manage ongoing deliveries',
        icon: Icons.route,
        color: Colors.orange,
        routeName: '/driver/active-trips',
      ),
      RoleFeature(
        id: 'trip_history',
        title: 'Trip History',
        titleBN: 'ট্রিপ ইতিহাস',
        description: 'View past trips',
        icon: Icons.history,
        color: Colors.green,
        routeName: '/driver/history',
      ),
      RoleFeature(
        id: 'earnings',
        title: 'Earnings',
        titleBN: 'আয়',
        description: 'Track your earnings',
        icon: Icons.money,
        color: Colors.purple,
        routeName: '/driver/earnings',
      ),
      RoleFeature(
        id: 'vehicle_info',
        title: 'Vehicle Info',
        titleBN: 'যানবাহন তথ্য',
        description: 'Manage vehicle details',
        icon: Icons.directions_car,
        color: Colors.indigo,
        routeName: '/driver/vehicle',
      ),
    ];
  }

  // ====== SERVICE PROVIDER FEATURES ======
  static List<RoleFeature> _getServiceProviderFeatures() {
    return [
      RoleFeature(
        id: 'manage_services',
        title: 'Manage Services',
        titleBN: 'সেবা পরিচালনা করুন',
        description: 'Add and manage your services',
        icon: Icons.work,
        color: Colors.purple,
        routeName: '/service/manage',
      ),
      RoleFeature(
        id: 'service_bookings',
        title: 'Bookings',
        titleBN: 'বুকিং',
        description: 'View service bookings',
        icon: Icons.calendar_today,
        color: Colors.blue,
        routeName: '/service/bookings',
      ),
      RoleFeature(
        id: 'service_earnings',
        title: 'Earnings',
        titleBN: 'আয়',
        description: 'Track your earnings',
        icon: Icons.money,
        color: Colors.green,
        routeName: '/service/earnings',
      ),
      RoleFeature(
        id: 'service_reviews',
        title: 'Reviews',
        titleBN: 'পর্যালোচনা',
        description: 'View customer reviews',
        icon: Icons.star,
        color: Colors.orange,
        routeName: '/service/reviews',
      ),
      RoleFeature(
        id: 'service_availability',
        title: 'Availability',
        titleBN: 'উপলব্ধতা',
        description: 'Set your working hours',
        icon: Icons.schedule,
        color: Colors.indigo,
        routeName: '/service/availability',
      ),
    ];
  }

  // ====== COMPANY FEATURES ======
  static List<RoleFeature> _getCompanyFeatures() {
    return [
      RoleFeature(
        id: 'products_catalog',
        title: 'Products Catalog',
        titleBN: 'পণ্য ক্যাটালগ',
        description: 'Manage your product catalog',
        icon: Icons.inventory_2,
        color: Colors.blue,
        routeName: '/company/catalog',
      ),
      RoleFeature(
        id: 'sales_dashboard',
        title: 'Sales Dashboard',
        titleBN: 'বিক্রয় ড্যাশবোর্ড',
        description: 'View sales analytics',
        icon: Icons.bar_chart,
        color: Colors.orange,
        routeName: '/company/sales',
      ),
      RoleFeature(
        id: 'orders_management',
        title: 'Order Management',
        titleBN: 'অর্ডার ব্যবস্থাপনা',
        description: 'Manage all orders',
        icon: Icons.list_alt,
        color: Colors.green,
        routeName: '/company/orders',
      ),
      RoleFeature(
        id: 'customer_management',
        title: 'Customers',
        titleBN: 'গ্রাহক',
        description: 'Manage customer relationships',
        icon: Icons.people,
        color: Colors.purple,
        routeName: '/company/customers',
      ),
      RoleFeature(
        id: 'analytics',
        title: 'Analytics',
        titleBN: 'বিশ্লেষণ',
        description: 'View detailed analytics',
        icon: Icons.analytics,
        color: Colors.indigo,
        routeName: '/company/analytics',
      ),
    ];
  }
}
