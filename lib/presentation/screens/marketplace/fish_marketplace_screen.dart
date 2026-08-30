import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agrolinkbd/presentation/screens/buyer/shopping_cart_screen.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/farmer/auction/create_fish_auction_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/fish_buyer_qc_inspection_screen.dart';

class FishMarketplaceScreen extends StatefulWidget {
  final bool showAppBar;
  const FishMarketplaceScreen({super.key, this.showAppBar = true});

  @override
  State<FishMarketplaceScreen> createState() => _FishMarketplaceScreenState();
}

class _FishMarketplaceScreenState extends State<FishMarketplaceScreen> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'সব';
  String _sortBy = 'popular';
  String _searchQuery = '';
  bool _isWholesaleMode = false;
  int _currentBannerIndex = 0;
  late PageController _bannerPageController;
  Timer? _bannerTimer;

  late Duration _flashDuration;
  Timer? _flashTimer;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'সব', 'key': 'all', 'icon': Icons.set_meal, 'count': '২২+'},
    {'label': 'পদ্মার ইলিশ ও নদীর মাছ', 'key': 'river', 'icon': Icons.waves, 'count': '৮'},
    {'label': 'জীবন্ত অক্সিজেন ট্যাংক', 'key': 'live', 'icon': Icons.pool, 'count': '৬'},
    {'label': 'গলদা ও বাগদা চিংড়ি', 'key': 'shrimp_crab', 'icon': Icons.phishing, 'count': '৫'},
    {'label': 'পাইকারি বড় লট (৫০+ কেজি)', 'key': 'wholesale', 'icon': Icons.inventory_2, 'count': '১০'},
    {'label': 'সামুদ্রিক ও রূপচাঁদা', 'key': 'marine', 'icon': Icons.sailing, 'count': '৭'},
    {'label': 'মহেশখালী অর্গানিক শুটকি', 'key': 'dry', 'icon': Icons.wb_sunny, 'count': '৪'},
    {'label': 'হ্যাচারি পোনা ও রেণু', 'key': 'fingerling', 'icon': Icons.opacity, 'count': '৩'},
  ];

  final List<Map<String, dynamic>> _heroFlashDeals = [
    {
      'id': 'FLASH_1',
      'title': 'চাঁদপুর মোহনার পদ্মার তাজা রূপালী ইলিশ',
      'weight': '১.৩ - ১.৬ কেজি/পিস',
      'price': 1450,
      'wholesalePrice': 1350,
      'discount': '১৫% ছাড়',
      'tag': 'ভোর ৪:৩০ এ চাঁদপুর মোহনা থেকে আহরিত',
      'image': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=900&auto=format&fit=crop&q=80',
      'location': 'চাঁদপুর ফিশারি ঘাট',
      'seller': 'চাঁদপুর মোহনা ইলিশ ফোরাম',
      'stock': '৪৫০ কেজি লট',
      'verified': true,
      'phone': '01711002233',
    },
    {
      'id': 'FLASH_2',
      'title': 'সাতক্ষীরার রপ্তানি গ্রেড জম্বো বাগদা চিংড়ি',
      'weight': '২০-২৫ পিস/কেজি (জম্বো)',
      'price': 950,
      'wholesalePrice': 880,
      'discount': '১০% পাইকারি ছাড়',
      'tag': 'ঘের থেকে সরাসরি জীবন্ত সংগ্রহ',
      'image': 'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=900&auto=format&fit=crop&q=80',
      'location': 'শ্যামনগর, সাতক্ষীরা',
      'seller': 'সাতক্ষীরা সী-ফুড এক্সপোর্ট',
      'stock': '২০০ কেজি লট',
      'verified': true,
      'phone': '01711445566',
    },
    {
      'id': 'FLASH_3',
      'title': 'হালদা নদীর তেলযুক্ত তাজা বড় কাতলা মাছ',
      'weight': '৪ - ৫.৫ কেজি সাইজ',
      'price': 440,
      'wholesalePrice': 390,
      'discount': 'পাইকারি বিশেষ লট',
      'tag': 'প্রাকৃতিক হালদা নদীর খাঁটি স্বাদ',
      'image': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80',
      'location': 'হালদা নদী, চট্টগ্রাম',
      'seller': 'চট্টগ্রাম রিভার ক্যাচ এন্টারপ্রাইজ',
      'stock': '৬০০ কেজি লট',
      'verified': true,
      'phone': '01811889900',
    },
  ];

  final List<Map<String, dynamic>> _allFishProducts = [
    {
      'id': 'FP001',
      'title': 'পদ্মার তাজা ইলিশ (১.২ - ১.৫ কেজি ওজনের)',
      'primaryCategory': 'পদ্মার ইলিশ ও নদীর মাছ',
      'categories': ['পদ্মার ইলিশ ও নদীর মাছ', 'পাইকারি বড় লট (৫০+ কেজি)'],
      'price': 1450,
      'wholesalePrice': 1350,
      'minWholesaleKg': 30,
      'unit': 'কেজি',
      'seller': 'চাঁদপুর মোহনা ফিশার্স অ্যাসোসিয়েশন',
      'location': 'চাঁদপুর বন্দর ঘাট',
      'rating': 4.9,
      'reviews': 248,
      'stock': '৩২০ কেজি',
      'isLive': false,
      'isPremium': true,
      'harvestTime': 'আজ ভোর ৫:৩০ AM',
      'puritySeal': '১০০% ফরমালিন মুক্ত সার্টিফাইড',
      'deliveryMode': 'থার্মোকল বরফ বক্স / এক্সপ্রেস ভ্যান',
      'imageUrl': 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=700&auto=format&fit=crop&q=80',
      'description': 'চাঁদপুরের পদ্মা ও মেঘনা মিলনস্থল থেকে সরাসরি ভোরে ধরা খাঁটি চকচকে রূপালী ইলিশ। কোনো বরফের রাসায়নিক নেই, শতভাগ টাটকা ও ডিমযুক্ত স্বাদ।',
      'phone': '01711002233',
    },
    {
      'id': 'FP002',
      'title': 'দেশি রুই মাছ (২.৫ - ৩.৫ কেজি ওজনের তাজা)',
      'primaryCategory': 'পদ্মার ইলিশ ও নদীর মাছ',
      'categories': ['পদ্মার ইলিশ ও নদীর মাছ', 'জীবন্ত অক্সিজেন ট্যাংক', 'পাইকারি বড় লট (৫০+ কেজি)'],
      'price': 380,
      'wholesalePrice': 330,
      'minWholesaleKg': 50,
      'unit': 'কেজি',
      'seller': 'রাজশাহী চলনবিল অ্যাকোয়াকালচার',
      'location': 'সিংড়া, নাটোর',
      'rating': 4.8,
      'reviews': 185,
      'stock': '৭৫০ কেজি',
      'isLive': true,
      'isPremium': true,
      'harvestTime': 'আজ সকাল ৬:১৫ AM',
      'puritySeal': 'প্রাকৃতিক প্রোটিন ফিডে চাষকৃত',
      'deliveryMode': 'অক্সিজেন লাইভ ভ্যান ডেলিভারি',
      'imageUrl': 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?w=700&auto=format&fit=crop&q=80',
      'description': 'চলনবিলের পরিষ্কার পানিতে প্রাকৃতিক খাদ্য দিয়ে বড় করা খাঁটি দেশি রুই মাছ। লাল টুকটুকে তাজা ফুলকা ও শক্ত আঁশযুক্ত মাংস।',
      'phone': '01711223344',
    },
    {
      'id': 'FP003',
      'title': 'জীবন্ত বাগদা চিংড়ি (রপ্তানি গ্রেড-১)',
      'primaryCategory': 'গলদা ও বাগদা চিংড়ি',
      'categories': ['গলদা ও বাগদা চিংড়ি', 'সামুদ্রিক ও রূপচাঁদা', 'জীবন্ত অক্সিজেন ট্যাংক'],
      'price': 950,
      'wholesalePrice': 870,
      'minWholesaleKg': 20,
      'unit': 'কেজি',
      'seller': 'সাতক্ষীরা ব্লু-অ্যাকোয়া লিমিটেড',
      'location': 'শ্যামনগর, সাতক্ষীরা',
      'rating': 5.0,
      'reviews': 310,
      'stock': '১৮০ কেজি',
      'isLive': true,
      'isPremium': true,
      'harvestTime': 'আজ ভোর ৫:০০ AM',
      'puritySeal': 'ইইউ এক্সপোর্ট কোয়ালিটি সার্টিফাইড',
      'deliveryMode': 'অক্সিজেন স্যাচুরেটেড ওয়াটার প্যাক',
      'imageUrl': 'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=700&auto=format&fit=crop&q=80',
      'description': 'সাতক্ষীরার লোনা পানির প্রাকৃতিক ঘের থেকে সংগৃহীত সরাসরি আন্তর্জাতিক মানের গ্রেড-১ বাগদা চিংড়ি। দারুণ মিষ্টি স্বাদ ও খাস্তা টেক্সচার।',
      'phone': '01711556677',
    },
    {
      'id': 'FP004',
      'title': 'হালদা নদীর কাতলা মাছ (৪ কেজি+ সাইজ)',
      'primaryCategory': 'পদ্মার ইলিশ ও নদীর মাছ',
      'categories': ['পদ্মার ইলিশ ও নদীর মাছ', 'পাইকারি বড় লট (৫০+ কেজি)'],
      'price': 420,
      'wholesalePrice': 380,
      'minWholesaleKg': 40,
      'unit': 'কেজি',
      'seller': 'চট্টগ্রাম রিভার ফ্রেশ কো-অপারেটিভ',
      'location': 'হালদা ঘাট, রাউজান',
      'rating': 4.9,
      'reviews': 142,
      'stock': '৫০০ কেজি',
      'isLive': false,
      'isPremium': true,
      'harvestTime': 'আজ ভোর ৪:৪৫ AM',
      'puritySeal': 'হালদা নদীর ঐতিহ্যবাহী প্রাকৃতিক মাছ',
      'deliveryMode': 'থার্মোকল ক্র্যাশড আইস বক্স',
      'imageUrl': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=700&auto=format&fit=crop&q=80',
      'description': 'বিশ্বখ্যাত প্রাকৃতিক মৎস্য প্রজনন ক্ষেত্র হালদা নদীর সুবিশাল সুস্বাদু কাতলা মাছ। পেটিতে প্রচুর মিষ্টি চর্বি ও কোমল মাংস।',
      'phone': '01811334455',
    },
    {
      'id': 'FP005',
      'title': 'জীবন্ত দেশি শিং মাছ (বায়োফ্লক ট্যাংক ফ্রেশ)',
      'primaryCategory': 'জীবন্ত অক্সিজেন ট্যাংক',
      'categories': ['জীবন্ত অক্সিজেন ট্যাংক', 'পদ্মার ইলিশ ও নদীর মাছ'],
      'price': 600,
      'wholesalePrice': 540,
      'minWholesaleKg': 15,
      'unit': 'কেজি',
      'seller': 'ময়মনসিংহ প্রিমিয়ার বায়োফ্লক হাব',
      'location': 'ত্রিশাল, ময়মনসিংহ',
      'rating': 4.9,
      'reviews': 178,
      'stock': '২২০ কেজি',
      'isLive': true,
      'isPremium': true,
      'harvestTime': 'লাইভ ট্যাংক থেকে সরাসরি অর্ডার অনুযায়ী তোলা হবে',
      'puritySeal': '১০০% জীবন্ত গ্যারান্টি • রক্তস্বল্পতায় আদর্শ',
      'deliveryMode': 'লাইভ অক্সিজেন ব্যাগ বা ট্যাংক ভ্যান',
      'imageUrl': 'https://images.unsplash.com/photo-1524704654690-b56c05c78a00?w=700&auto=format&fit=crop&q=80',
      'description': 'রোগী, প্রসূতি মা ও শিশুদের জন্য পুষ্টিগুণে সেরা শতভাগ জীবন্ত দেশি শিং মাছ। সম্পূর্ণ ড্রাগ-মুক্ত ও প্রাকৃতিক পরিবেশে উৎপাদিত।',
      'phone': '01911998877',
    },
    {
      'id': 'FP006',
      'title': 'কক্সবাজারের রূপচাঁদা (সিলভার পমফ্রেট ১ কেজি প্যাক)',
      'primaryCategory': 'সামুদ্রিক ও রূপচাঁদা',
      'categories': ['সামুদ্রিক ও রূপচাঁদা', 'পাইকারি বড় লট (৫০+ কেজি)'],
      'price': 850,
      'wholesalePrice': 780,
      'minWholesaleKg': 25,
      'unit': 'কেজি',
      'seller': 'কক্সবাজার ডিপ-সী ট্রলার ফোরাম',
      'location': 'ফিশারি ঘাট, কক্সবাজার',
      'rating': 4.9,
      'reviews': 215,
      'stock': '৩০০ কেজি',
      'isLive': false,
      'isPremium': true,
      'harvestTime': 'গতকাল রাতে গভীর বঙ্গোপসাগর থেকে আসা ট্রলার',
      'puritySeal': 'রপ্তানি গ্রেড সিলভার রূপচাঁদা',
      'deliveryMode': 'চিলড কোল্ড চেইন ট্রান্সপোর্ট',
      'imageUrl': 'https://images.unsplash.com/photo-1534939561126-855b8675edd7?w=700&auto=format&fit=crop&q=80',
      'description': 'কক্সবাজারের গভীর সমুদ্রের আসল সিলভার রূপচাঁদা মাছ। ফাইভ স্টার রেস্তোরাঁ ও হোম ডাইনিংয়ের জন্য সর্বোচ্চ মানের ফ্রাই সাইজ।',
      'phone': '01811667788',
    },
    {
      'id': 'FP007',
      'title': 'গলদা চিংড়ি (জম্বো সাইজ ৫০০ গ্রাম - ১ কেজি প্যাক)',
      'primaryCategory': 'গলদা ও বাগদা চিংড়ি',
      'categories': ['গলদা ও বাগদা চিংড়ি', 'পদ্মার ইলিশ ও নদীর মাছ'],
      'price': 1100,
      'wholesalePrice': 990,
      'minWholesaleKg': 15,
      'unit': 'কেজি',
      'seller': 'বাগেরহাট গলদা চাষী সমিতি',
      'location': 'মংলা রোড, বাগেরহাট',
      'rating': 4.9,
      'reviews': 260,
      'stock': '১৪০ কেজি',
      'isLive': false,
      'isPremium': true,
      'harvestTime': 'আজ ভোর ৬:০০ AM',
      'puritySeal': 'মাথায় ভরপুর লাল ঘি গ্যারান্টি',
      'deliveryMode': 'আইসড থার্মোকল বক্স',
      'imageUrl': 'https://images.unsplash.com/photo-1559742811-822873691df8?w=700&auto=format&fit=crop&q=80',
      'description': 'বাগেরহাটের মিষ্টি পানির সুবিশাল গলদা চিংড়ি। প্রতিটি চিংড়ির মাথায় রয়েছে সুস্বাদু লাল ঘি এবং মোটা মাংসল শরীর।',
      'phone': '01711889911',
    },
    {
      'id': 'FP008',
      'title': 'সুন্দরবনের জীবন্ত মাড ক্র্যাব (বড় সাইজের কাঁকড়া)',
      'primaryCategory': 'গলদা ও বাগদা চিংড়ি',
      'categories': ['গলদা ও বাগদা চিংড়ি', 'সামুদ্রিক ও রূপচাঁদা', 'জীবন্ত অক্সিজেন ট্যাংক'],
      'price': 720,
      'wholesalePrice': 650,
      'minWholesaleKg': 20,
      'unit': 'কেজি',
      'seller': 'খুলনা সুন্দরবন সি-ফুড প্রসেসিং',
      'location': 'রূপসা ঘাট, খুলনা',
      'rating': 4.8,
      'reviews': 130,
      'stock': '১১০ কেজি',
      'isLive': true,
      'isPremium': true,
      'harvestTime': 'সুন্দরবন খাঁড়ি থেকে সরাসরি সংগৃহীত',
      'puritySeal': '১০০% জীবিত ও মাংসে টাইট কাঁকড়া',
      'deliveryMode': 'স্পেশাল ব্রিদিং ব্যাম্বু ক্রাফট বক্স',
      'imageUrl': 'https://images.unsplash.com/photo-1559742811-822873691df8?w=700&auto=format&fit=crop&q=80',
      'description': 'সুন্দরবনের প্রাকৃতিক লোনা খাঁড়ির বড় সাইজের জীবন্ত কাঁকড়া। প্রচুর নরম মাংস ও ঘিয়ে ভরপুর এক্সপোর্ট কোয়ালিটি।',
      'phone': '01711332211',
    },
    {
      'id': 'FP009',
      'title': 'সামুদ্রিক কোরাল / ভেঁটকি মাছ (২ - ৩ কেজি সাইজ)',
      'primaryCategory': 'সামুদ্রিক ও রূপচাঁদা',
      'categories': ['সামুদ্রিক ও রূপচাঁদা', 'পাইকারি বড় লট (৫০+ কেজি)'],
      'price': 750,
      'wholesalePrice': 680,
      'minWholesaleKg': 30,
      'unit': 'কেজি',
      'seller': 'কক্সবাজার সী-ফুড ট্রেডিং',
      'location': 'টেকনাফ কোস্টাল জোন',
      'rating': 4.8,
      'reviews': 112,
      'stock': '১৯০ কেজি',
      'isLive': false,
      'isPremium': true,
      'harvestTime': 'আজ ভোর ৫:০০ AM',
      'puritySeal': 'বারবিকিউ ও ফিশ ফিলেটের জন্য সেরা',
      'deliveryMode': 'কোল্ড চেইন এক্সপ্রেস ভ্যান',
      'imageUrl': 'https://images.unsplash.com/photo-1580476262798-bddd9f4b7369?w=700&auto=format&fit=crop&q=80',
      'description': 'বঙ্গোপসাগরের গভীর জলসীমা থেকে সংগৃহীত প্রিমিয়াম সাইজের সাদা কোরাল বা ভেঁটকি মাছ। ফিশ ফ্রাই ও তন্দুরি বারবিকিউয়ের জন্য অতুলনীয়।',
      'phone': '01811443322',
    },
    {
      'id': 'FP010',
      'title': 'সেন্টমার্টিন অর্গানিক রূপচাঁদা শুটকি (লবণ ও কেমিক্যালমুক্ত)',
      'primaryCategory': 'মহেশখালী অর্গানিক শুটকি',
      'categories': ['মহেশখালী অর্গানিক শুটকি', 'সামুদ্রিক ও রূপচাঁদা'],
      'price': 1250,
      'wholesalePrice': 1120,
      'minWholesaleKg': 10,
      'unit': 'কেজি',
      'seller': 'সেন্টমার্টিন ড্রাইড ফিশ এন্টারপ্রাইজ',
      'location': 'সেন্টমার্টিন দ্বীপ, কক্সবাজার',
      'rating': 5.0,
      'reviews': 165,
      'stock': '৮০ কেজি',
      'isLive': false,
      'isPremium': true,
      'harvestTime': 'প্রাকৃতিক সূর্যালোক ও সামুদ্রিক বাতাসে শুকানো',
      'puritySeal': '১০০% কীটনাশক ও বালুকামুক্ত অর্গানিক',
      'deliveryMode': 'ভ্যাকুয়াম সিলড প্রিমিয়াম পাউচ',
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=700&auto=format&fit=crop&q=80',
      'description': 'সেন্টমার্টিন দ্বীপের আসল রূপচাঁদা মাছের স্বাস্থ্যসম্মত অর্গানিক শুটকি। কোনো কীটনাশক, বিষাক্ত লবণ বা ধুলাবালি স্পর্শ করেনি।',
      'phone': '01811554433',
    },
    {
      'id': 'FP011',
      'title': 'উচ্চ ফলনশীল রুই ও কাতলার উন্নত জাতের পোনা (রেণু ও ফিঙ্গারলিং)',
      'primaryCategory': 'হ্যাচারি পোনা ও রেণু',
      'categories': ['হ্যাচারি পোনা ও রেণু', 'পদ্মার ইলিশ ও নদীর মাছ'],
      'price': 1200,
      'wholesalePrice': 1050,
      'minWholesaleKg': 10,
      'unit': 'হাজার পিস',
      'seller': 'যশোর সরকারি সার্টিফাইড হ্যাচারি কমপ্লেক্স',
      'location': 'চাঁচড়া, যশোর',
      'rating': 4.9,
      'reviews': 195,
      'stock': '৮০,০০০ পিস',
      'isLive': true,
      'isPremium': true,
      'harvestTime': 'হ্যাচারি ট্যাংক থেকে লাইভ অক্সিজেন ব্যাগে প্যাক হবে',
      'puritySeal': '১০০% রোগমুক্ত এসপিএফ ব্রুড স্টক',
      'deliveryMode': 'অক্সিজেন বেলুন ট্রিপল লেয়ার ব্যাগ',
      'imageUrl': 'https://images.unsplash.com/photo-1524704654690-b56c05c78a00?w=700&auto=format&fit=crop&q=80',
      'description': 'উচ্চ বৃদ্ধি ও রোগ প্রতিরোধক্ষমতাসম্পন্ন অরিজিনাল রুই ও কাতলার গ্রেড-১ পোনা। সারা দেশে ৭২ ঘন্টার অক্সিজেন সহনশীল ব্যাগে পরিবহন।',
      'phone': '01711667788',
    },
    {
      'id': 'FP012',
      'title': 'সুপার মনোসেক্স গিফট তেলাপিয়া (বড় আড়ত লট ৫০০ কেজি+)',
      'primaryCategory': 'পাইকারি বড় লট (৫০+ কেজি)',
      'categories': ['পাইকারি বড় লট (৫০+ কেজি)', 'জীবন্ত অক্সিজেন ট্যাংক'],
      'price': 220,
      'wholesalePrice': 185,
      'minWholesaleKg': 100,
      'unit': 'কেজি',
      'seller': 'বগুড়া মেগা অ্যাকোয়াকালচার জোন',
      'location': 'শেরপুর, বগুড়া',
      'rating': 4.7,
      'reviews': 340,
      'stock': '২,৫০০ কেজি',
      'isLive': true,
      'isPremium': false,
      'harvestTime': 'আজ সকাল ৭:০০ AM হারভেস্ট শুরু',
      'puritySeal': 'সুপারস্টোর ও পাইকারি আড়তদারদের জন্য প্রস্তুত',
      'deliveryMode': 'ট্যাঙ্কার ট্রাক বা বরফ ভ্যান',
      'imageUrl': 'https://images.unsplash.com/photo-1534483509719-3feaee7c30da?w=700&auto=format&fit=crop&q=80',
      'description': 'প্রতিটি মাছ ৫০০-৭০০ গ্রাম ওজনের মনোসেক্স গিফট তেলাপিয়া। হোটেল, রেস্তোরাঁ ও সুপারশপের জন্য সরাসরি খামার রেটে বিশাল লট।',
      'phone': '01711990011',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController();
    _startBannerAutoScroll();

    _flashDuration = const Duration(hours: 4, minutes: 28, seconds: 45);
    _startFlashTimer();
  }

  void _startBannerAutoScroll() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && _bannerPageController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _heroFlashDeals.length;
        _bannerPageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _startFlashTimer() {
    _flashTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _flashDuration.inSeconds > 0) {
        setState(() {
          _flashDuration = _flashDuration - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _bannerPageController.dispose();
    _bannerTimer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    var list = _allFishProducts.where((product) {
      final matchesCategory = _selectedCategory == 'সব' ||
          product['primaryCategory'] == _selectedCategory ||
          (product['categories'] as List<String>? ?? []).contains(_selectedCategory);
      final matchesSearch = _searchQuery.isEmpty ||
          (product['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product['seller'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (product['location'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesWholesale = !_isWholesaleMode || (product['categories'] as List<String>? ?? []).contains('পাইকারি বড় লট (৫০+ কেজি)');
      return matchesCategory && matchesSearch && matchesWholesale;
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

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      Get.snackbar('কল করা যাচ্ছে না', 'নম্বর: $phoneNumber', backgroundColor: Colors.red.shade100);
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final fullNumber = cleanNumber.startsWith('88') ? cleanNumber : '88$cleanNumber';
    final Uri url = Uri.parse('https://wa.me/$fullNumber?text=আমি%20অ্যাগ্রোলিংক%20বিডি%20বিগ%20ফিশ%20মার্কেট%20থেকে%20মাছ%20কিনতে%20আগ্রহী।');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _makePhoneCall(phoneNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color deepOcean = Color(0xFF00363A);
    const Color tealAccent = Color(0xFF006064);

    final filtered = _filteredProducts;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A1218) : const Color(0xFFF1F5F8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (widget.showAppBar)
            SliverAppBar(
              expandedHeight: 175.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: deepOcean,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.set_meal, color: Color(0xFF80DEEA), size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'বিগ ফিশ মার্কেট ও হোলসেল হাব',
                        style: GoogleFonts.hindSiliguri(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF002528), Color(0xFF004D40), Color(0xFF01579B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 45, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF80DEEA).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.trending_up, color: Colors.greenAccent, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'আজকের রেট: ইলিশ ৳১৪৫০/কেজি ↑ | কাতলা ৳৪২০ | বাগদা ৳৯৫০ | রুই ৳৩৮০',
                                style: GoogleFonts.hindSiliguri(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.verified_user_outlined, color: Color(0xFF80DEEA)),
                  tooltip: 'ল্যাব ও কোয়ালিটি সনদ',
                  onPressed: () => Get.to(() => const FishBuyerQcInspectionScreen()),
                ),
                Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                          tooltip: 'শপিং কার্ট',
                          onPressed: () => Get.to(() => const ShoppingCartScreen()),
                        ),
                        if (cart.itemCount > 0)
                          Positioned(
                            right: 6,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.deepOrange,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                              child: Text(
                                '${cart.itemCount}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16252F) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'মাছের নাম, নদী/ঘের বা আড়তদার খুঁজুন...',
                        hintStyle: GoogleFonts.hindSiliguri(color: Colors.grey.shade500, fontSize: 13.5),
                        prefixIcon: const Icon(Icons.search, color: tealAccent),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setState(() => _searchQuery = ''),
                              )
                            : const Icon(Icons.mic, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isWholesaleMode
                            ? [const Color(0xFF004D40), const Color(0xFF006064)]
                            : [Colors.teal.shade50, Colors.cyan.shade50],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.teal.shade300.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_shipping,
                          color: _isWholesaleMode ? Colors.white : tealAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isWholesaleMode ? 'পাইকারি আড়ত মোড সক্রিয় (৫০+ কেজি লট)' : 'খুচরা ও পারিবারিক বাজার মোড',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _isWholesaleMode ? Colors.white : Colors.teal.shade900,
                                ),
                              ),
                              Text(
                                _isWholesaleMode ? 'আড়তদার ও সুপারশপের জন্য বিশেষ রেট' : 'পাইকারি মূল্যে কিনতে মোড চালু করুন',
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 11,
                                  color: _isWholesaleMode ? Colors.white70 : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isWholesaleMode,
                          activeTrackColor: const Color(0xFF80DEEA),
                          onChanged: (val) {
                            setState(() {
                              _isWholesaleMode = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildHeroFlashDealsCarousel(context, isDark),
          ),

          SliverToBoxAdapter(
            child: _buildCategoryBar(),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${filtered.length} টি তাজা মাছ পাওয়া গেছে',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.sort, size: 18),
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: deepOcean,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'popular', child: Text('জনপ্রিয়')),
                      DropdownMenuItem(value: 'price_low', child: Text('মূল্য: কম থেকে বেশি')),
                      DropdownMenuItem(value: 'price_high', child: Text('মূল্য: বেশি থেকে কম')),
                      DropdownMenuItem(value: 'rating', child: Text('রেটিং অনুসারে')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _sortBy = val);
                    },
                  ),
                ],
              ),
            ),
          ),

          filtered.isEmpty
              ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptySearchState(),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.58,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildProMaxFishCard(context, filtered[index], isDark);
                      },
                      childCount: filtered.length,
                    ),
                  ),
                ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const CreateFishAuctionScreen()),
        backgroundColor: const Color(0xFF004D40),
        elevation: 6,
        icon: const Icon(Icons.gavel, color: Colors.white, size: 18),
        label: Text(
          'লাইভ মাছের নিলাম',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroFlashDealsCarousel(BuildContext context, bool isDark) {
    return Container(
      height: 195,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Stack(
        children: [
          PageView.builder(
            controller: _bannerPageController,
            itemCount: _heroFlashDeals.length,
            onPageChanged: (idx) => setState(() => _currentBannerIndex = idx),
            itemBuilder: (context, index) {
              final deal = _heroFlashDeals[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: deal['image'] as String,
                        width: double.infinity,
                        height: 195,
                        fit: BoxFit.cover,
                        errorWidget: (c, u, e) => Container(color: const Color(0xFF004D40)),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.85),
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on, color: Colors.white, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'আজকের ভোরবেলার ফ্রেশ ক্যাচ',
                                style: GoogleFonts.hindSiliguri(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            'শেষ হতে: ${_formatDuration(_flashDuration)}',
                            style: GoogleFonts.poppins(
                              color: Colors.amberAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 14,
                        left: 14,
                        right: 14,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    deal['title'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.hindSiliguri(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${deal['tag']} • ${deal['stock']}',
                                    maxLines: 1,
                                    style: GoogleFonts.hindSiliguri(
                                      color: const Color(0xFF80DEEA),
                                      fontSize: 11.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        '৳ ${deal['price']}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '/কেজি',
                                        style: GoogleFonts.hindSiliguri(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.greenAccent.withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'পাইকারি ৳${deal['wholesalePrice']}',
                                          style: GoogleFonts.hindSiliguri(
                                            color: Colors.greenAccent,
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final product = _allFishProducts.firstWhere(
                                  (p) => p['title'] == deal['title'] || p['id'] == 'FP001',
                                );
                                _showFishDetailModal(context, product, isDark);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF006064),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              child: Text('অর্ডার করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}';
  }

  Widget _buildCategoryBar() {
    return Container(
      height: 52,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['label'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              avatar: Icon(
                cat['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF006064),
              ),
              label: Text(
                '${cat['label']} (${cat['count']})',
                style: GoogleFonts.hindSiliguri(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF006064),
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF006064) : Colors.grey.shade300,
                ),
              ),
              onSelected: (val) {
                setState(() {
                  _selectedCategory = cat['label'] as String;
                });
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProMaxFishCard(BuildContext context, Map<String, dynamic> product, bool isDark) {
    final bool isLive = product['isLive'] == true;
    final int price = _isWholesaleMode ? (product['wholesalePrice'] as int? ?? product['price'] as int) : product['price'] as int;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16252F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isLive ? Colors.cyan.withValues(alpha: 0.4) : Colors.grey.shade200.withValues(alpha: 0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _showFishDetailModal(context, product, isDark),
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: CachedNetworkImage(
                      imageUrl: product['imageUrl'] as String,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => Container(height: 120, color: Colors.grey.shade200),
                      errorWidget: (c, u, e) => Container(height: 120, color: const Color(0xFF004D40)),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isLive ? Colors.teal.shade800.withValues(alpha: 0.9) : const Color(0xFF0288D1).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(isLive ? Icons.pool : Icons.waves, color: Colors.white, size: 11),
                          const SizedBox(width: 3),
                          Text(
                            isLive ? 'জীবন্ত মাছ' : 'টাটকা রিভার ক্যাচ',
                            style: GoogleFonts.hindSiliguri(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 11),
                          const SizedBox(width: 2),
                          Text(
                            '${product['rating']}',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['title'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 11, color: Colors.grey),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            product['location'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'মজুত: ${product['stock']}',
                      style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.teal.shade800, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '৳ $price',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF006064),
                          ),
                        ),
                        Text(
                          ' /${product['unit']}',
                          style: GoogleFonts.hindSiliguri(fontSize: 10.5, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    if (_isWholesaleMode)
                      Text(
                        'নূন্যতম ${product['minWholesaleKg'] ?? 20} কেজি লট',
                        style: GoogleFonts.hindSiliguri(fontSize: 9.5, color: Colors.deepOrange, fontWeight: FontWeight.bold),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showFishDetailModal(context, product, isDark),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006064),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 1,
                            ),
                            child: Text(
                              'অর্ডার / কিনুন',
                              style: GoogleFonts.hindSiliguri(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            _addToCart(
                              product['title'] as String,
                              price.toString(),
                              product['seller'] as String,
                              product['location'] as String,
                              product['imageUrl'] as String,
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF006064).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add_shopping_cart, size: 16, color: Color(0xFF006064)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFishDetailModal(BuildContext context, Map<String, dynamic> product, bool isDark) {
    double selectedKg = 1.0;
    String selectedCutting = 'আস্ত মাছ (Whole Round)';
    String selectedDelivery = '🧊 বরফ ঢাকা থার্মোকল বক্স';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          final int unitPrice = _isWholesaleMode ? (product['wholesalePrice'] as int? ?? product['price'] as int) : product['price'] as int;
          final double totalPrice = unitPrice * selectedKg;

          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CachedNetworkImage(
                      imageUrl: product['imageUrl'] as String,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['title'] as String,
                          style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006064).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '৳ $unitPrice /${product['unit']}',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF006064)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.teal, size: 15),
                      const SizedBox(width: 4),
                      Text(
                        product['puritySeal'] as String? ?? '১০০% ফরমালিন মুক্ত',
                        style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.teal.shade800, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        product['harvestTime'] as String? ?? 'আজ ভোর ৫:০০ AM',
                        style: GoogleFonts.hindSiliguri(fontSize: 11.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    product['description'] as String,
                    style: GoogleFonts.hindSiliguri(fontSize: 12.5, color: Colors.grey.shade700, height: 1.35),
                  ),
                  const SizedBox(height: 16),
                  Text('পরিমাণ নির্বাচন করুন:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (selectedKg > 1) {
                            setModalState(() => selectedKg -= 1);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF006064)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          '${selectedKg.toStringAsFixed(0)} ${product['unit']}',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setModalState(() => selectedKg += 1);
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF006064)),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('মোট মূল্য:', style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600)),
                          Text(
                            '৳ ${totalPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF006064)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('কাটিং ও প্রসেসিং নির্বাচন:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      'আস্ত মাছ (Whole Round)',
                      'আঁশমুক্ত পেটি-গাদা টুকরো',
                      'রেডি ফিলেট (Boneless)',
                    ].map((cut) {
                      final isSelected = selectedCutting == cut;
                      return ChoiceChip(
                        label: Text(cut, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF006064),
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                        onSelected: (val) => setModalState(() => selectedCutting = cut),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  Text('ডেলিভারি মেথড:', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      '🧊 বরফ ঢাকা থার্মোকল বক্স',
                      '🚐 অক্সিজেন লাইভ ট্যাংক ভ্যান',
                      '⚡ ৩ ঘন্টায় সুপার এক্সপ্রেস',
                    ].map((del) {
                      final isSelected = selectedDelivery == del;
                      return ChoiceChip(
                        label: Text(del, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF0288D1),
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                        onSelected: (val) => setModalState(() => selectedDelivery = del),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF16252F) : const Color(0xFFF4F9FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.teal.shade200.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF006064).withValues(alpha: 0.15),
                          child: const Icon(Icons.person, color: Color(0xFF006064)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['seller'] as String,
                                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                '${product['location']} • ভেরিফায়েড আড়তদার',
                                style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          tooltip: 'সরাসরি কল করুন',
                          onPressed: () => _makePhoneCall(product['phone'] as String? ?? '01700000000'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF006064)),
                          tooltip: 'হোয়াটসঅ্যাপ / চ্যাট',
                          onPressed: () => _openWhatsApp(product['phone'] as String? ?? '01700000000'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.back();
                            _addToCart(
                              product['title'] as String,
                              unitPrice.toString(),
                              product['seller'] as String,
                              product['location'] as String,
                              product['imageUrl'] as String,
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 18, color: Color(0xFF006064)),
                          label: Text('কার্টে যোগ করুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: const Color(0xFF006064))),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF006064), width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Get.back();
                            _handleDirectPurchase(
                              product['title'] as String,
                              totalPrice,
                              product['seller'] as String,
                              product['imageUrl'] as String,
                            );
                          },
                          icon: const Icon(Icons.flash_on, color: Colors.white, size: 18),
                          label: Text('সরাসরি কিনুন', style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006064),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
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
      '$title আপনার শপিং কার্টে যুক্ত হয়েছে।',
      backgroundColor: const Color(0xFF006064),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () => Get.to(() => const ShoppingCartScreen()),
        child: Text(
          'কার্ট দেখুন',
          style: GoogleFonts.hindSiliguri(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _handleDirectPurchase(String title, double price, String seller, String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        'লগইন প্রয়োজন',
        'মাছ কিনতে দয়া করে আপনার অ্যাকাউন্টে লগইন করুন',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    final success = await SSLCommerzService.initiatePayment(
      context: context,
      amount: price,
      productName: title,
      customerName: user.displayName ?? 'Fish Buyer',
      customerEmail: user.email ?? 'buyer@example.com',
      customerPhone: '01700000000',
      customerAddress: 'Dhaka, Bangladesh',
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
        transportStatus: 'মাছ প্যাকেজিং ও কোল্ড ভ্যানে লোড হচ্ছে',
        paymentStatus: 'Paid via SSLCommerz / AgroLink Escrow',
        createdAt: DateTime.now(),
      );

      final orderService = OrderService();
      await orderService.createOrder(newOrder);
      Get.to(() => const FishBuyerOrdersScreen());
    }
  }

  Widget _buildEmptySearchState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 70, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text('কোনো মাছের সন্ধান পাওয়া যায়নি', style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('অন্য কোনো নাম বা ক্যাটাগরি দিয়ে চেষ্টা করুন', style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
