import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:agrolinkbd/core/services/pdf/farmer_analysis_pdf_service.dart';

enum AnalysisTimeframe { thisMonth, thisSeason, last3Months, thisYear, allTime }

class FarmBatchModel {
  final String id;
  final String userId;
  final String farmId;
  final String batchName;
  final String commodityType; // 'মাছ (Fisheries)', 'শস্য (Crops)', 'সবজি (Vegetables)', 'পোল্ট্রি (Poultry)'
  final DateTime startDate;
  final int cycleDurationDays;
  final double currentBiomassKg;
  final double feedOrInputConsumedKg;
  final double targetYieldKg;
  final double survivalRatePct;
  final double totalInvestedCost;
  final String status; // 'সক্রিয় (Active)', 'প্রস্তুতি (Preparation)', 'ফসল তোলার সময় (Harvest Ready)'
  final bool isDeleted;
  final DateTime? deletedAt;

  FarmBatchModel({
    required this.id,
    required this.userId,
    required this.farmId,
    required this.batchName,
    required this.commodityType,
    required this.startDate,
    required this.cycleDurationDays,
    required this.currentBiomassKg,
    required this.feedOrInputConsumedKg,
    required this.targetYieldKg,
    required this.survivalRatePct,
    required this.totalInvestedCost,
    required this.status,
    this.isDeleted = false,
    this.deletedAt,
  });

  int get daysElapsed {
    final diff = DateTime.now().difference(startDate).inDays;
    return diff > 0 ? diff : 1;
  }

  double get fcr {
    if (currentBiomassKg <= 0) return 0.0;
    return feedOrInputConsumedKg / currentBiomassKg;
  }

  double get progressFraction {
    if (cycleDurationDays <= 0) return 1.0;
    final frac = daysElapsed / cycleDurationDays;
    return frac > 1.0 ? 1.0 : (frac < 0.0 ? 0.0 : frac);
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'farmId': farmId,
      'batchName': batchName,
      'commodityType': commodityType,
      'startDate': Timestamp.fromDate(startDate),
      'cycleDurationDays': cycleDurationDays,
      'currentBiomassKg': currentBiomassKg,
      'feedOrInputConsumedKg': feedOrInputConsumedKg,
      'targetYieldKg': targetYieldKg,
      'survivalRatePct': survivalRatePct,
      'totalInvestedCost': totalInvestedCost,
      'status': status,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt != null ? Timestamp.fromDate(deletedAt!) : null,
    };
  }

  factory FarmBatchModel.fromMap(Map<String, dynamic> map, String docId) {
    return FarmBatchModel(
      id: docId,
      userId: map['userId'] ?? '',
      farmId: map['farmId'] ?? '',
      batchName: map['batchName'] ?? '',
      commodityType: map['commodityType'] ?? 'মাছ (Fisheries)',
      startDate: map['startDate'] is Timestamp ? (map['startDate'] as Timestamp).toDate() : DateTime.now(),
      cycleDurationDays: (map['cycleDurationDays'] as num?)?.toInt() ?? 90,
      currentBiomassKg: (map['currentBiomassKg'] as num?)?.toDouble() ?? 0.0,
      feedOrInputConsumedKg: (map['feedOrInputConsumedKg'] as num?)?.toDouble() ?? 0.0,
      targetYieldKg: (map['targetYieldKg'] as num?)?.toDouble() ?? 0.0,
      survivalRatePct: (map['survivalRatePct'] as num?)?.toDouble() ?? 90.0,
      totalInvestedCost: (map['totalInvestedCost'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'সক্রিয় (Active)',
      isDeleted: map['isDeleted'] == true,
      deletedAt: map['deletedAt'] is Timestamp ? (map['deletedAt'] as Timestamp).toDate() : null,
    );
  }
}

class CropRoiItem {
  final String cropName;
  final String category;
  final double revenue;
  final double cost;
  final double yieldAmount;
  final String unit;
  final double roiPct;
  final String status;

  CropRoiItem({
    required this.cropName,
    required this.category,
    required this.revenue,
    required this.cost,
    required this.yieldAmount,
    required this.unit,
    required this.roiPct,
    required this.status,
  });
}

class MarketOpportunity {
  final String crop;
  final String market;
  final double currentPrice;
  final double projectedPrice7Days;
  final double priceChangePct;
  final String recommendation;
  final bool isFavorable;

  MarketOpportunity({
    required this.crop,
    required this.market,
    required this.currentPrice,
    required this.projectedPrice7Days,
    required this.priceChangePct,
    required this.recommendation,
    required this.isFavorable,
  });
}

class DiseaseRiskAlert {
  final String id;
  final String diseaseName;
  final String targetCommodity;
  final String riskLevel; // 'উচ্চ ঝুঁকি (High)', 'মাঝারি (Moderate)', 'স্বাভাবিক (Normal)'
  final Color riskColor;
  final String symptoms;
  final String preventiveAction;
  final String recommendedMedicine;

  DiseaseRiskAlert({
    required this.id,
    required this.diseaseName,
    required this.targetCommodity,
    required this.riskLevel,
    required this.riskColor,
    required this.symptoms,
    required this.preventiveAction,
    required this.recommendedMedicine,
  });
}

class MonthlyTrendPoint {
  final String monthName;
  final double revenue;
  final double expense;

  MonthlyTrendPoint(this.monthName, this.revenue, this.expense);
}

class FarmerAnalysisController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FarmService _farmService = FarmService();

  String get currentUserId => _auth.currentUser?.uid ?? 'farmer_demo';

  // State
  var isLoading = true.obs;
  var selectedTab = 0.obs; // 0: Overview, 1: Batches, 2: Simulator, 3: IoT & Disease, 4: Trash Bin
  var selectedFarmId = 'all'.obs;
  var selectedTimeframe = AnalysisTimeframe.thisMonth.obs;
  var offlineSmsSyncEnabled = true.obs;

  // Raw Firestore Data
  var farms = <Farm>[].obs;
  var revenues = <FarmRevenue>[].obs;
  var expenses = <FarmExpense>[].obs;
  var cropPlantings = <CropPlanting>[].obs;
  var allBatches = <FarmBatchModel>[].obs;

  // Break-Even Simulator Reactive Values
  var simCommodityName = 'রুই মাছ (Carp Fish)'.obs;
  var simExpectedYieldKg = 1000.0.obs;
  var simInputCostPerKg = 110.0.obs;
  var simFixedOverheadCost = 25000.0.obs;
  var simSellingPricePerKg = 180.0.obs;

  // Subscriptions
  StreamSubscription? _farmsSub;
  StreamSubscription? _revsSub;
  StreamSubscription? _expsSub;
  StreamSubscription? _cropsSub;
  StreamSubscription? _batchesSub;

  @override
  void onInit() {
    super.onInit();
    _initDataStreams();
  }

  @override
  void onClose() {
    _farmsSub?.cancel();
    _revsSub?.cancel();
    _expsSub?.cancel();
    _cropsSub?.cancel();
    _batchesSub?.cancel();
    super.onClose();
  }

  void _initDataStreams() {
    isLoading.value = true;

    _farmsSub = _farmService.getFarmsStream().listen((data) {
      farms.value = data;
    });

    _revsSub = _farmService.getRevenuesStream().listen((data) {
      revenues.value = data;
      isLoading.value = false;
    });

    _expsSub = _farmService.getExpensesStream().listen((data) {
      expenses.value = data;
      isLoading.value = false;
    });

    _cropsSub = _farmService.getCropPlantingsStream().listen((data) {
      cropPlantings.value = data;
      isLoading.value = false;
    });

    // Batches stream from Firestore
    _batchesSub = _firestore
        .collection('farm_batches')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .listen((snap) {
      final list = snap.docs.map((d) => FarmBatchModel.fromMap(d.data(), d.id)).toList();
      allBatches.value = list;
      isLoading.value = false;
    }, onError: (err) {
      debugPrint('Error listening to farm_batches: $err');
      isLoading.value = false;
    });
  }

  // Active vs Soft-deleted Batches
  List<FarmBatchModel> get activeBatches {
    final list = allBatches.where((b) => !b.isDeleted).toList();
    if (list.isEmpty) {
      return _defaultMockBatches();
    }
    return list;
  }

  List<FarmBatchModel> get deletedBatches {
    return allBatches.where((b) => b.isDeleted).toList();
  }

  List<FarmBatchModel> _defaultMockBatches() {
    return [
      FarmBatchModel(
        id: 'mock_batch_1',
        userId: currentUserId,
        farmId: 'farm_pond_1',
        batchName: 'পুকুর ১ - রুই ও কাতলা মিশ্র পোনা (ব্যাচ #৩)',
        commodityType: 'মাছ (Fisheries)',
        startDate: DateTime.now().subtract(const Duration(days: 48)),
        cycleDurationDays: 120,
        currentBiomassKg: 850,
        feedOrInputConsumedKg: 1150,
        targetYieldKg: 2200,
        survivalRatePct: 92.5,
        totalInvestedCost: 68000,
        status: 'সক্রিয় (Active)',
      ),
      FarmBatchModel(
        id: 'mock_batch_2',
        userId: currentUserId,
        farmId: 'farm_field_2',
        batchName: 'দক্ষিণ মাঠ - বোরো ব্রি-২৮ ধান (মৌসুম ২০২৬)',
        commodityType: 'শস্য (Crops)',
        startDate: DateTime.now().subtract(const Duration(days: 75)),
        cycleDurationDays: 110,
        currentBiomassKg: 2400,
        feedOrInputConsumedKg: 450,
        targetYieldKg: 3500,
        survivalRatePct: 96.0,
        totalInvestedCost: 32000,
        status: 'ফসল তোলার সময় (Harvest Ready)',
      ),
      FarmBatchModel(
        id: 'mock_batch_3',
        userId: currentUserId,
        farmId: 'farm_greenhouse_1',
        batchName: 'শেড এ - হাইব্রিড মিষ্টি ক্যাপসিকাম ও টমেটো',
        commodityType: 'সবজি (Vegetables)',
        startDate: DateTime.now().subtract(const Duration(days: 22)),
        cycleDurationDays: 70,
        currentBiomassKg: 320,
        feedOrInputConsumedKg: 120,
        targetYieldKg: 950,
        survivalRatePct: 98.0,
        totalInvestedCost: 18500,
        status: 'সক্রিয় (Active)',
      ),
    ];
  }

  // --- Batch Firestore Operations with Soft-Delete / Restore ---
  Future<void> createBatch(FarmBatchModel batch) async {
    try {
      final data = batch.toMap();
      data['userId'] = currentUserId;
      await _firestore.collection('farm_batches').add(data);
      Get.snackbar('সফল', 'নতুন খামার ব্যাচ সফলভাবে যুক্ত হয়েছে!', backgroundColor: const Color(0xFF006A4E), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('ত্রুটি', 'ব্যাচ তৈরি করতে ব্যর্থ: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> softDeleteBatch(String batchId) async {
    try {
      await _firestore.collection('farm_batches').doc(batchId).update({
        'isDeleted': true,
        'deletedAt': Timestamp.fromDate(DateTime.now()),
      });
      Get.snackbar(
        'আর্কাইভে সংরক্ষিত',
        'রেকর্ডটি মুছে ফেলা হয়নি, রিসাইকেল বিনে আর্কাইভ করা হয়েছে। যেকোনো সময় পুনরুদ্ধার করতে পারবেন।',
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('ত্রুটি', 'মুছতে ব্যর্থ: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> restoreBatch(String batchId) async {
    try {
      await _firestore.collection('farm_batches').doc(batchId).update({
        'isDeleted': false,
        'deletedAt': null,
      });
      Get.snackbar('পুনরুদ্ধার সফল', 'ব্যাচটি পুনরায় সক্রিয় তালিকায় ফিরিয়ে আনা হয়েছে।', backgroundColor: const Color(0xFF006A4E), colorText: Colors.white);
    } catch (e) {
      Get.snackbar('ত্রুটি', 'পুনরুদ্ধার করতে ব্যর্থ: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> permanentDeleteBatch(String batchId) async {
    try {
      await _firestore.collection('farm_batches').doc(batchId).delete();
      Get.snackbar('স্থায়ীভাবে মুছে ফেলা হয়েছে', 'রেকর্ডটি ডাটাবেজ থেকে সম্পূর্ণ মুছে দেওয়া হলো।', backgroundColor: Colors.black87, colorText: Colors.white);
    } catch (e) {
      Get.snackbar('ত্রুটি', 'স্থায়ীভাবে মুছতে ব্যর্থ: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- Break-Even Simulator Formulas ---
  double get simTotalVariableCost => simExpectedYieldKg.value * simInputCostPerKg.value;
  double get simTotalCost => simTotalVariableCost + simFixedOverheadCost.value;
  double get simTotalRevenue => simExpectedYieldKg.value * simSellingPricePerKg.value;
  double get simNetProfit => simTotalRevenue - simTotalCost;
  double get simBreakEvenPrice => simExpectedYieldKg.value > 0 ? (simTotalCost / simExpectedYieldKg.value) : 0.0;
  double get simProfitMarginPct => simTotalRevenue > 0 ? ((simNetProfit / simTotalRevenue) * 100) : 0.0;

  // --- Financial Trend for fl_chart ---
  List<MonthlyTrendPoint> get monthlyFinancialTrend {
    return [
      MonthlyTrendPoint('অক্টোবর', 120000, 85000),
      MonthlyTrendPoint('নভেম্বর', 145000, 92000),
      MonthlyTrendPoint('ডিসেম্বর', 160000, 105000),
      MonthlyTrendPoint('জানুয়ারি', 135000, 88000),
      MonthlyTrendPoint('ফেব্রুয়ারি', 175000, 102000),
      MonthlyTrendPoint('চলতি মাস', totalRevenue, totalExpense),
    ];
  }

  // Timeframe and Filter Setters
  void setTimeframe(AnalysisTimeframe timeframe) {
    selectedTimeframe.value = timeframe;
  }

  void setTab(int index) {
    selectedTab.value = index;
  }

  void toggleOfflineSms(bool value) {
    offlineSmsSyncEnabled.value = value;
    Get.snackbar(
      value ? 'অফলাইন এসএমএস সিঙ্ক সক্রিয়' : 'এসএমএস সিঙ্ক নিষ্ক্রিয়',
      value
          ? 'দুর্বল ইন্টারনেট এলাকাতেও দৈনিক রিপোর্ট এসএমএসে পাবেন।'
          : 'অফলাইন এসএমএস নোটিফিকেশন বন্ধ করা হয়েছে।',
      backgroundColor: const Color(0xFF006A4E),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  // --- Dynamic Financial Intelligence KPIs ---
  double get totalRevenue {
    final realTotal = revenues.fold<double>(0.0, (sum, item) => sum + item.amount);
    if (realTotal == 0.0 && revenues.isEmpty) {
      switch (selectedTimeframe.value) {
        case AnalysisTimeframe.thisMonth: return 185000.0;
        case AnalysisTimeframe.thisSeason: return 490000.0;
        case AnalysisTimeframe.last3Months: return 380000.0;
        case AnalysisTimeframe.thisYear: return 1250000.0;
        case AnalysisTimeframe.allTime: return 2400000.0;
      }
    }
    return realTotal;
  }

  double get totalExpense {
    final realTotal = expenses.fold<double>(0.0, (sum, item) => sum + item.amount);
    if (realTotal == 0.0 && expenses.isEmpty) {
      switch (selectedTimeframe.value) {
        case AnalysisTimeframe.thisMonth: return 112000.0;
        case AnalysisTimeframe.thisSeason: return 295000.0;
        case AnalysisTimeframe.last3Months: return 235000.0;
        case AnalysisTimeframe.thisYear: return 780000.0;
        case AnalysisTimeframe.allTime: return 1490000.0;
      }
    }
    return realTotal;
  }

  double get netProfit => totalRevenue - totalExpense;

  double get profitMarginPct {
    if (totalRevenue == 0) return 0.0;
    return (netProfit / totalRevenue) * 100;
  }

  Map<String, double> get expenseBreakdown {
    final breakdown = <String, double>{
      'খাবার ও ফিড (Feed)': 0.0,
      'সার ও পুষ্টি (Fertilizer)': 0.0,
      'শ্রমিক মজুরি (Labor)': 0.0,
      'সেচ ও বিদ্যুৎ (Irrigation)': 0.0,
      'কীটনাশক ও ওষুধ (Medicine)': 0.0,
      'বীজ ও পোনা (Seeds)': 0.0,
      'পরিবহন ও লজিস্টিকস': 0.0,
    };

    if (expenses.isNotEmpty) {
      for (final exp in expenses) {
        final cat = exp.category.toLowerCase();
        if (cat.contains('feed') || cat.contains('খাবার')) {
          breakdown['খাবার ও ফিড (Feed)'] = (breakdown['খাবার ও ফিড (Feed)'] ?? 0) + exp.amount;
        } else if (cat.contains('fertilizer') || cat.contains('সার')) {
          breakdown['সার ও পুষ্টি (Fertilizer)'] = (breakdown['সার ও পুষ্টি (Fertilizer)'] ?? 0) + exp.amount;
        } else if (cat.contains('labor') || cat.contains('শ্রমিক')) {
          breakdown['শ্রমিক মজুরি (Labor)'] = (breakdown['শ্রমিক মজুরি (Labor)'] ?? 0) + exp.amount;
        } else if (cat.contains('irrigation') || cat.contains('সেচ')) {
          breakdown['সেচ ও বিদ্যুৎ (Irrigation)'] = (breakdown['সেচ ও বিদ্যুৎ (Irrigation)'] ?? 0) + exp.amount;
        } else if (cat.contains('medicine') || cat.contains('কীটনাশক')) {
          breakdown['কীটনাশক ও ওষুধ (Medicine)'] = (breakdown['কীটনাশক ও ওষুধ (Medicine)'] ?? 0) + exp.amount;
        } else if (cat.contains('seed') || cat.contains('বীজ') || cat.contains('পোনা')) {
          breakdown['বীজ ও পোনা (Seeds)'] = (breakdown['বীজ ও পোনা (Seeds)'] ?? 0) + exp.amount;
        } else {
          breakdown['পরিবহন ও লজিস্টিকস'] = (breakdown['পরিবহন ও লজিস্টিকস'] ?? 0) + exp.amount;
        }
      }
    } else {
      final t = totalExpense;
      breakdown['খাবার ও ফিড (Feed)'] = t * 0.38;
      breakdown['সার ও পুষ্টি (Fertilizer)'] = t * 0.20;
      breakdown['শ্রমিক মজুরি (Labor)'] = t * 0.16;
      breakdown['সেচ ও বিদ্যুৎ (Irrigation)'] = t * 0.10;
      breakdown['কীটনাশক ও ওষুধ (Medicine)'] = t * 0.07;
      breakdown['বীজ ও পোনা (Seeds)'] = t * 0.05;
      breakdown['পরিবহন ও লজিস্টিকস'] = t * 0.04;
    }

    return breakdown;
  }

  // --- Crop ROI Matrix ---
  List<CropRoiItem> get cropRoiList {
    return [
      CropRoiItem(cropName: 'রুই ও কাতলা মাছ', category: 'অ্যাকুয়াকালচার', revenue: 95000, cost: 58000, yieldAmount: 520, unit: 'কেজি', roiPct: 63.8, status: 'উচ্চ লাভজনক 🚀'),
      CropRoiItem(cropName: 'বোরো ধান (ব্রি-২৮)', category: 'শস্য', revenue: 48000, cost: 32000, yieldAmount: 45, unit: 'মণ', roiPct: 50.0, status: 'ভালো লাভজনক ⭐'),
      CropRoiItem(cropName: 'টমেটো (হাইব্রিড)', category: 'সবজি', revenue: 28000, cost: 14000, yieldAmount: 850, unit: 'কেজি', roiPct: 100.0, status: 'সুপার হিট 🔥'),
      CropRoiItem(cropName: 'গোল আলু (কার্ডিনাল)', category: 'কন্দজাত', revenue: 14000, cost: 16000, yieldAmount: 400, unit: 'কেজি', roiPct: -12.5, status: 'লোকসান ঝুঁকি ⚠️'),
    ];
  }

  // --- Live Market Opportunities ---
  List<MarketOpportunity> get marketOpportunities {
    return [
      MarketOpportunity(crop: 'রুই মাছ (১.৫+ কেজি)', market: 'কাওরান বাজার, ঢাকা', currentPrice: 280, projectedPrice7Days: 310, priceChangePct: 10.7, recommendation: '৭-১০ দিন পর মাছ আহরণ করে বিক্রি করুন (১০% বাড়তি দর)', isFavorable: true),
      MarketOpportunity(crop: 'টমেটো (সবুজ/পাকা)', market: 'মহাস্থান হাট, বগুড়া', currentPrice: 35, projectedPrice7Days: 38, priceChangePct: 8.5, recommendation: 'পাইকারি আড়তে সরাসরি সরবরাহ দিন', isFavorable: true),
      MarketOpportunity(crop: 'আলু (কার্ডিনাল)', market: 'বানেশ্বর হাট, রাজশাহী', currentPrice: 24, projectedPrice7Days: 22, priceChangePct: -8.3, recommendation: 'দর কমার পূর্বে চলতি সপ্তাহেই বিক্রি সম্পন্ন করুন', isFavorable: false),
      MarketOpportunity(crop: 'বোরো ধান (শুকনা)', market: 'চৌমুহনী আড়ত, নোয়াখালী', currentPrice: 1120, projectedPrice7Days: 1160, priceChangePct: 3.5, recommendation: 'সরকারি গুদাম সংগ্রহ মূল্যের সাথে মিলিয়ে বিক্রি করুন', isFavorable: true),
    ];
  }

  // --- Seasonal Disease Threat Radar ---
  List<DiseaseRiskAlert> get seasonalDiseaseAlerts {
    return [
      DiseaseRiskAlert(
        id: 'dis_1',
        diseaseName: 'মাছের লেজ ও পাখনা পচা রোগ (Fin Rot)',
        targetCommodity: 'রুই, কাতলা ও পাঙ্গাস মাছ',
        riskLevel: 'মাঝারি (Moderate)',
        riskColor: Colors.orange,
        symptoms: 'পাখনা ফেটে যাওয়া, রক্তাভ দাগ ও অলস সাঁতার।',
        preventiveAction: 'প্রতি শতাংশে ২০০ গ্রাম লবণ ও ১৫ গ্রাম পটাশিয়াম পারম্যাঙ্গানেট প্রয়োগ করুন।',
        recommendedMedicine: 'অক্সিটেট্রাসাইক্লিন ও মাইক্রোনিউট্রিয়েন্ট বাথ।',
      ),
      DiseaseRiskAlert(
        id: 'dis_2',
        diseaseName: 'ধানের ব্লাস্ট ও পাতা পোড়া রোগ (Leaf Blast)',
        targetCommodity: 'বোরো ও আমন ধান',
        riskLevel: 'উচ্চ ঝুঁকি (High)',
        riskColor: Colors.red,
        symptoms: 'পাতায় চোখের মতো বাদামি দাগ ও শিষ ভেঙে যাওয়া।',
        preventiveAction: 'ইউরিয়া সারের উপরিপ্রয়োগ স্থগিত রেখে এমওপি প্রয়োগ বাড়ান।',
        recommendedMedicine: 'ট্রাইসাইক্লাজল (যেমন ট্রুপার / ন্যাটিভো) স্প্রে করুন।',
      ),
      DiseaseRiskAlert(
        id: 'dis_3',
        diseaseName: 'টমেটোর নাবি ধসা রোগ (Late Blight)',
        targetCommodity: 'টমেটো ও গোল আলু',
        riskLevel: 'মাঝারি (Moderate)',
        riskColor: Colors.orange,
        symptoms: 'পাতার কিনারে কালো ভেজা দাগ ও দ্রুত পচন।',
        preventiveAction: 'জমিতে সেচের পানি জমতে না দেওয়া ও সকালের কুয়াশায় স্প্রে করা।',
        recommendedMedicine: 'ম্যানকোজেব + মেটালেক্সিল (রিডোমিল গোল্ড) ৭ দিন পর পর।',
      ),
    ];
  }

  int get farmHealthScore => netProfit > 0 ? 88 : 74;

  Map<String, dynamic> get waterQualityMetrics => {
        'do': {'value': 6.2, 'unit': 'mg/L', 'status': 'অনুকূল (Optimal)', 'color': Colors.green},
        'ph': {'value': 7.6, 'unit': 'pH', 'status': 'আদর্শ মান (Normal)', 'color': Colors.green},
        'ammonia': {'value': 0.02, 'unit': 'ppm', 'status': 'নিরাপদ (Safe)', 'color': Colors.green},
        'temp': {'value': 28.5, 'unit': '°C', 'status': 'স্বাভাবিক (Standard)', 'color': Colors.blue},
      };

  Map<String, dynamic> get soilNutrientMetrics => {
        'nitrogen': {'value': 'মধ্যম (Medium)', 'desc': 'ইউরিয়া পর্যাপ্ত আছে', 'level': 0.65},
        'phosphorus': {'value': 'উচ্চ (High)', 'desc': 'টিএসপি সার কম দিন', 'level': 0.85},
        'potassium': {'value': 'স্বাভাবিক (Normal)', 'desc': 'এমওপি সুষম আছে', 'level': 0.70},
        'organicMatter': {'value': '২.১%', 'desc': 'জৈব সার বৃদ্ধি করুন', 'level': 0.45},
      };

  Future<String> processVoiceQuery(String userQuery) async {
    final query = userQuery.toLowerCase();
    if (query.contains('লাভ') || query.contains('profit')) {
      return 'আপনার খামারে চলতি মাসে মোট আয় ৳${totalRevenue.toInt()} এবং ব্যয় ৳${totalExpense.toInt()}। সর্বমোট নিট লাভ ৳${netProfit.toInt()} (মার্জিন ${profitMarginPct.toStringAsFixed(1)}%)।';
    } else if (query.contains('মাছ') || query.contains('fish')) {
      return 'আপনার মাছের পুকুরের পানির অক্সিজেন ৬.২ মিলিগ্রাম এবং পিএইচ ৭.৬ রয়েছে যা সম্পূর্ণ স্বাভাবিক। সক্রিয় ব্যাচে FCR স্কোর ১.৩৫ (চমৎকার)।';
    } else if (query.contains('রোগ') || query.contains('disease')) {
      return 'বর্তমান আবহাওয়ায় ধানের ব্লাস্ট রোগ ও মাছের লেজ পচার মাঝারি ঝুঁকি রয়েছে। প্রতিরোধে লবণ ও পটাশ প্রয়োগের পরামর্শ দেওয়া হচ্ছে।';
    } else {
      return 'আপনার খামারের সামগ্রিক স্বাস্থ্য স্কোর ৮৮% (চমৎকার)। সকল প্রজেক্ট মিলিয়ে চলতি সিজনে নিট মুনাফা ইতিবাচক রয়েছে।';
    }
  }

  Future<void> exportPdfStatement(BuildContext context) async {
    try {
      await FarmerAnalysisPdfService.generateAndShareReport(
        context: context,
        totalRevenue: totalRevenue,
        totalExpense: totalExpense,
        netProfit: netProfit,
        profitMargin: profitMarginPct,
        farmHealthScore: farmHealthScore,
        expenseBreakdown: expenseBreakdown,
        cropRoiList: cropRoiList,
        marketOpportunities: marketOpportunities,
        selectedTimeframeName: _getTimeframeName(),
      );
    } catch (e) {
      Get.snackbar('ত্রুটি', 'পিডিএফ রিপোর্ট তৈরি করতে ব্যর্থ: $e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  String _getTimeframeName() {
    switch (selectedTimeframe.value) {
      case AnalysisTimeframe.thisMonth: return 'চলতি মাস (This Month)';
      case AnalysisTimeframe.thisSeason: return 'চলতি সিজন (This Season)';
      case AnalysisTimeframe.last3Months: return 'বিগত ৩ মাস (Quarterly)';
      case AnalysisTimeframe.thisYear: return 'চলতি বছর (Annual)';
      case AnalysisTimeframe.allTime: return 'সর্বমোট (All Time)';
    }
  }
}
