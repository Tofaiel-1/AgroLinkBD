import 'package:flutter/material.dart';

/// Comprehensive color system for AgroLinkBD
/// Modern, accessibility-friendly color palette
class AppColors {
  AppColors._();

  // ========== PRIMARY COLORS (Role-Based) ==========
  /// Farmer Role - Fresh Green (Growth, Agriculture, Nature)
  static const Color farmerPrimary = Color(0xFF2E7D32);
  static const Color farmerLight = Color(0xFF81C784);
  static const Color farmerDark = Color(0xFF1B5E20);
  static const Color farmerAccent = Color(0xFFA5D6A7);

  /// Buyer Role - Professional Blue (Trust, Commerce, Stability)
  static const Color buyerPrimary = Color(0xFF1976D2);
  static const Color buyerLight = Color(0xFF64B5F6);
  static const Color buyerDark = Color(0xFF0D47A1);
  static const Color buyerAccent = Color(0xFF90CAF9);

  /// Driver Role - Vibrant Orange (Energy, Movement, Logistics)
  static const Color driverPrimary = Color(0xFFF57C00);
  static const Color driverLight = Color(0xFFFFB74D);
  static const Color driverDark = Color(0xFFE65100);
  static const Color driverAccent = Color(0xFFFFCC80);

  /// Service Provider Role - Rich Purple (Expertise, Professionalism)
  static const Color serviceProviderPrimary = Color(0xFF7B1FA2);
  static const Color serviceProviderLight = Color(0xFFBA68C8);
  static const Color serviceProviderDark = Color(0xFF4A148C);
  static const Color serviceProviderAccent = Color(0xFFCE93D8);

  // ========== SEMANTIC COLORS ==========
  /// Success - Green (for confirmations, completions)
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFC8E6C9);
  static const Color successDark = Color(0xFF2E7D32);

  /// Error - Red (for alerts, deletions)
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFEF9A9A);
  static const Color errorDark = Color(0xFFC62828);

  /// Warning - Amber (for caution, attention)
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFE082);
  static const Color warningDark = Color(0xFFFFA000);

  /// Info - Light Blue (for information)
  static const Color info = Color(0xFF29B6F6);
  static const Color infoLight = Color(0xFF81D4FA);
  static const Color infoDark = Color(0xFF0277BD);

  // ========== NEUTRAL COLORS ==========
  /// Background - Light neutral for cards, sections
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);

  /// Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textInverse = Color(0xFFFFFFFF);

  /// Border & Divider
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);

  /// Disabled
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color disabledSurface = Color(0xFFF5F5F5);

  // ========== GRADIENT COLORS ==========
  static const List<Color> farmerGradient = [farmerPrimary, farmerLight];
  static const List<Color> buyerGradient = [buyerPrimary, buyerLight];
  static const List<Color> driverGradient = [driverPrimary, driverLight];
  static const List<Color> serviceProviderGradient = [
    serviceProviderPrimary,
    serviceProviderLight
  ];

  /// Get role-specific color based on user role
  static Color getPrimaryColorForRole(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return farmerPrimary;
      case 'buyer':
        return buyerPrimary;
      case 'driver':
        return driverPrimary;
      case 'service_provider':
      case 'serviceprovider':
        return serviceProviderPrimary;
      default:
        return buyerPrimary; // Default to buyer blue
    }
  }

  /// Get role-specific gradient
  static List<Color> getGradientForRole(String role) {
    switch (role.toLowerCase()) {
      case 'farmer':
        return farmerGradient;
      case 'buyer':
        return buyerGradient;
      case 'driver':
        return driverGradient;
      case 'service_provider':
      case 'serviceprovider':
        return serviceProviderGradient;
      default:
        return buyerGradient;
    }
  }
}
