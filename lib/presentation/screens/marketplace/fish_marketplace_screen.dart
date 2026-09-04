import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agrolinkbd/core/providers/language_provider.dart';
import 'package:agrolinkbd/core/providers/cart_provider.dart';
import 'package:agrolinkbd/core/models/cart_model.dart';
import 'package:agrolinkbd/presentation/screens/buyer/shopping_cart_screen.dart';
import 'package:agrolinkbd/core/models/order_model.dart';
import 'package:agrolinkbd/core/services/order_service.dart';
import 'package:agrolinkbd/core/services/sslcommerz_service.dart';
import 'package:agrolinkbd/presentation/screens/buyer/fish_buyer_orders_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/buyer/fish_buyer_live_auction_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/buyer/fish_buyer_pond_analysis_screen.dart';
import 'package:agrolinkbd/presentation/screens/fisheries/premium/fish_buyer_qc_inspection_screen.dart';

class FishMarketplaceScreen extends StatefulWidget {
  final bool showAppBar;
  const FishMarketplaceScreen({super.key, this.showAppBar = true});

  @override
  State<FishMarketplaceScreen> createState() => _FishMarketplaceScreenState();
}

class _FishMarketplaceScreenState extends State<FishMarketplaceScreen> with SingleTickerProviderStateMixin {
  String _selectedCategoryKey = 'all';
  String _sortBy = 'popular';
  String _searchQuery = '';
  bool _isWholesaleMode = false;
  int _currentBannerIndex = 0;
  late PageController _bannerPageController;
  Timer? _bannerTimer;

  final List<Map<String, dynamic>> _categories = [
    {'key': 'all', 'labelBn': 'সব মাছ', 'labelEn': 'All Fish', 'icon': Icons.set_meal, 'count': '২২+'},
    {'key': 'river', 'labelBn': 'পদ্মার ইলিশ ও নদীর মাছ', 'labelEn': 'Padma Hilsa & River Fish', 'icon': Icons.waves, 'count': '৮'},
    {'key': 'live', 'labelBn': 'জীবন্ত অক্সিজেন ট্যাংক', 'labelEn': 'Live Oxygen Tank', 'icon': Icons.pool, 'count': '৬'},
    {'key': 'shrimp_crab', 'labelBn': 'গলদা ও বাগদা চিংড়ি', 'labelEn': 'Prawn & Shrimp', 'icon': Icons.phishing, 'count': '৫'},
    {'key': 'wholesale', 'labelBn': 'পাইকারি বড় লট (৫০+ কেজি)', 'labelEn': 'Wholesale Lot (50+ kg)', 'icon': Icons.inventory_2, 'count': '১০'},
    {'key': 'marine', 'labelBn': 'সামুদ্রিক ও রূপচাঁদা', 'labelEn': 'Marine & Pomfret', 'icon': Icons.sailing, 'count': '৭'},
    {'key': 'dry', 'labelBn': 'মহেশখালী অর্গানিক শুটকি', 'labelEn': 'Organic Dry Fish', 'icon': Icons.wb_sunny, 'count': '৪'},
    {'key': 'fingerling', 'labelBn': 'হ্যাচারি পোনা ও রেণু', 'labelEn': 'Hatchery Fry & Fingerlings', 'icon': Icons.opacity, 'count': '৩'},
  ];

  final List<Map<String, dynamic>> _heroFlashDeals = [
    {
      'id': 'FLASH_1',
      'title': 'চাঁদপুর মোহনার পদ্মার তাজা রূপালী ইলিশ',
      'titleEn': 'Chandpur Mohona Fresh Silver Hilsa',
      'weight': '১.৩ - ১.৬ কেজি/পিস',
      'weightEn': '1.3 - 1.6 kg/pc',
      'price': 1450,
      'wholesalePrice': 1350,
      'discount': '১৫% ছাড়',
      'discountEn': '15% OFF',
      'tag': 'ভোর ৪:৩০ এ চাঁদপুর মোহনা থেকে আহরিত',
      'tagEn': 'Harvested 4:30 AM from Chandpur Estuary',
      'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788504670/images_qbleou.jpg',
      'location': 'চাঁদপুর ফিশারি ঘাট',
      'locationEn': 'Chandpur Fishery Ghat',
      'seller': 'চাঁদপুর মোহনা ইলিশ ফোরাম',
      'sellerEn': 'Chandpur Mohona Hilsa Forum',
      'stock': '৪৫০ কেজি লট',
      'stockEn': '450 kg Lot',
      'verified': true,
      'phone': '01711002233',
    },
    {
      'id': 'FLASH_2',
      'title': 'সাতক্ষীরার রপ্তানি গ্রেড জম্বো বাগদা চিংড়ি',
      'titleEn': 'Satkhira Export Grade Jumbo Black Tiger Shrimp',
      'weight': '২০-২৫ পিস/কেজি (জম্বো)',
      'weightEn': '20-25 pcs/kg (Jumbo)',
      'price': 950,
      'wholesalePrice': 880,
      'discount': '১০% ছাড়',
      'discountEn': '10% OFF',
      'tag': 'ঘের থেকে সরাসরি জীবন্ত সংগ্রহ',
      'tagEn': 'Collected live directly from farm gher',
      'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505088/images_yhiizh.jpg',
      'location': 'শ্যামনগর, সাতক্ষীরা',
      'locationEn': 'Shyamnagar, Satkhira',
      'seller': 'সাতক্ষীরা সী-ফুড এক্সপোর্ট',
      'sellerEn': 'Satkhira Seafood Export',
      'stock': '২০০ কেজি লট',
      'stockEn': '200 kg Lot',
      'verified': true,
      'phone': '01711445566',
    },
    {
      'id': 'FLASH_3',
      'title': 'হালদা নদীর তেলযুক্ত তাজা বড় কাতলা মাছ',
      'titleEn': 'Halda River Fresh Sweet Katla Fish',
      'weight': '৪ - ৫.৫ কেজি সাইজ',
      'weightEn': '4 - 5.5 kg Size',
      'price': 440,
      'wholesalePrice': 390,
      'discount': 'পাইকারি বিশেষ লট',
      'discountEn': 'Wholesale Special Lot',
      'tag': 'প্রাকৃতিক হালদা নদীর খাঁটি স্বাদ',
      'tagEn': 'Authentic wild taste of Halda River',
      'image': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505305/images_l53fvw.jpg',
      'location': 'হালদা নদী, চট্টগ্রাম',
      'locationEn': 'Halda River, Chattogram',
      'seller': 'চট্টগ্রাম রিভার ক্যাচ এন্টারপ্রাইজ',
      'sellerEn': 'Chattogram River Catch Enterprise',
      'stock': '৬০০ কেজি লট',
      'stockEn': '600 kg Lot',
      'verified': true,
      'phone': '01811889900',
    },
  ];

  final List<Map<String, dynamic>> _allFishProducts = [
    {
      'id': 'FP001',
      'title': 'পদ্মার তাজা ইলিশ (১.২ - ১.৫ কেজি)',
      'titleEn': 'Fresh Padma Hilsa (1.2 - 1.5 kg)',
      'categoryKey': 'river',
      'categoryKeys': ['river', 'wholesale'],
      'price': 1450,
      'wholesalePrice': 1350,
      'minWholesaleKg': 30,
      'unit': 'কেজি',
      'unitEn': 'kg',
      'seller': 'চাঁদপুর মোহনা ফিশার্স অ্যাসোসিয়েশন',
      'sellerEn': 'Chandpur Mohona Fishers Association',
      'location': 'চাঁদপুর ঘাট',
      'locationEn': 'Chandpur Ghat',
      'rating': 4.9,
      'reviews': 248,
      'stock': '৩২০ কেজি',
      'stockEn': '320 kg',
      'isLive': false,
      'isPremium': true,
      'harvestTime': 'আজ ভোর ৫:৩০ AM',
      'harvestTimeEn': 'Today 5:30 AM (Dawn Catch)',
      'puritySeal': '১০০% ফরমালিন মুক্ত সার্টিফাইড',
      'puritySealEn': '100% Formalin Free Certified',
      'deliveryMode': 'থার্মোকল বরফ বক্স / এক্সপ্রেস ভ্যান',
      'deliveryModeEn': 'Thermocol Ice Box / Express Van',
      'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505394/images_yr8obg.jpg',
      'description': 'চাঁদপুরের পদ্মা ও মেঘনা মিলনস্থল থেকে সরাসরি ভোরে ধরা খাঁটি চকচকে রূপালী ইলিশ। কোনো বরফের রাসায়নিক নেই, শতভাগ টাটকা ও ডিমযুক্ত স্বাদ।',
      'descriptionEn': 'Authentic gleaming silver Hilsa caught at dawn from the confluence of Padma and Meghna. Free from chemicals, 100% fresh with exquisite taste.',
      'phone': '01711002233',
    },
    {
      'id': 'FP002',
      'title': 'দেশি রুই মাছ (২.৫ - ৩.৫ কেজি)',
      'titleEn': 'Native Rui Fish (2.5 - 3.5 kg)',
      'categoryKey': 'river',
      'categoryKeys': ['river', 'live', 'wholesale'],
      'price': 380,
      'wholesalePrice': 330,
      'minWholesaleKg': 50,
      'unit': 'কেজি',
      'unitEn': 'kg',
      'seller': 'রাজশাহী চলনবিল অ্যাকোয়াকালচার',
      'sellerEn': 'Rajshahi Chalan Beel Aquaculture',
      'location': 'সিংড়া, নাটোর',
      'locationEn': 'Singra, Natore',
      'rating': 4.8,
      'reviews': 185,
      'stock': '৭৫০ কেজি',
      'stockEn': '750 kg',
      'isLive': true,
      'isPremium': true,
      'harvestTime': 'আজ সকাল ৬:১৫ AM',
      'harvestTimeEn': 'Today 6:15 AM',
      'puritySeal': 'প্রাকৃতিক প্রোটিন ফিডে চাষকৃত',
      'puritySealEn': 'Grown on Natural Protein Feed',
      'deliveryMode': 'অক্সিজেন লাইভ ভ্যান ডেলিভারি',
      'deliveryModeEn': 'Live Oxygen Van Delivery',
      'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505454/images_jzjue9.jpg',
      'description': 'চলনবিলের পরিষ্কার পানিতে প্রাকৃতিক খাদ্য দিয়ে বড় করা খাঁটি দেশি রুই মাছ। লাল টুকটুকে তাজা ফুলকা ও শক্ত আঁশযুক্ত মাংস।',
      'descriptionEn': 'Authentic native Rui reared in clean Chalan Beel waters with organic feed. Bright red fresh gills and firm textured flesh.',
      'phone': '01711223344',
    },
    {
      'id': 'FP003',
      'title': 'জীবন্ত বাগদা চিংড়ি (গ্রেড-১)',
      'titleEn': 'Live Black Tiger Shrimp (Grade-1)',
      'categoryKey': 'shrimp_crab',
      'categoryKeys': ['shrimp_crab', 'marine', 'live'],
      'price': 950,
      'wholesalePrice': 870,
      'minWholesaleKg': 20,
      'unit': 'কেজি',
      'unitEn': 'kg',
      'seller': 'সাতক্ষীরা ব্লু-অ্যাকোয়া লিমিটেড',
      'sellerEn': 'Satkhira Blue-Aqua Ltd',
      'location': 'শ্যামনগর, সাতক্ষীরা',
      'locationEn': 'Shyamnagar, Satkhira',
      'rating': 5.0,
      'reviews': 310,
      'stock': '১৮০ কেজি',
      'stockEn': '180 kg',
      'isLive': true,
      'isPremium': true,
      'harvestTime': 'আজ ভোর ৫:০০ AM',
      'harvestTimeEn': 'Today 5:00 AM (Live Pond)',
      'puritySeal': 'ইইউ এক্সপোর্ট কোয়ালিটি সার্টিফাইড',
      'puritySealEn': 'EU Export Quality Certified',
      'deliveryMode': 'অক্সিজেন স্যাচুরেটেড ওয়াটার প্যাক',
      'deliveryModeEn': 'Oxygen Saturated Water Pack',
      'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788509639/images_pofhet.jpg',
      'description': 'সাতক্ষীরার লোনা পানির প্রাকৃতিক ঘের থেকে সংগৃহীত সরাসরি আন্তর্জাতিক মানের গ্রেড-১ বাগদা চিংড়ি। দারুণ মিষ্টি স্বাদ ও খাস্তা টেক্সচার।',
      'descriptionEn': 'Premium Grade-1 Black Tiger Shrimp harvested directly from natural saline water ghers. Delicious sweet taste and crisp texture.',
      'phone': '01711556677',
    },
    {
      'id': 'FP004',
      'title': 'হালদা নদীর কাতলা মাছ (৪ কেজি+)',
      'titleEn': 'Halda River Katla Fish (4 kg+)',
      'categoryKey': 'river',
      'categoryKeys': ['river', 'wholesale'],
      'price': 420,
      'wholesalePrice': 380,
      'minWholesaleKg': 40,
      'unit': 'কেজি',
      'unitEn': 'kg',
      'seller': 'চট্টগ্রাম রিভার ফ্রেশ কো-অপারেটিভ',
      'sellerEn': 'Chattogram River Fresh Co-op',
      'location': 'হালদা ঘাট, রাউজান',
      'locationEn': 'Halda Ghat, Raozan',
      'rating': 4.9,
      'reviews': 142,
      'stock': '৫০০ কেজি',
      'stockEn': '500 kg',
      'isLive': false,
      'isPremium': true,
      'harvestTime': 'আজ ভোর ৪:৪৫ AM',
      'harvestTimeEn': 'Today 4:45 AM',
      'puritySeal': 'হালদা নদীর ঐতিহ্যবাহী প্রাকৃতিক মাছ',
      'puritySealEn': 'Natural Heritage Halda River Catch',
      'deliveryMode': 'থার্মোকল ক্র্যাশড আইস বক্স',
      'deliveryModeEn': 'Thermocol Crushed Ice Box',
      'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505305/images_l53fvw.jpg',
      'description': 'বিশ্বখ্যাত প্রাকৃতিক মৎস্য প্রজনন ক্ষেত্র হালদা নদীর সুবিশাল সুস্বাদু কাতলা মাছ। পেটিতে প্রচুর মিষ্টি চর্বি ও কোমল মাংস।',
      'descriptionEn': 'Prized large Katla fish from the world-famous natural spawning ground Halda River. Rich sweet belly fat and succulent meat.',
      'phone': '01811334455',
    },
    {
      'id': 'FP005',
      'title': 'জীবন্ত দেশি শিং মাছ (বায়োফ্লক)',
      'titleEn': 'Live Native Shing (Biofloc)',
      'categoryKey': 'live',
      'categoryKeys': ['live', 'river'],
      'price': 600,
      'wholesalePrice': 540,
      'minWholesaleKg': 15,
      'unit': 'কেজি',
      'unitEn': 'kg',
      'seller': 'ময়মনসিংহ প্রিমিয়ার বায়োফ্লক হাব',
      'sellerEn': 'Mymensingh Premier Biofloc Hub',
      'location': 'ত্রিশাল, ময়মনসিংহ',
      'locationEn': 'Trishal, Mymensingh',
      'rating': 4.9,
      'reviews': 178,
      'stock': '২২০ কেজি',
      'stockEn': '220 kg',
      'isLive': true,
      'isPremium': true,
      'harvestTime': 'লাইভ ট্যাংক থেকে সরাসরি হারভেস্ট',
      'harvestTimeEn': 'Harvested live from tank',
      'puritySeal': '১০০% জীবন্ত গ্যারান্টি • পুষ্টিগুণে সেরা',
      'puritySealEn': '100% Live Guaranteed • Rich in Iron',
      'deliveryMode': 'লাইভ অক্সিজেন ব্যাগ বা ট্যাংক ভ্যান',
      'deliveryModeEn': 'Live Oxygen Bag or Tank Van',
      'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505936/images_reb179.jpg',
      'description': 'রোগী, প্রসূতি মা ও শিশুদের জন্য পুষ্টিগুণে সেরা শতভাগ জীবন্ত দেশি শিং মাছ। সম্পূর্ণ ড্রাগ-মুক্ত ও প্রাকৃতিক পরিবেশে উৎপাদিত।',
      'descriptionEn': 'Nutrient-rich 100% live native Shing catfish, ideal for patients and convalescents. Raised antibiotic-free in biofloc tanks.',
      'phone': '01911998877',
    },
    {
      'id': 'FP006',
      'title': 'কক্সবাজারের রূপচাঁদা (সিলভার পমফ্রেট)',
      'titleEn': 'Cox\'s Bazar Silver Pomfret',
      'categoryKey': 'marine',
      'categoryKeys': ['marine', 'wholesale'],
      'price': 850,
      'wholesalePrice': 780,
      'minWholesaleKg': 25,
      'unit': 'কেজি',
      'unitEn': 'kg',
      'seller': 'কক্সবাজার ডিপ-সী ট্রলার ফোরাম',
      'sellerEn': 'Cox\'s Bazar Deep-Sea Trawler Forum',
      'location': 'ফিশারি ঘাট, কক্সবাজার',
      'locationEn': 'Fishery Ghat, Cox\'s Bazar',
      'rating': 4.9,
      'reviews': 215,
      'stock': '৩০০ কেজি',
      'stockEn': '300 kg',
      'isLive': false,
      'isPremium': true,
      'harvestTime': 'গভীর বঙ্গোপসাগরের ট্রলারের তাজা মাছ',
      'harvestTimeEn': 'Deep-sea trawler fresh catch',
      'puritySeal': 'রপ্তানি গ্রেড সিলভার রূপচাঁদা',
      'puritySealEn': 'Export Grade Silver Pomfret',
      'deliveryMode': 'চিলড কোল্ড চেইন ট্রান্সপোর্ট',
      'deliveryModeEn': 'Chilled Cold Chain Transport',
      'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505965/images_qp7kzf.jpg',
      'description': 'কক্সবাজারের গভীর সমুদ্রের আসল সিলভার রূপচাঁদা মাছ। ফাইভ স্টার রেস্তোরাঁ ও হোম ডাইনিংয়ের জন্য সর্বোচ্চ মানের ফ্রাই সাইজ।',
      'descriptionEn': 'Authentic Silver Pomfret from the deep waters of Bay of Bengal. Premium pan-fry size favored by five-star restaurants.',
      'phone': '01811667788',
    },
    {
      'id': 'FP007',
      'title': 'গলদা চিংড়ি (জম্বো সাইজ)',
      'titleEn': 'Giant Freshwater Prawn (Jumbo)',
      'categoryKey': 'shrimp_crab',
      'categoryKeys': ['shrimp_crab', 'river'],
      'price': 1100,
      'wholesalePrice': 990,
      'minWholesaleKg': 15,
      'unit': 'কেজি',
      'unitEn': 'kg',
      'seller': 'বাগেরহাট গলদা চাষী সমিতি',
      'sellerEn': 'Bagerhat Prawn Farmers Association',
      'location': 'বাগেরহাট',
      'locationEn': 'Bagerhat',
      'rating': 4.9,
      'reviews': 260,
      'stock': '১৪০ কেজি',
      'stockEn': '140 kg',
      'isLive': false,
      'isPremium': true,
      'harvestTime': 'আজ ভোর ৬:০০ AM',
      'harvestTimeEn': 'Today 6:00 AM',
      'puritySeal': 'মাথায় ভরপুর লাল ঘি গ্যারান্টি',
      'puritySealEn': 'Rich Red Head-Roe Guaranteed',
      'deliveryMode': 'আইসড থার্মোকল বক্স',
      'deliveryModeEn': 'Iced Thermocol Box',
      'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788506018/images_xj5y1u.jpg',
      'description': 'বাগেরহাটের মিষ্টি পানির সুবিশাল গলদা চিংড়ি। প্রতিটি চিংড়ির মাথায় রয়েছে সুস্বাদু লাল ঘি এবং মোটা মাংসল শরীর।',
      'descriptionEn': 'Luscious large freshwater prawns from Bagerhat. Packed with delicious roe in the head and juicy, tender tail meat.',
      'phone': '01711889911',
    },
    {
      'id': 'FP008',
      'title': 'সুন্দরবনের জীবন্ত কাঁকড়া (মাড ক্র্যাব)',
      'titleEn': 'Sundarbans Live Mud Crab',
      'categoryKey': 'shrimp_crab',
      'categoryKeys': ['shrimp_crab', 'marine', 'live'],
      'price': 720,
      'wholesalePrice': 650,
      'minWholesaleKg': 20,
      'unit': 'কেজি',
      'unitEn': 'kg',
      'seller': 'খুলনা সুন্দরবন সি-ফুড প্রসেসিং',
      'sellerEn': 'Khulna Sundarbans Sea-Food Processing',
      'location': 'রূপসা ঘাট, খুলনা',
      'locationEn': 'Rupsha Ghat, Khulna',
      'rating': 4.8,
      'reviews': 130,
      'stock': '১১০ কেজি',
      'stockEn': '110 kg',
      'isLive': true,
      'isPremium': true,
      'harvestTime': 'সুন্দরবন খাঁড়ি থেকে সরাসরি সংগৃহীত',
      'harvestTimeEn': 'Harvested directly from Sundarbans estuaries',
      'puritySeal': '১০০% জীবিত ও মাংসে টাইট কাঁকড়া',
      'puritySealEn': '100% Live & Meat-Packed Grade',
      'deliveryMode': 'স্পেশাল ব্রিদিং ব্যাম্বু ক্রাফট বক্স',
      'deliveryModeEn': 'Special Breathing Bamboo Craft Box',
      'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788506053/images_jm6zzy.jpg',
      'description': 'সুন্দরবনের প্রাকৃতিক লোনা খাঁড়ির বড় সাইজের জীবন্ত কাঁকড়া। প্রচুর নরম মাংস ও ঘিয়ে ভরপুর এক্সপোর্ট কোয়ালিটি।',
      'descriptionEn': 'Wild live mud crabs from the estuaries of Sundarbans. Dense sweet meat and rich roe, high-grade export standard.',
      'phone': '01711332211',
    },
    {
      'id': 'FP009',
      'title': 'সামুদ্রিক কোরাল / ভেঁটকি মাছ',
      'titleEn': 'Sea Bass / Koral Fish',
      'categoryKey': 'marine',
      'categoryKeys': ['marine', 'wholesale'],
      'price': 750,
      'wholesalePrice': 680,
      'minWholesaleKg': 30,
      'unit': 'কেজি',
      'unitEn': 'kg',
      'seller': 'কক্সবাজার সী-ফুড ট্রেডিং',
      'sellerEn': 'Cox\'s Bazar Seafood Trading',
      'location': 'টেকনাফ, কক্সবাজার',
      'locationEn': 'Teknaf, Cox\'s Bazar',
      'rating': 4.8,
      'reviews': 112,
      'stock': '১৯০ কেজি',
      'stockEn': '190 kg',
      'isLive': false,
      'isPremium': true,
      'harvestTime': 'আজ ভোর ৫:০০ AM',
      'harvestTimeEn': 'Today 5:00 AM',
      'puritySeal': 'বারবিকিউ ও ফিশ ফিলেটের জন্য সেরা',
      'puritySealEn': 'Best for Barbecue & Fillet',
      'deliveryMode': 'কোল্ড চেইন এক্সপ্রেস ভ্যান',
      'deliveryModeEn': 'Cold Chain Express Van',
      'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788506111/images_khkkib.jpg',
      'description': 'বঙ্গোপসাগরের গভীর জলসীমা থেকে সংগৃহীত প্রিমিয়াম সাইজের সাদা কোরাল বা ভেঁটকি মাছ। ফিশ ফ্রাই ও তন্দুরি বারবিকিউয়ের জন্য অতুলনীয়।',
      'descriptionEn': 'Premium wild Sea Bass from Bay of Bengal. Mild sweet flavor and flaky white fillets, ideal for grilling and pan-frying.',
      'phone': '01811443322',
    },
    {
      'id': 'FP010',
      'title': 'সেন্টমার্টিন অর্গানিক রূপচাঁদা শুটকি',
      'titleEn': 'Saint Martin Organic Dry Pomfret',
      'categoryKey': 'dry',
      'categoryKeys': ['dry', 'marine'],
      'price': 1250,
      'wholesalePrice': 1120,
      'minWholesaleKg': 10,
      'unit': 'কেজি',
      'unitEn': 'kg',
      'seller': 'সেন্টমার্টিন ড্রাইড ফিশ এন্টারপ্রাইজ',
      'sellerEn': 'Saint Martin Dried Fish Enterprise',
      'location': 'সেন্টমার্টিন দ্বীপ',
      'locationEn': 'Saint Martin Island',
      'rating': 5.0,
      'reviews': 165,
      'stock': '৮০ কেজি',
      'stockEn': '80 kg',
      'isLive': false,
      'isPremium': true,
      'harvestTime': 'প্রাকৃতিক সূর্যালোক ও বাতাসে শুকানো',
      'harvestTimeEn': 'Naturally sun & breeze dried',
      'puritySeal': '১০০% কীটনাশক ও বালুকামুক্ত অর্গানিক',
      'puritySealEn': '100% Pesticide & Sand-Free Organic',
      'deliveryMode': 'ভ্যাকুয়াম সিলড প্রিমিয়াম পাউচ',
      'deliveryModeEn': 'Vacuum Sealed Premium Pouch',
      'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788506186/images_cjgkzx.jpg',
      'description': 'সেন্টমার্টিন দ্বীপের আসল রূপচাঁদা মাছের স্বাস্থ্যসম্মত অর্গানিক শুটকি। কোনো কীটনাশক, বিষাক্ত লবণ বা ধুলাবালি স্পর্শ করেনি।',
      'descriptionEn': 'Traditional sun-dried Silver Pomfret from Saint Martin Island. Completely free of salt chemicals, sand, or preservatives.',
      'phone': '01811554433',
    },
    {
      'id': 'FP011',
      'title': 'উন্নত জাতের রুই-কাতলার পোনা (রেণু)',
      'titleEn': 'High-Yield Rui & Katla Fry / Fingerlings',
      'categoryKey': 'fingerling',
      'categoryKeys': ['fingerling', 'river'],
      'price': 1200,
      'wholesalePrice': 1050,
      'minWholesaleKg': 10,
      'unit': 'হাজার পিস',
      'unitEn': 'k pcs',
      'seller': 'যশোর সরকারি সার্টিফাইড হ্যাচারি',
      'sellerEn': 'Jashore Certified Hatchery Complex',
      'location': 'চাঁচড়া, যশোর',
      'locationEn': 'Chanchra, Jashore',
      'rating': 4.9,
      'reviews': 195,
      'stock': '৮০,০০০ পিস',
      'stockEn': '80,000 pcs',
      'isLive': true,
      'isPremium': true,
      'harvestTime': 'হ্যাচারি ট্যাংক থেকে লাইভ প্যাকেজিং',
      'harvestTimeEn': 'Live hatchery packaging',
      'puritySeal': '১০০% রোগমুক্ত এসপিএফ ব্রুড স্টক',
      'puritySealEn': '100% Disease-Free SPF Brood Stock',
      'deliveryMode': 'অক্সিজেন বেলুন ট্রিপল লেয়ার ব্যাগ',
      'deliveryModeEn': 'Triple-Layer Oxygen Balloon Bag',
      'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788509335/images_t4wq23.jpg',
      'description': 'উচ্চ বৃদ্ধি ও রোগ প্রতিরোধক্ষমতাসম্পন্ন অরিজিনাল রুই ও কাতলার গ্রেড-১ পোনা। সারা দেশে ৭২ ঘন্টার অক্সিজেন সহনশীল ব্যাগে পরিবহন।',
      'descriptionEn': 'Fast-growing, disease-resistant certified Grade-1 Rui and Katla fry. Dispatched nationwide with 72-hour oxygen guaranteed packing.',
      'phone': '01711667788',
    },
    {
      'id': 'FP012',
      'title': 'সুপার মনোসেক্স গিফট তেলাপিয়া',
      'titleEn': 'Super Monosex GIFT Tilapia',
      'categoryKey': 'wholesale',
      'categoryKeys': ['wholesale', 'live'],
      'price': 220,
      'wholesalePrice': 185,
      'minWholesaleKg': 100,
      'unit': 'কেজি',
      'unitEn': 'kg',
      'seller': 'বগুড়া মেগা অ্যাকোয়াকালচার জোন',
      'sellerEn': 'Bogura Mega Aquaculture Zone',
      'location': 'শেরপুর, বগুড়া',
      'locationEn': 'Sherpur, Bogura',
      'rating': 4.7,
      'reviews': 340,
      'stock': '২,৫০০ কেজি',
      'stockEn': '2,500 kg',
      'isLive': true,
      'isPremium': false,
      'harvestTime': 'প্রতিদিন তাজা পুকুর থেকে হারভেস্ট',
      'harvestTimeEn': 'Daily fresh pond harvest',
      'puritySeal': 'সুপারস্টোর ও পাইকারি আড়তদারদের জন্য প্রস্তুত',
      'puritySealEn': 'Ready for Supermarkets & Wholesale Markets',
      'deliveryMode': 'ট্যাঙ্কার ট্রাক বা বরফ ভ্যান',
      'deliveryModeEn': 'Live Tanker Truck or Iced Van',
      'imageUrl': 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788510151/images_vpbfpn.jpg',
      'description': 'প্রতিটি মাছ ৫০০-৭০০ গ্রাম ওজনের মনোসেক্স গিফট তেলাপিয়া। হোটেল, রেস্তোরাঁ ও সুপারশপের জন্য সরাসরি খামার রেটে বিশাল লট।',
      'descriptionEn': '500-700g graded Monosex GIFT Tilapia. Direct farm gate pricing for wholesale depots, restaurants, and retail supermarket chains.',
      'phone': '01711990011',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController();
    _startBannerAutoScroll();
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

  @override
  void dispose() {
    _bannerPageController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredProducts {
    var list = _allFishProducts.where((product) {
      final categoryKey = product['categoryKey'] as String? ?? '';
      final categoryKeys = product['categoryKeys'] as List<String>? ?? [];
      final matchesCategory = _selectedCategoryKey == 'all' ||
          categoryKey == _selectedCategoryKey ||
          categoryKeys.contains(_selectedCategoryKey);
      final query = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty ||
          (product['title'] as String? ?? '').toLowerCase().contains(query) ||
          (product['titleEn'] as String? ?? '').toLowerCase().contains(query) ||
          (product['seller'] as String? ?? '').toLowerCase().contains(query) ||
          (product['sellerEn'] as String? ?? '').toLowerCase().contains(query) ||
          (product['location'] as String? ?? '').toLowerCase().contains(query) ||
          (product['locationEn'] as String? ?? '').toLowerCase().contains(query);
      final matchesWholesale = !_isWholesaleMode || categoryKeys.contains('wholesale');
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
      final isBn = LanguageProvider.isBn(context);
      Get.snackbar(
        isBn ? 'কল করা যাচ্ছে না' : 'Cannot make call',
        '${isBn ? "নম্বর" : "Number"}: $phoneNumber',
        backgroundColor: Colors.red.shade100,
      );
    }
  }

  void _openWhatsApp(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final fullNumber = cleanNumber.startsWith('88') ? cleanNumber : '88$cleanNumber';
    final isBn = LanguageProvider.isBn(context);
    final msg = isBn
        ? 'আমি%20অ্যাগ্রোলিংক%20বিডি%20বিগ%20ফিশ%20মার্কেট%20থেকে%20মাছ%20ক্রয়/অর্ডার%20সম্পর্কে%20যোগাযোগ%20করছি।'
        : 'Hello,%20I%20am%20contacting%20you%20from%20AgroLinkBD%20Big%20Fish%20Market%20regarding%20fish%20order.';
    final Uri url = Uri.parse('https://wa.me/$fullNumber?text=$msg');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _makePhoneCall(phoneNumber);
    }
  }

  void _addToCart(String title, String priceStr, String seller, String location, String imageUrl, String unit, bool isBn) {
    final double price = double.tryParse(priceStr) ?? 0.0;
    final String id = 'fish_${title.hashCode}_${seller.hashCode}';
    final String nowIso = DateTime.now().toIso8601String();

    final item = CartItem(
      id: id,
      title: title,
      price: price,
      unit: unit,
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
      isBn ? 'কার্টে যোগ করা হয়েছে 🛒' : 'Added to Cart 🛒',
      isBn ? '$title আপনার শপিং কার্টে যুক্ত হয়েছে।' : '$title has been added to your shopping cart.',
      backgroundColor: const Color(0xFF004D40),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(12),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () => Get.to(() => const ShoppingCartScreen()),
        child: Text(
          isBn ? 'কার্ট দেখুন' : 'View Cart',
          style: GoogleFonts.hindSiliguri(color: Colors.amberAccent, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _handleDirectPurchase(String title, double price, String seller, String imageUrl, bool isBn) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.snackbar(
        isBn ? 'লগইন প্রয়োজন' : 'Login Required',
        isBn ? 'মাছ কিনতে দয়া করে আপনার অ্যাকাউন্টে লগইন করুন' : 'Please log in to your account to purchase fish',
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
        transportStatus: isBn ? 'মাছ প্যাকেজিং ও কোল্ড ভ্যানে লোড হচ্ছে' : 'Fish is being packaged and loaded into refrigerated van',
        paymentStatus: 'Paid via SSLCommerz / AgroLink Escrow',
        createdAt: DateTime.now(),
      );

      final orderService = OrderService();
      await orderService.createOrder(newOrder);
      Get.to(() => const FishBuyerOrdersScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isBn = LanguageProvider.isBn(context);
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
              expandedHeight: 165.0,
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
                      child: const Icon(Icons.storefront_rounded, color: Color(0xFF80DEEA), size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isBn ? 'বিগ ফিশ মার্কেট ও হোলসেল ট্রেড' : 'Big Fish Market & Wholesale Trade',
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
                              const Icon(Icons.analytics_rounded, color: Colors.greenAccent, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isBn
                                      ? 'লাইভ বাজারদর: ইলিশ ৳১৪৫০ | রুই ৳৩৮০ | কাতলা ৳৪২০ | চিংড়ি ৳৯৫০'
                                      : 'Live Rates: Hilsa ৳1450 | Rui ৳380 | Katla ৳420 | Prawn ৳950',
                                  style: GoogleFonts.hindSiliguri(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                  tooltip: isBn ? 'ল্যাব ও কোয়ালিটি সনদ' : 'Lab & Quality Certification',
                  onPressed: () => Get.to(() => const FishBuyerQcInspectionScreen()),
                ),
                Consumer<CartProvider>(
                  builder: (context, cart, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                          tooltip: isBn ? 'শপিং কার্ট' : 'Shopping Cart',
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
                        hintText: isBn ? 'মাছের প্রজাতি, নদীর তাজা মাছ বা আড়ত খুঁজুন...' : 'Search fish species, river catches or wholesalers...',
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
                          Icons.warehouse_rounded,
                          color: _isWholesaleMode ? Colors.white : tealAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isWholesaleMode
                                    ? (isBn ? 'পাইকারি আড়ত মোড সক্রিয় (৫০+ কেজি লট)' : 'Wholesale Lot Mode Active (50+ kg)')
                                    : (isBn ? 'খুচরা ও সরাসরি ক্রয় মোড' : 'Retail & Consumer Buying Mode'),
                                style: GoogleFonts.hindSiliguri(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: _isWholesaleMode ? Colors.white : Colors.teal.shade900,
                                ),
                              ),
                              Text(
                                _isWholesaleMode
                                    ? (isBn ? 'আড়তদার ও পাইকারদের জন্য বিশেষ রেট' : 'Exclusive bulk rates for wholesale buyers')
                                    : (isBn ? 'পাইকারি মূল্যে লট কিনতে মোড অন করুন' : 'Enable mode to buy in bulk wholesale lots'),
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
                  const SizedBox(height: 10),

                  // Wholesale Buyer Pond Analysis Hub Quick Banner
                  InkWell(
                    onTap: () => Get.to(() => const FishBuyerPondAnalysisScreen()),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00363A), Color(0xFF006064)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF004D40).withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFF80DEEA).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.analytics_rounded, color: Colors.black87, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isBn ? 'পুকুর ও ঘের অ্যানালাইসিস হাব' : 'Pond & Farm Analysis Hub',
                                      style: GoogleFonts.hindSiliguri(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: Colors.amberAccent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isBn ? 'প্রো অডিট' : 'PRO AUDIT',
                                        style: GoogleFonts.poppins(color: Colors.black87, fontSize: 8.5, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  isBn
                                      ? 'হারভেস্টের আগে বায়োমাস, পানির গুণমান ও ল্যান্ডিং লাভ যাচাই করুন'
                                      : 'Audit pre-harvest standing biomass, water purity & net wholesale ROI',
                                  style: GoogleFonts.hindSiliguri(
                                    fontSize: 11,
                                    color: const Color(0xFF80DEEA),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: _buildHeroFlashDealsCarousel(context, isDark, isBn),
          ),

          SliverToBoxAdapter(
            child: _buildCategoryBar(isBn),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn
                        ? '${filtered.length} টি তাজা মাছ পাওয়া গেছে'
                        : '${filtered.length} Fresh Fish Available',
                    style: GoogleFonts.hindSiliguri(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.grey.shade700,
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
                    items: [
                      DropdownMenuItem(value: 'popular', child: Text(isBn ? 'জনপ্রিয়' : 'Most Popular')),
                      DropdownMenuItem(value: 'price_low', child: Text(isBn ? 'মূল্য: কম থেকে বেশি' : 'Price: Low to High')),
                      DropdownMenuItem(value: 'price_high', child: Text(isBn ? 'মূল্য: বেশি থেকে কম' : 'Price: High to Low')),
                      DropdownMenuItem(value: 'rating', child: Text(isBn ? 'রেটিং অনুসারে' : 'Top Rated')),
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
                  child: _buildEmptySearchState(isBn),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.65, // Balanced square aesthetic with 1:1 image & action buttons
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildSquareFishCard(context, filtered[index], isDark, isBn);
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
        onPressed: () => Get.to(() => const FishBuyerLiveAuctionScreen()),
        backgroundColor: const Color(0xFF004D40),
        elevation: 6,
        icon: const Icon(Icons.gavel, color: Colors.white, size: 18),
        label: Text(
          isBn ? 'লাইভ মাছের নিলাম' : 'Live Fish Auction',
          style: GoogleFonts.hindSiliguri(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroFlashDealsCarousel(BuildContext context, bool isDark, bool isBn) {
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
              final title = isBn ? (deal['title'] as String) : (deal['titleEn'] as String? ?? deal['title'] as String);
              final tag = isBn ? (deal['tag'] as String) : (deal['tagEn'] as String? ?? deal['tag'] as String);
              final stock = isBn ? (deal['stock'] as String) : (deal['stockEn'] as String? ?? deal['stock'] as String);

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
                                isBn ? 'আজকের ভোরবেলার ফ্রেশ ক্যাচ' : "Today's Dawn Catch",
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
                        bottom: 14,
                        left: 14,
                        right: 14,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.hindSiliguri(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$tag • $stock',
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
                                        isBn ? '/কেজি' : '/kg',
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
                                          isBn ? 'পাইকারি ৳${deal['wholesalePrice']}' : 'Wholesale ৳${deal['wholesalePrice']}',
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
                            ElevatedButton.icon(
                              onPressed: () {
                                final product = _allFishProducts.firstWhere(
                                  (p) => p['title'] == deal['title'] || p['id'] == 'FP001',
                                );
                                _showFishDetailModal(context, product, isDark, isBn);
                              },
                              icon: const Icon(Icons.shopping_bag_rounded, size: 16, color: Colors.white),
                              label: Text(
                                isBn ? 'অর্ডার করুন' : 'Order Now',
                                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF004D40),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              ),
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

  Widget _buildCategoryBar(bool isBn) {
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
          final isSelected = _selectedCategoryKey == cat['key'];
          final label = isBn
              ? (cat['labelBn'] as String? ?? cat['label'] as String? ?? '')
              : (cat['labelEn'] as String? ?? cat['labelBn'] as String? ?? '');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              avatar: Icon(
                cat['icon'] as IconData,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF006064),
              ),
              label: Text(
                '$label (${cat['count']})',
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
                  _selectedCategoryKey = cat['key'] as String;
                });
              },
            ),
          );
        },
      ),
    );
  }

  /// Square-Shaped Product Card with Order Now & Add to Cart actions for buyers
  Widget _buildSquareFishCard(
    BuildContext context,
    Map<String, dynamic> product,
    bool isDark,
    bool isBn,
  ) {
    final bool isLive = product['isLive'] == true;
    final int price = _isWholesaleMode ? (product['wholesalePrice'] as int? ?? product['price'] as int) : product['price'] as int;
    final String title = isBn ? (product['title'] as String? ?? '') : (product['titleEn'] as String? ?? product['title'] as String? ?? '');
    final String location = isBn ? (product['location'] as String? ?? '') : (product['locationEn'] as String? ?? product['location'] as String? ?? '');
    final String stock = isBn ? (product['stock'] as String? ?? '') : (product['stockEn'] as String? ?? product['stock'] as String? ?? '');
    final String unit = isBn ? (product['unit'] as String? ?? 'কেজি') : (product['unitEn'] as String? ?? 'kg');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16252F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isLive ? Colors.teal.shade300.withValues(alpha: 0.4) : Colors.grey.shade200.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _showFishDetailModal(context, product, isDark, isBn),
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1:1 Square Aspect Ratio Header Image
              AspectRatio(
                aspectRatio: 1.15,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                      child: CachedNetworkImage(
                        imageUrl: product['imageUrl'] as String,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (c, u) => Container(color: Colors.grey.shade200),
                        errorWidget: (c, u, e) => Container(color: const Color(0xFF004D40)),
                      ),
                    ),
                    // Live / Fresh Badge
                    Positioned(
                      top: 7,
                      left: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: isLive ? const Color(0xFF004D40).withValues(alpha: 0.9) : const Color(0xFF0277BD).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(isLive ? Icons.pool : Icons.waves, color: Colors.white, size: 10),
                            const SizedBox(width: 3),
                            Text(
                              isLive
                                  ? (isBn ? 'জীবন্ত' : 'Live')
                                  : (isBn ? 'নদীর তাজা' : 'Fresh River'),
                              style: GoogleFonts.hindSiliguri(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Rating Badge
                    Positioned(
                      top: 7,
                      right: 7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 10),
                            const SizedBox(width: 2),
                            Text(
                              '${product['rating']}',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Product Info & Price
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 6, 9, 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.hindSiliguri(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded, size: 11, color: Colors.teal.shade700),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '$location • $stock',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.hindSiliguri(fontSize: 9.5, color: Colors.grey.shade600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '৳ $price',
                          style: GoogleFonts.poppins(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF00695C),
                          ),
                        ),
                        Text(
                          ' /$unit',
                          style: GoogleFonts.hindSiliguri(fontSize: 10, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Order Now & Add to Cart Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(9, 0, 9, 8),
                child: Row(
                  children: [
                    // Buyer Order Button
                    Expanded(
                      child: SizedBox(
                        height: 32,
                        child: ElevatedButton.icon(
                          onPressed: () => _showFishDetailModal(context, product, isDark, isBn),
                          icon: const Icon(Icons.shopping_bag_outlined, size: 14, color: Colors.white),
                          label: Text(
                            isBn ? 'অর্ডার করুন' : 'Order Now',
                            style: GoogleFonts.hindSiliguri(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004D40),
                            padding: EdgeInsets.zero,
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),

                    // Quick Add to Cart Button
                    InkWell(
                      onTap: () {
                        _addToCart(
                          title,
                          price.toString(),
                          isBn ? (product['seller'] as String? ?? '') : (product['sellerEn'] as String? ?? product['seller'] as String? ?? ''),
                          location,
                          product['imageUrl'] as String,
                          unit,
                          isBn,
                        );
                      },
                      borderRadius: BorderRadius.circular(9),
                      child: Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFF004D40).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(color: const Color(0xFF004D40).withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.add_shopping_cart_rounded, size: 16, color: Color(0xFF004D40)),
                      ),
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

  /// Detail Modal: Full interactive purchasing with quantity selection, customization, and SSLCommerz payment
  void _showFishDetailModal(BuildContext context, Map<String, dynamic> product, bool isDark, bool isBn) {
    double selectedKg = 1.0;
    String selectedCutting = isBn ? 'আস্ত মাছ (Whole Round)' : 'Whole Round Fish';
    String selectedDelivery = isBn ? '🧊 বরফ ঢাকা থার্মোকল বক্স' : '🧊 Ice-Packed Insulated Box';

    final String title = isBn ? (product['title'] as String? ?? '') : (product['titleEn'] as String? ?? product['title'] as String? ?? '');
    final String seller = isBn ? (product['seller'] as String? ?? '') : (product['sellerEn'] as String? ?? product['seller'] as String? ?? '');
    final String location = isBn ? (product['location'] as String? ?? '') : (product['locationEn'] as String? ?? product['location'] as String? ?? '');
    final String unit = isBn ? (product['unit'] as String? ?? 'কেজি') : (product['unitEn'] as String? ?? 'kg');
    final String puritySeal = isBn
        ? (product['puritySeal'] as String? ?? '১০০% ফরমালিন মুক্ত')
        : (product['puritySealEn'] as String? ?? '100% Formalin-Free');
    final String harvestTime = isBn
        ? (product['harvestTime'] as String? ?? 'আজ ভোর ৫:০০ AM')
        : (product['harvestTimeEn'] as String? ?? 'Harvested Today 5:00 AM');
    final String description = isBn
        ? (product['description'] as String? ?? '')
        : (product['descriptionEn'] as String? ?? product['description'] as String? ?? '');

    final cuttingOptions = isBn
        ? ['আস্ত মাছ (Whole Round)', 'আঁশমুক্ত পেটি-গাদা টুকরো', 'রেডি ফিলেট (Boneless)']
        : ['Whole Round Fish', 'Scaled & Curry Cut', 'Ready Fillet (Boneless)'];

    final deliveryOptions = isBn
        ? ['🧊 বরফ ঢাকা থার্মোকল বক্স', '🚐 অক্সিজেন লাইভ ট্যাংক ভ্যান', '⚡ ৩ ঘন্টায় সুপার এক্সপ্রেস']
        : ['🧊 Ice-Packed Insulated Box', '🚐 Live Oxygen Tank Van', '⚡ 3-Hour Super Express'];

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
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.hindSiliguri(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004D40).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '৳ $unitPrice /$unit',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF004D40)),
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
                        puritySeal,
                        style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.teal.shade800, fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      const Icon(Icons.access_time, color: Colors.grey, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        harvestTime,
                        style: GoogleFonts.hindSiliguri(fontSize: 11.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: GoogleFonts.hindSiliguri(fontSize: 12.5, color: Colors.grey.shade700, height: 1.35),
                  ),
                  const SizedBox(height: 16),

                  // Quantity Selector for Buyer
                  Text(
                    isBn ? 'পরিমাণ নির্বাচন করুন:' : 'Select Quantity:',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (selectedKg > 1) {
                            setModalState(() => selectedKg -= 1);
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF004D40)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          '${selectedKg.toStringAsFixed(0)} $unit',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setModalState(() => selectedKg += 1);
                        },
                        icon: const Icon(Icons.add_circle_outline, color: Color(0xFF004D40)),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            isBn ? 'মোট মূল্য:' : 'Total Price:',
                            style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          Text(
                            '৳ ${totalPrice.toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF004D40)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Cutting Options
                  Text(
                    isBn ? 'কাটিং ও প্রসেসিং নির্বাচন:' : 'Cutting & Processing Option:',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: cuttingOptions.map((cut) {
                      final isSelected = selectedCutting == cut;
                      return ChoiceChip(
                        label: Text(cut, style: GoogleFonts.hindSiliguri(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF004D40),
                        labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                        onSelected: (val) => setModalState(() => selectedCutting = cut),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Delivery Options
                  Text(
                    isBn ? 'ডেলিভারি মেথড:' : 'Delivery Method:',
                    style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: deliveryOptions.map((del) {
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
                  const SizedBox(height: 16),

                  // Wholesaler Contact Info
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
                          backgroundColor: const Color(0xFF004D40).withValues(alpha: 0.15),
                          child: const Icon(Icons.store_rounded, color: Color(0xFF004D40)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                seller,
                                style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                '$location • ${isBn ? "অনুমোদিত আড়তদার" : "Verified Wholesaler"}',
                                style: GoogleFonts.hindSiliguri(fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.call, color: Colors.green),
                          tooltip: isBn ? 'আড়তে কল করুন' : 'Call Depot',
                          onPressed: () => _makePhoneCall(product['phone'] as String? ?? '01700000000'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF004D40)),
                          tooltip: isBn ? 'হোয়াটসঅ্যাপে যোগাযোগ' : 'WhatsApp Chat',
                          onPressed: () => _openWhatsApp(product['phone'] as String? ?? '01700000000'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Buyer Action Buttons: Add to Cart & Buy Now with SSLCommerz
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.back();
                            _addToCart(
                              title,
                              unitPrice.toString(),
                              seller,
                              location,
                              product['imageUrl'] as String,
                              unit,
                              isBn,
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart, size: 18, color: Color(0xFF004D40)),
                          label: Text(
                            isBn ? 'কার্টে যোগ করুন' : 'Add to Cart',
                            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: const Color(0xFF004D40)),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF004D40), width: 1.5),
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
                              title,
                              totalPrice,
                              seller,
                              product['imageUrl'] as String,
                              isBn,
                            );
                          },
                          icon: const Icon(Icons.flash_on, color: Colors.white, size: 18),
                          label: Text(
                            isBn ? 'সরাসরি কিনুন' : 'Buy Now',
                            style: GoogleFonts.hindSiliguri(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF004D40),
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

  Widget _buildEmptySearchState(bool isBn) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 70, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            isBn ? 'কোনো মাছের সন্ধান পাওয়া যায়নি' : 'No fish found',
            style: GoogleFonts.hindSiliguri(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            isBn ? 'অন্য কোনো নাম বা ক্যাটাগরি দিয়ে চেষ্টা করুন' : 'Try searching with a different name or category',
            style: GoogleFonts.hindSiliguri(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
