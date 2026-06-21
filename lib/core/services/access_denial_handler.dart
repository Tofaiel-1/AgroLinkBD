import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'route_guard.dart';

/// Access Denial Handler
/// Manages access denied scenarios with user-friendly feedback
class AccessDenialHandler {
  /// Show access denied toast
  static void showAccessDeniedToast(
    UserType userType,
    String attemptedRoute, {
    String? customMessage,
  }) {
    String message = customMessage ??
        RouteGuard.getAccessDenialReason(userType, attemptedRoute);

    Get.snackbar(
      '🚫 Access Denied',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
    );
  }

  /// Show access denied dialog
  static Future<void> showAccessDeniedDialog(
    BuildContext context,
    UserType userType,
    String attemptedRoute, {
    VoidCallback? onDismiss,
  }) async {
    final reason = RouteGuard.getAccessDenialReason(userType, attemptedRoute);
    final defaultRoute = RouteGuard.getDefaultRoute(userType);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock, color: Colors.red),
            SizedBox(width: 8),
            Text('Access Denied'),
          ],
        ),
        content: Text(reason),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDismiss?.call();
            },
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Get.offAllNamed(defaultRoute);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Go to Dashboard'),
          ),
        ],
      ),
    );
  }

  /// Show cross-role access attempt notification
  static void showCrossRoleAccessAttempt(
    UserType userType,
    String attemptedRoute,
  ) {
    final myRole = _getRoleDisplayName(userType);
    final attemptedRole = _extractRoleFromRoute(attemptedRoute);

    showAccessDeniedToast(
      userType,
      attemptedRoute,
      customMessage:
          'This is a $attemptedRole feature. You are accessing as $myRole.',
    );
  }

  /// Show permission denied notification
  static void showPermissionDenied(String featureName) {
    Get.snackbar(
      '🔒 Permission Required',
      'You don\'t have permission to access $featureName',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show feature not available notification
  static void showFeatureNotAvailable(String featureName) {
    Get.snackbar(
      '⚠️ Feature Not Available',
      '$featureName is not available for your role',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.shade600,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Helper: Get role display name
  static String _getRoleDisplayName(UserType userType) {
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

  /// Helper: Extract role from route
  static String _extractRoleFromRoute(String route) {
    if (route.contains('/farmer')) return 'Farmer';
    if (route.contains('/buyer')) return 'Buyer';
    if (route.contains('/driver')) return 'Driver';
    if (route.contains('/service-provider')) return 'Service Provider';
    if (route.contains('/company')) return 'Company';
    return 'Unknown';
  }
}

/// Navigation Security Middleware
/// Prevents unauthorized navigation at the widget level
class NavigationSecurityMiddleware {
  /// Wrap navigation action with security check
  static Future<T?> secureNavigate<T>(
    UserType userType,
    String routeName,
    Future<T?> Function() navigateFn, {
    bool showDialog = false,
  }) async {
    // Check access
    if (!RouteGuard.canAccess(userType, routeName)) {
      if (showDialog) {
        // Dialog will be shown by caller
        return null;
      } else {
        // Show toast
        AccessDenialHandler.showAccessDeniedToast(userType, routeName);
        return null;
      }
    }

    // Access granted, perform navigation
    try {
      return await navigateFn();
    } catch (e) {
      debugPrint('Navigation error: $e');
      return null;
    }
  }

  /// Check if navigation should be blocked
  static bool shouldBlockNavigation(UserType userType, String routeName) {
    return !RouteGuard.canAccess(userType, routeName);
  }

  /// Get redirection target
  static String getRedirectionTarget(UserType userType, String routeName) {
    return RouteGuard.validateAndGetRoute(userType, routeName);
  }
}

/// Role Access Violation Logger
/// Logs unauthorized access attempts for security auditing
class RoleAccessViolationLogger {
  static final List<AccessViolationLog> _violations = [];

  /// Log an access violation
  static void logViolation({
    required UserType userType,
    required String attemptedRoute,
    required DateTime timestamp,
    String? reason,
  }) {
    _violations.add(AccessViolationLog(
      userType: userType,
      attemptedRoute: attemptedRoute,
      timestamp: timestamp,
      reason: reason,
    ));

    debugPrint(
      '🚨 ACCESS VIOLATION: ${userType.toString().split('.').last} tried to access $attemptedRoute',
    );
  }

  /// Get all violations
  static List<AccessViolationLog> getViolations() => _violations;

  /// Get violations for a specific user type
  static List<AccessViolationLog> getViolationsForRole(UserType userType) {
    return _violations.where((v) => v.userType == userType).toList();
  }

  /// Clear violation logs
  static void clearLogs() {
    _violations.clear();
  }
}

/// Data class for logging access violations
class AccessViolationLog {
  final UserType userType;
  final String attemptedRoute;
  final DateTime timestamp;
  final String? reason;

  AccessViolationLog({
    required this.userType,
    required this.attemptedRoute,
    required this.timestamp,
    this.reason,
  });

  @override
  String toString() => '''
AccessViolationLog(
  role: ${userType.toString().split('.').last},
  route: $attemptedRoute,
  time: ${timestamp.toIso8601String()},
  reason: $reason
)''';
}
