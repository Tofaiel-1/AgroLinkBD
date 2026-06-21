import 'package:flutter/material.dart';

/// Centralized auth constants and colors for all user roles
class AuthConstants {
  // Role colors
  static const Color farmerPrimary = Color(0xFF2E7D32); // Green
  static const Color buyerPrimary = Color(0xFF1976D2); // Blue
  static const Color driverPrimary = Color(0xFFF57C00); // Orange
  static const Color serviceProviderPrimary = Color(0xFF7B1FA2); // Purple
  static const Color companyPrimary = Color(0xFF0D47A1); // Navy

  // Common colors
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);

  // Spacing
  static const double padding16 = 16.0;
  static const double padding24 = 24.0;
  static const double padding32 = 32.0;
  static const double borderRadius = 12.0;

  // Auth field heights
  static const double textFieldHeight = 56.0;
  static const double buttonHeight = 48.0;

  // Role configurations
  static const Map<String, Map<String, dynamic>> roleConfig = {
    'farmer': {
      'color': farmerPrimary,
      'icon': '🌾',
      'label': 'কৃষক',
      'label_en': 'Farmer',
      'description': 'শস্য চাষ এবং বিক্রয়',
    },
    'buyer': {
      'color': buyerPrimary,
      'icon': '🛒',
      'label': 'ক্রেতা',
      'label_en': 'Buyer',
      'description': 'কৃষি পণ্য ক্রয়',
    },
    'driver': {
      'color': driverPrimary,
      'icon': '🚛',
      'label': 'চালক',
      'label_en': 'Driver',
      'description': 'পণ্য পরিবহন সেবা',
    },
    'service_provider': {
      'color': serviceProviderPrimary,
      'icon': '🔧',
      'label': 'সেবা প্রদানকারী',
      'label_en': 'Service Provider',
      'description': 'কৃষি সম্পর্কিত সেবা',
    },
    'company': {
      'color': companyPrimary,
      'icon': '🏢',
      'label': 'কোম্পানি',
      'label_en': 'Company',
      'description': 'কর্পোরেট সংস্থা',
    },
  };
}
