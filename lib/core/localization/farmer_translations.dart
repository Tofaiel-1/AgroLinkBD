import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';

class FarmerTranslations {
  static const Map<String, Map<String, String>> _strings = {
    // General
    'farmer': {'bn': 'কৃষক', 'en': 'Farmer'},
    'change_language': {'bn': 'ভাষা পরিবর্তন করুন', 'en': 'Change Language'},
    'select_language': {'bn': 'ভাষা নির্বাচন করুন', 'en': 'Select Language'},

    // Dashboard Greetings
    'good_morning': {'bn': 'শুভ সকাল', 'en': 'Good Morning'},
    'good_afternoon': {'bn': 'শুভ দুপুর', 'en': 'Good Afternoon'},
    'good_evening': {'bn': 'শুভ বিকাল', 'en': 'Good Evening'},
    'good_night': {'bn': 'শুভ রাত্রি', 'en': 'Good Night'},

    // Dashboard Header Cards
    'main_rating': {'bn': 'মূল রেটিং', 'en': 'Main Rating'},
    'trusted_user': {'bn': '১০০% বিশ্বস্ত ইউজার', 'en': '100% Trusted User'},
    'truck_booking': {'bn': 'ট্রাক বুকিং', 'en': 'Truck Booking'},
    'emergency_transport': {
      'bn': 'জরুরি শস্য পরিবহন',
      'en': 'Emergency Transport',
    },

    // Weather Cards
    'current_weather': {'bn': 'বর্তমান আবহাওয়া', 'en': 'Current Weather'},
    'humidity': {'bn': 'আর্দ্রতা', 'en': 'Humidity'},
    'wind': {'bn': 'বাতাস', 'en': 'Wind Speed'},
    'rain_chance': {'bn': 'বৃষ্টির সম্ভাবনা', 'en': 'Rain Chance'},
    'live_weather_news': {
      'bn': 'লাইভ আবহাওয়া ও কৃষি সংবাদ',
      'en': 'Live Weather & Agri News',
    },

    // Dashboard Sections & Actions
    'quick_actions': {'bn': 'দ্রুত সেবা সমূহ', 'en': 'Quick Actions'},
    'daily_tasks': {'bn': 'আজকের কাজ', 'en': 'Daily Tasks'},
    'live_market_price': {'bn': 'লাইভ বাজার দর', 'en': 'Live Market Prices'},
    'activity_report': {'bn': 'অ্যাক্টিভিটি রিপোর্ট', 'en': 'Activity Report'},
    'total_income': {'bn': 'মোট আয়', 'en': 'Total Income'},
    'total_expense': {'bn': 'মোট খরচ', 'en': 'Total Expense'},
    'tap_to_view': {'bn': 'দেখতে ট্যাপ করুন', 'en': 'Tap to view'},
    'sell_crop': {'bn': 'ফসল বিক্রি', 'en': 'Sell Crop'},
    'emergency': {'bn': 'জরুরি সেবা', 'en': 'Emergency'},
    'disease_check': {'bn': 'রোগ নির্ণয়', 'en': 'Disease Check'},
    'crop_suitability': {'bn': 'ফসল উপযোগিতা', 'en': 'Suitability'},
    'fertilizer_rec': {'bn': 'সার সুপারিশ', 'en': 'Fertilizer'},
    'crop_zone': {'bn': 'ফসল জোন', 'en': 'Crop Zone'},
    'crop_pattern': {'bn': 'ফসল বিন্যাস', 'en': 'Crop Pattern'},
    'saved_data': {'bn': 'সংরক্ষিত', 'en': 'Saved Data'},
    'soil_health': {'bn': 'মাটির গুণাগুণ', 'en': 'Soil Health'},
    'agri_expert': {'bn': 'কৃষি বিশেষজ্ঞ', 'en': 'Agri Expert'},
    'transport': {'bn': 'পরিবহন', 'en': 'Transport'},
    'payment': {'bn': 'পেমেন্ট', 'en': 'Payment'},
    'agri_loan': {'bn': 'কৃষি ঋণ', 'en': 'Agri Loan'},
    'premium_services_title': {
      'bn': 'প্রিমিয়াম কৃষি ও মৎস্য সেবা 💎',
      'en': 'Premium Agro & Fisheries Services 💎',
    },
    'sell_product': {'bn': 'পণ্য বিক্রি করুন', 'en': 'Sell Products'},
    'emergency_service': {'bn': 'জরুরি সেবা', 'en': 'Emergency Service'},
    'disease_detection': {'bn': 'রোগ নির্ণয়', 'en': 'Disease Detection'},
    'agri_info_service': {
      'bn': 'কৃষি তথ্য ও সেবা',
      'en': 'Agri Info & Service',
    },
    'my_farms': {'bn': 'আমার খামার', 'en': 'My Farms'},
    'agri_machinery': {'bn': 'কৃষি যন্ত্রপাতি', 'en': 'Agri Machinery'},
    'market_price': {'bn': 'বাজার দর', 'en': 'Market Price'},
    'agri_bank_loan': {'bn': 'কৃষি ব্যাংক ও ঋণ', 'en': 'Agri Bank & Loan'},
    'expert_consult': {'bn': 'বিশেষজ্ঞ পরামর্শ', 'en': 'Expert Consult'},
    'govt_subsidy': {'bn': 'সরকারি অনুদান', 'en': 'Govt Subsidy'},
    'agri_forum': {'bn': 'কৃষি ফোরাম', 'en': 'Agri Forum'},

    // Farm Management Screen
    'my_farms_title': {'bn': 'আমার খামার সমূহ', 'en': 'My Farms'},
    'my_farms_subtitle': {
      'bn': 'আপনার খামারের সকল তথ্য ও হিসাব পরিচালনা করুন',
      'en': 'Manage all information and accounts of your farms',
    },
    'farm_modules_title': {
      'bn': 'খামার ব্যবস্থাপনা মডিউল',
      'en': 'Farm Management Modules',
    },

    // Farm Management Modules (Titles)
    'mod_farm_mgmt_title': {
      'bn': 'খামার ব্যবস্থাপনা',
      'en': 'Farm Management',
    },
    'mod_crop_prod_title': {'bn': 'ফসল উৎপাদন', 'en': 'Crop Production'},
    'mod_expense_title': {'bn': 'খরচ ব্যবস্থাপনা', 'en': 'Expense Mgmt'},
    'mod_revenue_title': {'bn': 'আয় ও লাভ', 'en': 'Revenue & Profit'},
    'mod_task_title': {'bn': 'কাজ ব্যবস্থাপনা', 'en': 'Task Management'},
    'mod_inventory_title': {'bn': 'মালামাল ও মজুত', 'en': 'Inventory'},
    'mod_gallery_title': {'bn': 'খামারের গ্যালারি', 'en': 'Farm Gallery'},
    'mod_gps_title': {'bn': 'জিপিএস ম্যাপিং', 'en': 'GPS Mapping'},
    'mod_harvest_title': {'bn': 'ফসল তোলার হিসাব', 'en': 'Harvest Tracking'},
    'mod_yield_title': {'bn': 'ফলনের পূর্বাভাস', 'en': 'Yield Prediction'},
    'mod_notif_title': {'bn': 'নোটিফিকেশন', 'en': 'Farm Notifications'},

    // Farm Management Modules (Subtitles)
    'mod_farm_mgmt_sub': {'bn': 'বিবরণ ও সেটআপ', 'en': 'Details & Setup'},
    'mod_crop_prod_sub': {'bn': 'ট্র্যাকিং ও বৃদ্ধি', 'en': 'Tracking & Growth'},
    'mod_expense_sub': {'bn': 'খরচ ও ব্যয়', 'en': 'Costs & Spending'},
    'mod_revenue_sub': {'bn': 'বিক্রয় ও মুনাফা', 'en': 'Sales & Margins'},
    'mod_task_sub': {'bn': 'করণীয় ও কর্মী', 'en': 'To-Dos & Staff'},
    'mod_inventory_sub': {'bn': 'বীজ ও সার', 'en': 'Seeds & Fertilizer'},
    'mod_gallery_sub': {'bn': 'ছবি ও মিডিয়া', 'en': 'Photos & Media'},
    'mod_gps_sub': {'bn': 'সীমানা ও এলাকা', 'en': 'Borders & Zones'},
    'mod_harvest_sub': {'bn': 'ফলন ও লগ', 'en': 'Yields & Logs'},
    'mod_yield_sub': {'bn': 'এআই পূর্বাভাস', 'en': 'AI Forecasts'},
    'mod_notif_sub': {
      'bn': 'সতর্কবার্তা ও রিমাইন্ডার',
      'en': 'Alerts & Reminders',
    },
  };

  /// Main reactive lookup method for translating keys
  static String tr(BuildContext context, String key) {
    final bool isBn = LanguageProvider.isBn(context);
    final langCode = isBn ? 'bn' : 'en';
    return _strings[key]?[langCode] ?? key;
  }

  /// Non-reactive lookup method
  static String trStatic(BuildContext context, String key) {
    final bool isBn = LanguageProvider.isBnStatic(context);
    final langCode = isBn ? 'bn' : 'en';
    return _strings[key]?[langCode] ?? key;
  }
}
