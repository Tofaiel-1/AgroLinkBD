import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:agrolinkbd/presentation/screens/buyer/shopping_cart_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';
import 'package:agrolinkbd/core/utils/responsive_helper.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';

class FishMarketplaceScreen extends StatefulWidget {
  const FishMarketplaceScreen({super.key});

  @override
  State<FishMarketplaceScreen> createState() => _FishMarketplaceScreenState();
}

class _FishMarketplaceScreenState extends State<FishMarketplaceScreen> {
  String _selectedCategory = 'সব';
  String _sortBy = 'popular';
  String _searchQuery = '';
  int _currentBannerIndex = 0;

  final List<String> _banners = [
    'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1000&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1516815231560-8f41ec531527?w=1000&auto=format&fit=crop&q=80',
    'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=1000&auto=format&fit=crop&q=80',
  ];

  final List<Map<String, dynamic>> _categories = [
    {'label': 'সব', 'key': 'all', 'icon': Icons.set_meal},
    {'label': 'মিঠা পানির মাছ', 'key': 'sweet_water', 'icon': Icons.water},
    {'label': 'সামুদ্রিক মাছ', 'key': 'sea_water', 'icon': Icons.waves},
    {'label': 'জীবন্ত মাছ', 'key': 'live', 'icon': Icons.pool},
    {'label': 'চিংড়ি ও কাঁকড়া', 'key': 'shrimp_crab', 'icon': Icons.phishing},
    {'label': 'বরফ ঢাকা', 'key': 'frozen', 'icon': Icons.ac_unit},
    {'label': 'শুটকি', 'key': 'dry', 'icon': Icons.wb_sunny},
    {'label': 'পোনা ও রেণু', 'key': 'fingerling', 'icon': Icons.opacity},
  ];

  final List<Map<String, dynamic>> _allFishProducts = [
    {
      'id': 'FP001',
      'title': 'পদ্মার তাজা ইলিশ (১.২ কেজি+ ওজনের)',
      'primaryCategory': 'সামুদ্রিক মাছ',
      'categories': ['সামুদ্রিক মাছ', 'বরফ ঢাকা'],
      'price': 1450,
      'unit': 'কেজি',
      'seller': 'চাঁদপুর ফিশার্স ফোরাম',
      'location': 'চাঁদপুর বন্দর',
      'rating': 4.9,
      'reviews': 142,
      'stock': '৩২০ কেজি',
      'isLive': false,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=600&auto=format&fit=crop&q=80',
      'description': 'পদ্মা ও মেঘনার মোহনা থেকে সরাসরি সংগৃহীত তাজা রুপালি ইলিশ। কোনো রাসায়নিক বা ফরমালিন মুক্ত, বরফ দিয়ে সংরক্ষিত টাটকা ইলিশ।'
    },
    {
      'id': 'FP002',
      'title': 'দেশি রুই মাছ (২.৫ - ৩ কেজি ওজনের তাজা)',
      'primaryCategory': 'মিঠা পানির মাছ',
      'categories': ['মিঠা পানির মাছ', 'জীবন্ত মাছ'],
      'price': 380,
      'unit': 'কেজি',
      'seller': 'করিম মৎস্য খামার',
      'location': 'নাটোর, রাজশাহী',
      'rating': 4.8,
      'reviews': 98,
      'stock': '৫৫০ কেজি',
      'isLive': true,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?w=600&auto=format&fit=crop&q=80',
      'description': 'রাজশাহীর চলনবিল ও খামারে প্রাকৃতিক খাবার দিয়ে চাষ করা দেশি রুই মাছ। সরাসরি খামার থেকে জীবন্ত বা তাজা ডেলিভারি।'
    },
    {
      'id': 'FP003',
      'title': 'জীবন্ত বাগদা চিংড়ি (রপ্তানি গ্রেড)',
      'primaryCategory': 'চিংড়ি ও কাঁকড়া',
      'categories': ['চিংড়ি ও কাঁকড়া', 'সামুদ্রিক মাছ', 'জীবন্ত মাছ'],
      'price': 950,
      'unit': 'কেজি',
      'seller': 'সাতক্ষীরা অ্যাকোয়া লিমিটেড',
      'location': 'শ্যামনগর, সাতক্ষীরা',
      'rating': 5.0,
      'reviews': 185,
      'stock': '১৮০ কেজি',
      'isLive': true,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=600&auto=format&fit=crop&q=80',
      'description': 'সাতক্ষীরার ঘের থেকে সরাসরি সংগৃহীত আন্তর্জাতিক মানের বাগদা চিংড়ি। সুস্বাদু ও পুষ্টিগুণে ভরপুর।'
    },
    {
      'id': 'FP004',
      'title': 'হালদা নদীর কাতলা মাছ (৩ কেজি+ সাইজ)',
      'primaryCategory': 'মিঠা পানির মাছ',
      'categories': ['মিঠা পানির মাছ'],
      'price': 420,
      'unit': 'কেজি',
      'seller': 'চট্টগ্রাম রিভার ক্যাচ',
      'location': 'হালদা নদী, চট্টগ্রাম',
      'rating': 4.7,
      'reviews': 76,
      'stock': '৪০০ কেজি',
      'isLive': false,
      'isPremium': false,
      'imageUrl': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=600&auto=format&fit=crop&q=80',
      'description': 'হালদা নদীর প্রাকৃতিক পরিবেশ থেকে ধরা তাজা কাতলা মাছ। তেলযুক্ত ও অত্যন্ত সুস্বাদু।'
    },
    {
      'id': 'FP005',
      'title': 'জীবন্ত দেশি কৈ মাছ (বায়োফ্লক লাইভ ট্যাংক)',
      'primaryCategory': 'জীবন্ত মাছ',
      'categories': ['জীবন্ত মাছ', 'মিঠা পানির মাছ'],
      'price': 480,
      'unit': 'কেজি',
      'seller': 'ময়মনসিংহ বায়োফ্লক খামার',
      'location': 'ত্রিশাল, ময়মনসিংহ',
      'rating': 4.9,
      'reviews': 110,
      'stock': '২২০ কেজি',
      'isLive': true,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1524704654690-b56c05c78a00?w=600&auto=format&fit=crop&q=80',
      'description': 'ময়মনসিংহের বায়োফ্লক খামারে উৎপাদিত ১০০% জীবন্ত দেশি কৈ মাছ। অক্সিজেন ট্যাংকের মাধ্যমে ডেলিভারি।'
    },
    {
      'id': 'FP006',
      'title': 'সামুদ্রিক কোরাল / ভেঁটকি মাছ (২ কেজি ওজনের)',
      'primaryCategory': 'সামুদ্রিক মাছ',
      'categories': ['সামুদ্রিক মাছ', 'বরফ ঢাকা'],
      'price': 750,
      'unit': 'কেজি',
      'seller': 'কক্সবাজার সি-ফুড হাব',
      'location': 'ফিশারি ঘাট, কক্সবাজার',
      'rating': 4.8,
      'reviews': 92,
      'stock': '১৫০ কেজি',
      'isLive': false,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1580476262798-bddd9f4b7369?w=600&auto=format&fit=crop&q=80',
      'description': 'বঙ্গোপসাগর থেকে গভীর সমুদ্রে ধরা তাজা কোরাল বা ভেঁটকি মাছ। ফিশ ফ্রাই ও বারবিকিউয়ের জন্য সেরা।'
    },
    {
      'id': 'FP007',
      'title': 'গলদা চিংড়ি (জম্বো সাইজ ১ কেজি প্যাক)',
      'primaryCategory': 'চিংড়ি ও কাঁকড়া',
      'categories': ['চিংড়ি ও কাঁকড়া', 'মিঠা পানির মাছ'],
      'price': 1100,
      'unit': 'কেজি',
      'seller': 'বাগেরহাট চিংড়ি চাষী সমিতি',
      'location': 'মংলা, বাগেরহাট',
      'rating': 4.9,
      'reviews': 165,
      'stock': '১৪০ কেজি',
      'isLive': false,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1559742811-822873691df8?w=600&auto=format&fit=crop&q=80',
      'description': 'বাগেরহাটের মিষ্টি ও আধা-লোনা পানির গলদা চিংড়ি। প্রতিটি মাছে প্রচুর মাথার ঘি ও বড় মাংসল শরীর।'
    },
    {
      'id': 'FP008',
      'title': 'পাবদা মাছ (দেশি টাটকা ১ কেজি প্যাক)',
      'primaryCategory': 'মিঠা পানির মাছ',
      'categories': ['মিঠা পানির মাছ'],
      'price': 550,
      'unit': 'কেজি',
      'seller': 'যশোর ফিশারি জোন',
      'location': 'চাঁচড়া, যশোর',
      'rating': 4.6,
      'reviews': 64,
      'stock': '৩০০ কেজি',
      'isLive': false,
      'isPremium': false,
      'imageUrl': 'https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?w=600&auto=format&fit=crop&q=80',
      'description': 'যশোরের হ্যাচারি ও খামারের টাটকা পাবদা মাছ। কাঁটাহীন ও শিশুদের খাওয়ার জন্য অত্যন্ত উপযোগী।'
    },
    {
      'id': 'FP009',
      'title': 'কক্সবাজারের রূপচাঁদা (সিলভার পমফ্রেট)',
      'primaryCategory': 'সামুদ্রিক মাছ',
      'categories': ['সামুদ্রিক মাছ', 'বরফ ঢাকা'],
      'price': 850,
      'unit': 'কেজি',
      'seller': 'কক্সবাজার মেরিন ফিশারিজ',
      'location': 'কক্সবাজার সদর',
      'rating': 4.9,
      'reviews': 130,
      'stock': '১৭০ কেজি',
      'isLive': false,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1534939561126-855b8675edd7?w=600&auto=format&fit=crop&q=80',
      'description': 'কক্সবাজারের সমুদ্র থেকে ধরা আসল সিলভার রূপচাঁদা মাছ। রেস্টুরেন্ট ও পরিবারের জন্য ফ্রেশ কোয়ালিটি।'
    },
    {
      'id': 'FP010',
      'title': 'লইট্টা শুটকি (কক্সবাজার স্পেশাল ড্রাই ফিশ)',
      'primaryCategory': 'শুটকি',
      'categories': ['শুটকি'],
      'price': 650,
      'unit': 'কেজি',
      'seller': 'মহেশখালী শুটকি ভান্ডার',
      'location': 'মহেশখালী, কক্সবাজার',
      'rating': 4.8,
      'reviews': 148,
      'stock': '১২০ কেজি',
      'isLive': false,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&auto=format&fit=crop&q=80',
      'description': 'মহেশখালীর রোদে প্রাকৃতিকভাবে শুকানো লইট্টা শুটকি। কোনো কীটনাশক বা লবণ ছাড়া স্বাস্থ্যসম্মত প্রক্রিয়ায় তৈরি।'
    },
    {
      'id': 'FP011',
      'title': 'জীবন্ত শিং মাছ (ফার্ম ফ্রেশ, দেশি জাত)',
      'primaryCategory': 'জীবন্ত মাছ',
      'categories': ['জীবন্ত মাছ', 'মিঠা পানির মাছ'],
      'price': 600,
      'unit': 'কেজি',
      'seller': 'মুক্তাগাছা ফিশার্স',
      'location': 'মুক্তাগাছা, ময়মনসিংহ',
      'rating': 4.9,
      'reviews': 88,
      'stock': '১৯০ কেজি',
      'isLive': true,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1510130387422-82ebdeffd616?w=600&auto=format&fit=crop&q=80',
      'description': 'রোগী ও শিশুদের জন্য পুষ্টিকর জীবন্ত দেশি শিং মাছ। সরাসরি খামার থেকে লাইভ ডেলিভারি।'
    },
    {
      'id': 'FP012',
      'title': 'নদীর বোয়াল মাছ (বড় সাইজ ৪ কেজি+)',
      'primaryCategory': 'মিঠা পানির মাছ',
      'categories': ['মিঠা পানির মাছ'],
      'price': 780,
      'unit': 'কেজি',
      'seller': 'সিলেট হাওর মৎস্য খামার',
      'location': 'সুনামগঞ্জ হাওর, সিলেট',
      'rating': 4.7,
      'reviews': 70,
      'stock': '১১০ কেজি',
      'isLive': false,
      'isPremium': false,
      'imageUrl': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=600&auto=format&fit=crop&q=80',
      'description': 'সুনামগঞ্জের টাঙ্গুয়ার হাওরের মিষ্টি পানির বড় বোয়াল মাছ। তেলযুক্ত ও সুস্বাদু দেশি বোয়াল।'
    },
    {
      'id': 'FP013',
      'title': 'সামুদ্রিক কাঁকড়া (লাইভ ও ফ্রেশ মড ক্র্যাব)',
      'primaryCategory': 'চিংড়ি ও কাঁকড়া',
      'categories': ['চিংড়ি ও কাঁকড়া', 'সামুদ্রিক মাছ', 'জীবন্ত মাছ'],
      'price': 700,
      'unit': 'কেজি',
      'seller': 'সুন্দরবন সি-ফুড প্রসেসিং',
      'location': 'রূপসা, খুলনা',
      'rating': 4.8,
      'reviews': 95,
      'stock': '৯০ কেজি',
      'isLive': true,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1559742811-822873691df8?w=600&auto=format&fit=crop&q=80',
      'description': 'সুন্দরবন উপকূলীয় অঞ্চল থেকে সংগৃহীত জীবন্ত মড ক্র্যাব। প্রচুর মাংসে ভরপুর ও রপ্তানি কোয়ালিটি।'
    },
    {
      'id': 'FP014',
      'title': 'মনোসেক্স তেলাপিয়া (জীবন্ত ও টাটকা)',
      'primaryCategory': 'মিঠা পানির মাছ',
      'categories': ['মিঠা পানির মাছ', 'জীবন্ত মাছ'],
      'price': 220,
      'unit': 'কেজি',
      'seller': 'বগুড়া অ্যাগ্রো ফিশারিজ',
      'location': 'শেরপুর, বগুড়া',
      'rating': 4.5,
      'reviews': 210,
      'stock': '৮০০ কেজি',
      'isLive': true,
      'isPremium': false,
      'imageUrl': 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?w=600&auto=format&fit=crop&q=80',
      'description': 'বগুড়ার খামারে চাষকৃত তাজা মনোসেক্স তেলাপিয়া। প্রতিদিন সকালে ধরা টাটকা মাছ।'
    },
    {
      'id': 'FP015',
      'title': 'রূপচাঁদা শুটকি (প্রিমিয়াম গ্রেড ড্রাই ফিশ)',
      'primaryCategory': 'শুটকি',
      'categories': ['শুটকি', 'সামুদ্রিক মাছ'],
      'price': 1250,
      'unit': 'কেজি',
      'seller': 'সেন্টমার্টিন শুটকি হাউজ',
      'location': 'টেকনাফ, কক্সবাজার',
      'rating': 5.0,
      'reviews': 115,
      'stock': '৬০ কেজি',
      'isLive': false,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&auto=format&fit=crop&q=80',
      'description': 'সেন্টমার্টিন দ্বীপের আসল রূপচাঁদা মাছের অর্গানিক শুটকি। কোনো প্রকার কেমিক্যাল বা বালু মুক্ত।'
    },
    {
      'id': 'FP016',
      'title': 'চ্যাপা শুটকি (ময়মনসিংহের ঐতিহ্যবাহী)',
      'primaryCategory': 'শুটকি',
      'categories': ['শুটকি'],
      'price': 900,
      'unit': 'কেজি',
      'seller': 'ময়মনসিংহ অর্গানিক শুটকি',
      'location': 'ময়মনসিংহ সদর',
      'rating': 4.9,
      'reviews': 140,
      'stock': '৮০ কেজি',
      'isLive': false,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&auto=format&fit=crop&q=80',
      'description': 'ময়মনসিংহের পুটি মাছ থেকে ঐতিহ্যবাহী পদ্ধতিতে তৈরি খাঁটি চ্যাপা শুটকি। অসাধারণ ঘ্রাণ ও স্বাদ।'
    },
    {
      'id': 'FP017',
      'title': 'পাঙ্গাস মাছ (তাজা ও বরফমুক্ত)',
      'primaryCategory': 'মিঠা পানির মাছ',
      'categories': ['মিঠা পানির মাছ'],
      'price': 180,
      'unit': 'কেজি',
      'seller': 'গাজীপুর ফিশ প্রজেক্ট',
      'location': 'শ্রীপুর, গাজীপুর',
      'rating': 4.6,
      'reviews': 310,
      'stock': '১২০০ কেজি',
      'isLive': false,
      'isPremium': false,
      'imageUrl': 'https://images.unsplash.com/photo-1615141982883-c7ad0e69fd62?w=600&auto=format&fit=crop&q=80',
      'description': 'গাজীপুরের খামারের ফ্রেশ পাঙ্গাস মাছ। কোনো আঁশটে গন্ধ মুক্ত ও পুষ্টিকর।'
    },
    {
      'id': 'FP018',
      'title': 'সামুদ্রিক টুনা ও টুনা ফিলেট (বরফ ঢাকা)',
      'primaryCategory': 'বরফ ঢাকা',
      'categories': ['বরফ ঢাকা', 'সামুদ্রিক মাছ'],
      'price': 950,
      'unit': 'কেজি',
      'seller': 'চট্টগ্রাম ওশান ফ্রেশ',
      'location': 'পতেঙ্গা, চট্টগ্রাম',
      'rating': 4.8,
      'reviews': 84,
      'stock': '২০০ কেজি',
      'isLive': false,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=600&auto=format&fit=crop&q=80',
      'description': 'গভীর সমুদ্রের তাজা টুনা মাছের বরফ ঢাকা ফিলেট ও গোটা মাছ। সুস্বাদু ও উচ্চ প্রোটিন সমৃদ্ধ।'
    },
    {
      'id': 'FP019',
      'title': 'দেশি টেংরা মাছ (নদীর টাটকা ১ কেজি)',
      'primaryCategory': 'মিঠা পানির মাছ',
      'categories': ['মিঠা পানির মাছ'],
      'price': 620,
      'unit': 'কেজি',
      'seller': 'চলনবিল মৎস্য ভান্ডার',
      'location': 'সিরাজগঞ্জ',
      'rating': 4.7,
      'reviews': 79,
      'stock': '১৫০ কেজি',
      'isLive': false,
      'isPremium': false,
      'imageUrl': 'https://images.unsplash.com/photo-1580476262798-bddd9f4b7369?w=600&auto=format&fit=crop&q=80',
      'description': 'চলনবিলের প্রাকৃতিক টেংরা মাছ। চচ্চড়ি ও ঝোলের জন্য অতুলনীয় স্বাদ।'
    },
    {
      'id': 'FP020',
      'title': 'রুই মাছের পোনা (রেণু ও পোনা সাপ্লাই)',
      'primaryCategory': 'পোনা ও রেণু',
      'categories': ['পোনা ও রেণু', 'মিঠা পানির মাছ'],
      'price': 1200,
      'unit': 'হাজার পিস',
      'seller': 'যশোর হ্যাচারি লিমিটেড',
      'location': 'যশোর সদর',
      'rating': 4.9,
      'reviews': 160,
      'stock': '৫০,০০০ পিস',
      'isLive': true,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1524704654690-b56c05c78a00?w=600&auto=format&fit=crop&q=80',
      'description': 'উচ্চ ফলনশীল রুই মাছের গ্রেড-১ পোনা। চাষীদের পুকুরে ছাড়ার জন্য ১০০% সুস্থ ও চটপটে পোনা।'
    },
    {
      'id': 'FP021',
      'title': 'কাতলা ও সিলভার কার্প পোনা (হ্যাচারি ফ্রেশ)',
      'primaryCategory': 'পোনা ও রেণু',
      'categories': ['পোনা ও রেণু', 'মিঠা পানির মাছ'],
      'price': 1100,
      'unit': 'হাজার পিস',
      'seller': 'বগুড়া হ্যাচারি কমপ্লেক্স',
      'location': 'বগুড়া সদর',
      'rating': 4.8,
      'reviews': 125,
      'stock': '৪০,০০০ পিস',
      'isLive': true,
      'isPremium': false,
      'imageUrl': 'https://images.unsplash.com/photo-1524704654690-b56c05c78a00?w=600&auto=format&fit=crop&q=80',
      'description': 'দ্রুত বর্ধনশীল কাতলা ও সিলভার কার্পের পোনা। অক্সিজেন ব্যাগে সারা দেশে পরিবহনের সুবিধা।'
    },
    {
      'id': 'FP022',
      'title': 'বরফ ঢাকা চিংড়ি (হোটেল ও রেস্টুরেন্ট প্যাক)',
      'primaryCategory': 'বরফ ঢাকা',
      'categories': ['বরফ ঢাকা', 'চিংড়ি ও কাঁকড়া'],
      'price': 880,
      'unit': 'কেজি',
      'seller': 'খুলনা সি-ফুড এক্সপোর্ট',
      'location': 'রূপসা, খুলনা',
      'rating': 4.9,
      'reviews': 140,
      'stock': '৩৫০ কেজি',
      'isLive': false,
      'isPremium': true,
      'imageUrl': 'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=600&auto=format&fit=crop&q=80',
      'description': 'হোটেল, রেস্টুরেন্ট ও ক্যাটারিংয়ের জন্য রেডি-টু-কুক বরফ ঢাকা চিংড়ি মাছ।'
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    var list = _allFishProducts.where((product) {
      final matchesCategory = _selectedCategory == 'সব' ||
          product['primaryCategory'] == _selectedCategory ||
          (product['categories'] as List<String>? ?? []).contains(_selectedCategory);
      final matchesSearch = _searchQuery.isEmpty ||
          (product['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product['seller'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product['location'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    if (_sortBy == 'price_low') {
      list.sort((a, b) => (a['price'] as int).compareTo(b['price'] as int));
    } else if (_sortBy == 'price_high') {
      list.sort((a, b) => (b['price'] as int).compareTo(a['price'] as int));
    } else if (_sortBy == 'rating') {
      list.sort((a, b) => (b['rating'] as double).compareTo(a['rating'] as double));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==========================================
          // APP BAR & SEARCH
          // ==========================================
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            floating: true,
            backgroundColor: const Color(0xFF0277BD),
            elevation: 0,
            title: Text(
              'মৎস্য ও সি-ফুড বাজার',
              style: GoogleFonts.hindSiliguri(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                        onPressed: () {
                          Get.to(() => const ShoppingCartScreen());
                        },
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 6,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '${cartProvider.itemCount}',
                              style: GoogleFonts.poppins(
                                color: Colors.black87,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.sort, color: Colors.white),
                onSelected: (value) => setState(() => _sortBy = value),
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'popular', child: Text('জনপ্রিয় ও নতুন', style: GoogleFonts.hindSiliguri())),
                  PopupMenuItem(value: 'price_low', child: Text('দাম: কম → বেশি', style: GoogleFonts.hindSiliguri())),
                  PopupMenuItem(value: 'price_high', child: Text('দাম: বেশি → কম', style: GoogleFonts.hindSiliguri())),
                  PopupMenuItem(value: 'rating', child: Text('সেরা রেটিং', style: GoogleFonts.hindSiliguri())),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0277BD), Color(0xFF00ACC1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2C3E50) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white24 : Colors.transparent),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: TextField(
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'কী মাছ খুঁজছেন? (যেমন: রুই, ইলিশ, চিংড়ি)',
                          hintStyle: GoogleFonts.hindSiliguri(color: isDark ? Colors.grey.shade400 : Colors.grey.shade500, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF0277BD)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // BANNER CAROUSEL
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
              child: SizedBox(
                height: 160,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: _banners.length,
                      onPageChanged: (index) => setState(() => _currentBannerIndex = index),
                      itemBuilder: (context, index) {
                        final titles = [
                          'বাংলাদেশের বৃহত্তম তাজা মাছের বাজার',
                          'নদী ও খামারের জীবন্ত মাছ সরাসরি অর্ডার করুন',
                          'কক্সবাজার ও চট্টগ্রামের সামুদ্রিক তাজা সি-ফুড',
                        ];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: NetworkImage(_banners[index]),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.65), Colors.transparent],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              titles[index],
                              style: GoogleFonts.hindSiliguri(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _banners.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentBannerIndex == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentBannerIndex == index ? const Color(0xFF0277BD) : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // CATEGORIES (Horizontal Scroll with Count Badge)
          // ==========================================
          SliverToBoxAdapter(
            child: SizedBox(
              height: 110,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['label'];

                  // Calculate item count in category
                  final count = _allFishProducts.where((p) {
                    return cat['label'] == 'সব' ||
                        p['primaryCategory'] == cat['label'] ||
                        (p['categories'] as List<String>).contains(cat['label']);
                  }).length;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat['label']),
                    child: Container(
                      width: 86,
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      child: Column(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                height: 58,
                                width: 58,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF0277BD)
                                      : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF0288D1)
                                        : (isDark ? Colors.white12 : Colors.grey.shade300),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                ),
                                child: Icon(
                                  cat['icon'],
                                  color: isSelected ? Colors.white : const Color(0xFF0277BD),
                                  size: 26,
                                ),
                              ),
                              Positioned(
                                right: -4,
                                top: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.amber : const Color(0xFF0277BD),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.black87 : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            cat['label'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF0277BD)
                                  : (isDark ? Colors.grey.shade300 : Colors.black87),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ==========================================
          // FILTER HEADER STRIP
          // ==========================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$_selectedCategory (${filtered.length} টি পণ্য)',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    TextButton.icon(
                      onPressed: () => setState(() => _searchQuery = ''),
                      icon: const Icon(Icons.clear, size: 14),
                      label: Text('সার্চ রিসেট', style: GoogleFonts.hindSiliguri(fontSize: 12)),
                    ),
                ],
              ),
            ),
          ),

          // ==========================================
          // PRODUCTS GRID OR EMPTY STATE
          // ==========================================
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'এই ক্যাটাগরিতে কোনো মাছ পাওয়া যায়নি',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'অন্য কোনো ক্যাটাগরি বেছে নিন অথবা সার্চ পরিবর্তন করুন',
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveHelper.getGridColumns(context),
                  childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.78 : 0.62,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = filtered[index];
                    return _buildFishProductCard(
                      product: product,
                      isDark: isDark,
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildFishProductCard({
    required Map<String, dynamic> product,
    required bool isDark,
  }) {
    final title = product['title'] as String;
    final price = product['price'] as int;
    final seller = product['seller'] as String;
    final location = product['location'] as String;
    final imageUrl = product['imageUrl'] as String;
    final rating = product['rating'] as double;
    final reviews = product['reviews'] as int;
    final stock = product['stock'] as String;
    final isLive = product['isLive'] as bool? ?? false;
    final isPremium = product['isPremium'] as bool? ?? false;

    return GestureDetector(
      onTap: () => _showProductDetailModal(context, product, isDark),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white12 : Colors.transparent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Badges
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: isDark ? const Color(0xFF0D47A1).withOpacity(0.3) : const Color(0xFFE1F5FE),
                        child: const Center(
                          child: Icon(Icons.set_meal, size: 48, color: Color(0xFF0277BD)),
                        ),
                      ),
                    ),
                  ),
                  // Top left badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      children: [
                        if (isPremium)
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'প্রিমিয়াম',
                              style: GoogleFonts.hindSiliguri(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        if (isLive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, size: 7, color: Colors.white),
                                const SizedBox(width: 3),
                                Text(
                                  'জীবন্ত',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Rating & Reviews badge on bottom right of image
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            '$rating ($reviews)',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Details Section
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.hindSiliguri(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$seller • $location',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '৳ $price / কেজি',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: const Color(0xFF0277BD),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0277BD).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'মজুদ: $stock',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF0277BD),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Buttons: Add to cart & Buy Now
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 34,
                            child: ElevatedButton(
                              onPressed: () => _addToCart(
                                title,
                                price.toString(),
                                seller,
                                location,
                                imageUrl,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? const Color(0xFF1976D2).withOpacity(0.2)
                                    : const Color(0xFFE3F2FD),
                                foregroundColor: const Color(0xFF0277BD),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Icon(Icons.shopping_cart_outlined, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 34,
                            child: ElevatedButton(
                              onPressed: () => _handleDirectPurchase(
                                title,
                                price.toDouble(),
                                seller,
                                imageUrl,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0277BD),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'এখুনি কিনুন',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetailModal(BuildContext context, Map<String, dynamic> product, bool isDark) {
    final title = product['title'] as String;
    final price = product['price'] as int;
    final seller = product['seller'] as String;
    final location = product['location'] as String;
    final imageUrl = product['imageUrl'] as String;
    final rating = product['rating'] as double;
    final reviews = product['reviews'] as int;
    final stock = product['stock'] as String;
    final description = product['description'] as String;
    final isLive = product['isLive'] as bool? ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.hindSiliguri(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '১০০% জীবন্ত মাছ',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$rating ($reviews জন ক্রেতা রেটিং দিয়েছেন)',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'মজুদ: $stock',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0277BD),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF0277BD).withOpacity(0.1),
                      child: const Icon(Icons.storefront, color: Color(0xFF0277BD)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                seller,
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.verified, size: 15, color: Colors.blue),
                            ],
                          ),
                          Text(
                            location,
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'পণ্যের বিবরণ:',
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.hindSiliguri(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade300 : Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'মূল্য (প্রতি কেজি)',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '৳ $price',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0277BD),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _addToCart(
                            title,
                            price.toString(),
                            seller,
                            location,
                            imageUrl,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0277BD),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add_shopping_cart, size: 20),
                        label: Text(
                          'কার্টে যোগ করুন',
                          style: GoogleFonts.hindSiliguri(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addToCart(String title, String priceStr, String seller, String location, String imageUrl) {
    final double price = double.tryParse(priceStr) ?? 0.0;
    final String id = 'fish_${title.hashCode}_${seller.hashCode}';
    final String nowIso = DateTime.now().toIso8601String();

    final item = CartItem(
      id: id,
      title: title,
      price: price,
      unit: 'কেজি',
      quantity: 1.0,
      imageUrl: imageUrl,
      itemType: CartItemType.product,
      sellerId: 'seller_${seller.hashCode}',
      sellerName: seller,
      sellerRole: 'fishFarmer',
      metadata: {
        'addedAt': nowIso,
        'location': location,
        'category': 'fish',
        'history': [nowIso],
      },
    );

    Provider.of<CartProvider>(context, listen: false).addToCart(item);

    Get.snackbar(
      'কার্টে যোগ করা হয়েছে 🛒',
      '$title (১ কেজি) আপনার কার্টে যোগ করা হয়েছে।',
      backgroundColor: const Color(0xFF0277BD),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () {
          Get.to(() => const ShoppingCartScreen());
        },
        child: Text(
          'কার্ট দেখুন',
          style: GoogleFonts.hindSiliguri(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Future<void> _handleDirectPurchase(String title, double price, String seller, String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'ত্রুটি',
        'দয়া করে লগইন করুন',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    final success = await SSLCommerzService.initiatePayment(
      context: context,
      amount: price,
      productName: title,
      customerName: user.displayName ?? "Fish Buyer",
      customerEmail: user.email ?? "buyer@example.com",
      customerPhone: "01700000000",
      customerAddress: "Dhaka, Bangladesh",
    );

    if (success) {
      final orderId = 'ORD_${DateTime.now().millisecondsSinceEpoch}';
      final newOrder = OrderModel(
        id: orderId,
        buyerId: user.uid,
        farmerId: 'FARMER_123',
        farmerName: seller,
        productName: title,
        productImageUrl: imageUrl,
        quantity: 1.0,
        totalAmount: price,
        status: 'Processing',
        statusStep: 2,
        transportStatus: 'অর্ডার গৃহীত হয়েছে',
        paymentStatus: 'Paid via SSLCommerz',
        createdAt: DateTime.now(),
      );

      final orderService = OrderService();
      await orderService.createOrder(newOrder);
      Get.to(() => const FishBuyerOrdersScreen());
    }
  }
}
