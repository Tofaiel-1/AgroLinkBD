/// Complete Admin Panel Screens
///
/// This file exports all admin panel screens for easy import

// Login & Authentication
export 'admin_login_screen_v2.dart';

// Main Dashboard & Navigation
export 'admin_main_dashboard.dart';
export 'admin_panel_navigation.dart';

// Advanced Screens (New)
export 'advanced_admin_dashboard.dart';
export 'admin_kyc_verification_screen.dart';
export 'admin_orders_management_screen.dart';
export 'admin_transactions_monitoring_screen.dart';
export 'admin_support_tickets_screen.dart';
export 'admin_content_management_screen.dart';
export 'admin_drivers_management_screen.dart';
export 'admin_services_provider_management_screen.dart';
export 'admin_logs_audit_screen.dart';
export 'admin_analytics_reports_screen.dart';
export 'admin_system_settings_screen.dart';

// Legacy Admin Screens
export 'admin_user_management_screen.dart';
export 'admin_analytics_screen.dart';
export 'admin_settings_screen.dart';

// Usage:
//
// 1. For Login Screen with Firebase Storage Error Handling:
//    Get.to(() => const AdminLoginScreen());
//    // Handles: Super Admin Product Login, Firebase Storage Errors
//
// 2. For Advanced Dashboard (New):
//    Get.to(() => const AdvancedAdminDashboard());
//
// 3. For Full Admin Panel:
//    Get.to(() => const AdminPanelNavigation());
//
// 4. For Individual Advanced Screens:
//    Get.to(() => const AdminKYCVerificationScreen());
//    Get.to(() => const AdminOrderManagementScreen());
//    Get.to(() => const AdminTransactionMonitoringScreen());
//    Get.to(() => const AdminSupportTicketScreen());
//    Get.to(() => const AdminContentManagementScreen());
//    Get.to(() => const AdminDriversManagementScreen());
//    Get.to(() => const AdminServiceProviderManagementScreen());
//    Get.to(() => const AdminLogsAuditScreen());
//    Get.to(() => const AdminAnalyticsReportsScreen());
//    Get.to(() => const AdminSystemSettingsScreen());
//
// Firebase Storage Error Handling:
// - The login screen automatically handles Firebase Storage errors
// - On "object-not-found" error, default admin product is created
// - All errors are logged and displayed to user
