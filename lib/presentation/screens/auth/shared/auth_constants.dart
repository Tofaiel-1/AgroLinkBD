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

  // Role configurations organized by domain
  static const Map<String, Map<String, Map<String, dynamic>>> domainRoles = {
    'agriculture': {
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
      'expert': {
        'color': Color(0xFF6A1B9A), // Purple
        'icon': '👨‍🔬',
        'label': 'বিশেষজ্ঞ',
        'label_en': 'Expert',
        'description': 'কৃষি পরামর্শদাতা',
      },
    },
    'fisheries': {
      'fish_farmer': {
        'color': Color(0xFF0288D1), // Light Blue
        'icon': '👨‍🌾',
        'label': 'মৎস্য চাষী',
        'label_en': 'Fish Farmer',
        'description': 'মাছ চাষ এবং খামার পরিচালনা',
      },
      'fish_buyer': {
        'color': Color(0xFF0097A7), // Cyan
        'icon': '🛒',
        'label': 'মৎস্য ক্রেতা',
        'label_en': 'Fish Buyer',
        'description': 'মাছ ক্রয় (পাইকারি ও খুচরা)',
      },
      'fish_driver': {
        'color': Color(0xFFF57C00), // Orange
        'icon': '🚚',
        'label': 'মৎস্য পরিবহন চালক',
        'label_en': 'Fish Transport Driver',
        'description': 'মাছ পরিবহন সেবা',
      },
      'fish_service_provider': {
        'color': Color(0xFF00796B), // Teal
        'icon': '🔧',
        'label': 'মৎস্য সেবা প্রদানকারী',
        'label_en': 'Fisheries Service Provider',
        'description': 'পুকুর পরিষ্কার, পানি পরীক্ষা ইত্যাদি',
      },
      'fish_company': {
        'color': Color(0xFF303F9F), // Indigo
        'icon': '🏢',
        'label': 'মৎস্য কোম্পানি',
        'label_en': 'Fisheries Company',
        'description': 'মৎস্য ফিড ও মেডিসিন কোম্পানি',
      },
      'fish_expert': {
        'color': Color(0xFF512DA8), // Deep Purple
        'icon': '👨‍🔬',
        'label': 'মৎস্য বিশেষজ্ঞ',
        'label_en': 'Fisheries Expert',
        'description': 'মৎস্য রোগ ও চিকিৎসা পরামর্শ',
      },
      'hatchery': {
        'color': Color(0xFF009688), // Teal
        'icon': '🏭',
        'label': 'হ্যাচারি মালিক',
        'label_en': 'Hatchery Owner',
        'description': 'পোনা উৎপাদন এবং বিক্রয়',
      },
    }
  };

  // Backwards compatibility for old code assuming roleConfig
  static Map<String, Map<String, dynamic>> get roleConfig {
    final Map<String, Map<String, dynamic>> combined = {};
    combined.addAll(domainRoles['agriculture']!);
    combined.addAll(domainRoles['fisheries']!);
    return combined;
  }
}
