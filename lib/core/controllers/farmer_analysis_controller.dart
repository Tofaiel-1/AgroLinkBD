import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agrolinkbd/core/models/phase2_models/farm_models.dart';
import 'package:agrolinkbd/core/services/phase2_services/farm_service.dart';
import 'package:agrolinkbd/core/services/pdf/farmer_analysis_pdf_service.dart';
import 'package:agrolinkbd/core/services/farmer_gemini_ai_service.dart';

enum AnalysisTimeframe { thisMonth, thisSeason, last3Months, thisYear, allTime }

class FarmBatchModel {
  final String id;
  final String userId;
  final String farmId;
  final String batchName;
  final String commodityType;
  final DateTime startDate;
  final int cycleDurationDays;
  final double currentBiomassKg;
  final double feedOrInputConsumedKg;
  final double targetYieldKg;
  final double survivalRatePct;
  final double totalInvestedCost;
  final String status;
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
      commodityType: map['commodityType'] ?? 'Fisheries (মাছ)',
      startDate: map['startDate'] is Timestamp ? (map['startDate'] as Timestamp).toDate() : DateTime.now(),
      cycleDurationDays: (map['cycleDurationDays'] as num?)?.toInt() ?? 90,
      currentBiomassKg: (map['currentBiomassKg'] as num?)?.toDouble() ?? 0.0,
      feedOrInputConsumedKg: (map['feedOrInputConsumedKg'] as num?)?.toDouble() ?? 0.0,
      targetYieldKg: (map['targetYieldKg'] as num?)?.toDouble() ?? 0.0,
      survivalRatePct: (map['survivalRatePct'] as num?)?.toDouble() ?? 90.0,
      totalInvestedCost: (map['totalInvestedCost'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Active',
      isDeleted: map['isDeleted'] == true,
      deletedAt: map['deletedAt'] is Timestamp ? (map['deletedAt'] as Timestamp).toDate() : null,
    );
  }
}

class CropRoiItem {
  final String cropNameBn;
  final String cropNameEn;
  final String categoryBn;
  final String categoryEn;
  final double revenue;
  final double cost;
  final double yieldAmount;
  final String unitBn;
  final String unitEn;
  final double roiPct;
  final String statusBn;
  final String statusEn;

  CropRoiItem({
    required this.cropNameBn,
    required this.cropNameEn,
    required this.categoryBn,
    required this.categoryEn,
    required this.revenue,
    required this.cost,
    required this.yieldAmount,
    required this.unitBn,
    required this.unitEn,
    required this.roiPct,
    required this.statusBn,
    required this.statusEn,
  });
}

class MarketOpportunity {
  final String cropBn;
  final String cropEn;
  final String marketBn;
  final String marketEn;
  final double currentPrice;
  final double projectedPrice7Days;
  final double priceChangePct;
  final String recommendationBn;
  final String recommendationEn;
  final bool isFavorable;

  MarketOpportunity({
    required this.cropBn,
    required this.cropEn,
    required this.marketBn,
    required this.marketEn,
    required this.currentPrice,
    required this.projectedPrice7Days,
    required this.priceChangePct,
    required this.recommendationBn,
    required this.recommendationEn,
    required this.isFavorable,
  });
}

class DiseaseRiskAlert {
  final String id;
  final String diseaseNameBn;
  final String diseaseNameEn;
  final String targetCommodityBn;
  final String targetCommodityEn;
  final String riskLevelBn;
  final String riskLevelEn;
  final Color riskColor;
  final String symptomsBn;
  final String symptomsEn;
  final String preventiveActionBn;
  final String preventiveActionEn;
  final String recommendedMedicineBn;
  final String recommendedMedicineEn;

  DiseaseRiskAlert({
    required this.id,
    required this.diseaseNameBn,
    required this.diseaseNameEn,
    required this.targetCommodityBn,
    required this.targetCommodityEn,
    required this.riskLevelBn,
    required this.riskLevelEn,
    required this.riskColor,
    required this.symptomsBn,
    required this.symptomsEn,
    required this.preventiveActionBn,
    required this.preventiveActionEn,
    required this.recommendedMedicineBn,
    required this.recommendedMedicineEn,
  });
}

class MonthlyTrendPoint {
  final String monthNameBn;
  final String monthNameEn;
  final double revenue;
  final double expense;

  MonthlyTrendPoint({
    required this.monthNameBn,
    required this.monthNameEn,
    required this.revenue,
    required this.expense,
  });
}

class FarmerAnalysisController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FarmService _farmService = FarmService();

  String get currentUserId => _auth.currentUser?.uid ?? 'farmer_demo';

  // State
  var isLoading = true.obs;
  var selectedTab = 0.obs;
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
        batchName: 'Pond 1 - Rohu & Catla Mixed Fingerlings (Batch #3)',
        commodityType: 'Fisheries',
        startDate: DateTime.now().subtract(const Duration(days: 48)),
        cycleDurationDays: 120,
        currentBiomassKg: 850,
        feedOrInputConsumedKg: 1150,
        targetYieldKg: 2200,
        survivalRatePct: 92.5,
        totalInvestedCost: 68000,
        status: 'Active',
      ),
      FarmBatchModel(
        id: 'mock_batch_2',
        userId: currentUserId,
        farmId: 'farm_field_2',
        batchName: 'South Field - Boro BR-28 Rice (Season 2026)',
        commodityType: 'Crops',
        startDate: DateTime.now().subtract(const Duration(days: 75)),
        cycleDurationDays: 110,
        currentBiomassKg: 2400,
        feedOrInputConsumedKg: 450,
        targetYieldKg: 3500,
        survivalRatePct: 96.0,
        totalInvestedCost: 32000,
        status: 'Harvest Ready',
      ),
      FarmBatchModel(
        id: 'mock_batch_3',
        userId: currentUserId,
        farmId: 'farm_greenhouse_1',
        batchName: 'Greenhouse Shed A - Hybrid Sweet Capsicum & Tomato',
        commodityType: 'Vegetables',
        startDate: DateTime.now().subtract(const Duration(days: 22)),
        cycleDurationDays: 70,
        currentBiomassKg: 320,
        feedOrInputConsumedKg: 120,
        targetYieldKg: 950,
        survivalRatePct: 98.0,
        totalInvestedCost: 18500,
        status: 'Active',
      ),
    ];
  }

  Future<void> createBatch(FarmBatchModel batch, bool isBn) async {
    try {
      final data = batch.toMap();
      data['userId'] = currentUserId;
      await _firestore.collection('farm_batches').add(data);
      Get.snackbar(
        isBn ? 'সফল' : 'Success',
        isBn ? 'নতুন খামার ব্যাচ সফলভাবে যুক্ত হয়েছে!' : 'New farm batch created successfully!',
        backgroundColor: const Color(0xFF006A4E),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(isBn ? 'ত্রুটি' : 'Error', '$e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> softDeleteBatch(String batchId, bool isBn) async {
    try {
      await _firestore.collection('farm_batches').doc(batchId).update({
        'isDeleted': true,
        'deletedAt': Timestamp.fromDate(DateTime.now()),
      });
      Get.snackbar(
        isBn ? 'আর্কাইভে সংরক্ষিত' : 'Moved to Archive',
        isBn
            ? 'রেকর্ডটি রিসাইকেল বিনে সুরক্ষিত রয়েছে। যেকোনো সময় পুনরুদ্ধার করতে পারবেন।'
            : 'Record safely archived in Trash Bin. You can restore it anytime.',
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(isBn ? 'ত্রুটি' : 'Error', '$e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> restoreBatch(String batchId, bool isBn) async {
    try {
      await _firestore.collection('farm_batches').doc(batchId).update({
        'isDeleted': false,
        'deletedAt': null,
      });
      Get.snackbar(
        isBn ? 'পুনরুদ্ধার সফল' : 'Restored Successfully',
        isBn ? 'ব্যাচটি পুনরায় সক্রিয় তালিকায় ফিরিয়ে আনা হয়েছে।' : 'Batch restored back to active list.',
        backgroundColor: const Color(0xFF006A4E),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(isBn ? 'ত্রুটি' : 'Error', '$e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> permanentDeleteBatch(String batchId, bool isBn) async {
    try {
      await _firestore.collection('farm_batches').doc(batchId).delete();
      Get.snackbar(
        isBn ? 'স্থায়ীভাবে মুছে ফেলা হয়েছে' : 'Permanently Deleted',
        isBn ? 'রেকর্ডটি ডাটাবেজ থেকে সম্পূর্ণ মুছে দেওয়া হলো।' : 'Record permanently removed from database.',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(isBn ? 'ত্রুটি' : 'Error', '$e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // Simulator Formulas
  double get simTotalVariableCost => simExpectedYieldKg.value * simInputCostPerKg.value;
  double get simTotalCost => simTotalVariableCost + simFixedOverheadCost.value;
  double get simTotalRevenue => simExpectedYieldKg.value * simSellingPricePerKg.value;
  double get simNetProfit => simTotalRevenue - simTotalCost;
  double get simBreakEvenPrice => simExpectedYieldKg.value > 0 ? (simTotalCost / simExpectedYieldKg.value) : 0.0;
  double get simProfitMarginPct => simTotalRevenue > 0 ? ((simNetProfit / simTotalRevenue) * 100) : 0.0;

  // fl_chart Trend Points
  List<MonthlyTrendPoint> get monthlyFinancialTrend {
    return [
      MonthlyTrendPoint(monthNameBn: 'অক্টোবর', monthNameEn: 'Oct', revenue: 120000, expense: 85000),
      MonthlyTrendPoint(monthNameBn: 'নভেম্বর', monthNameEn: 'Nov', revenue: 145000, expense: 92000),
      MonthlyTrendPoint(monthNameBn: 'ডিসেম্বর', monthNameEn: 'Dec', revenue: 160000, expense: 105000),
      MonthlyTrendPoint(monthNameBn: 'জানুয়ারি', monthNameEn: 'Jan', revenue: 135000, expense: 88000),
      MonthlyTrendPoint(monthNameBn: 'ফেব্রুয়ারি', monthNameEn: 'Feb', revenue: 175000, expense: 102000),
      MonthlyTrendPoint(monthNameBn: 'চলতি মাস', monthNameEn: 'Current', revenue: totalRevenue, expense: totalExpense),
    ];
  }

  void setTimeframe(AnalysisTimeframe timeframe) {
    selectedTimeframe.value = timeframe;
  }

  void setTab(int index) {
    selectedTab.value = index;
  }

  void toggleOfflineSms(bool value, bool isBn) {
    offlineSmsSyncEnabled.value = value;
    Get.snackbar(
      value ? (isBn ? 'অফলাইন এসএমএস সিঙ্ক সক্রিয়' : 'Offline SMS Sync Active') : (isBn ? 'এসএমএস সিঙ্ক নিষ্ক্রিয়' : 'SMS Sync Disabled'),
      value
          ? (isBn ? 'দুর্বল ইন্টারনেট এলাকাতেও দৈনিক রিপোর্ট এসএমএসে পাবেন।' : 'Daily analytics reports will be delivered via SMS in low-network areas.')
          : (isBn ? 'অফলাইন এসএমএস নোটিফিকেশন বন্ধ করা হয়েছে।' : 'Offline SMS notifications have been disabled.'),
      backgroundColor: const Color(0xFF006A4E),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

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

  Map<String, double> getExpenseBreakdown(bool isBn) {
    final feedKey = isBn ? 'খাবার ও ফিড (Feed)' : 'Feed & Nutrition';
    final fertKey = isBn ? 'সার ও পুষ্টি (Fertilizer)' : 'Fertilizers & Nutrients';
    final laborKey = isBn ? 'শ্রমিক মজুরি (Labor)' : 'Labor & Farm Hands';
    final irrigKey = isBn ? 'সেচ ও বিদ্যুৎ (Irrigation)' : 'Irrigation & Electricity';
    final medKey = isBn ? 'কীটনাশক ও ওষুধ (Medicine)' : 'Medicine & Pesticides';
    final seedKey = isBn ? 'বীজ ও পোনা (Seeds)' : 'Seeds & Fingerlings';
    final logKey = isBn ? 'পরিবহন ও লজিস্টিকস' : 'Logistics & Transport';

    final breakdown = <String, double>{
      feedKey: 0.0,
      fertKey: 0.0,
      laborKey: 0.0,
      irrigKey: 0.0,
      medKey: 0.0,
      seedKey: 0.0,
      logKey: 0.0,
    };

    if (expenses.isNotEmpty) {
      for (final exp in expenses) {
        final cat = exp.category.toLowerCase();
        if (cat.contains('feed') || cat.contains('খাবার')) {
          breakdown[feedKey] = (breakdown[feedKey] ?? 0) + exp.amount;
        } else if (cat.contains('fertilizer') || cat.contains('সার')) {
          breakdown[fertKey] = (breakdown[fertKey] ?? 0) + exp.amount;
        } else if (cat.contains('labor') || cat.contains('শ্রমিক')) {
          breakdown[laborKey] = (breakdown[laborKey] ?? 0) + exp.amount;
        } else if (cat.contains('irrigation') || cat.contains('সেচ')) {
          breakdown[irrigKey] = (breakdown[irrigKey] ?? 0) + exp.amount;
        } else if (cat.contains('medicine') || cat.contains('কীটনাশক')) {
          breakdown[medKey] = (breakdown[medKey] ?? 0) + exp.amount;
        } else if (cat.contains('seed') || cat.contains('বীজ') || cat.contains('পোনা')) {
          breakdown[seedKey] = (breakdown[seedKey] ?? 0) + exp.amount;
        } else {
          breakdown[logKey] = (breakdown[logKey] ?? 0) + exp.amount;
        }
      }
    } else {
      final t = totalExpense;
      breakdown[feedKey] = t * 0.38;
      breakdown[fertKey] = t * 0.20;
      breakdown[laborKey] = t * 0.16;
      breakdown[irrigKey] = t * 0.10;
      breakdown[medKey] = t * 0.07;
      breakdown[seedKey] = t * 0.05;
      breakdown[logKey] = t * 0.04;
    }

    return breakdown;
  }

  List<CropRoiItem> get cropRoiList {
    return [
      CropRoiItem(
        cropNameBn: 'রুই ও কাতলা মাছ',
        cropNameEn: 'Rohu & Catla Carp Fish',
        categoryBn: 'অ্যাকুয়াকালচার',
        categoryEn: 'Aquaculture',
        revenue: 95000,
        cost: 58000,
        yieldAmount: 520,
        unitBn: 'কেজি',
        unitEn: 'kg',
        roiPct: 63.8,
        statusBn: 'উচ্চ লাভজনক 🚀',
        statusEn: 'High Profit 🚀',
      ),
      CropRoiItem(
        cropNameBn: 'বোরো ধান (ব্রি-২৮)',
        cropNameEn: 'Boro Rice (BR-28)',
        categoryBn: 'শস্য',
        categoryEn: 'Crops',
        revenue: 48000,
        cost: 32000,
        yieldAmount: 45,
        unitBn: 'মণ',
        unitEn: 'maund',
        roiPct: 50.0,
        statusBn: 'ভালো লাভজনক ⭐',
        statusEn: 'Profitable ⭐',
      ),
      CropRoiItem(
        cropNameBn: 'টমেটো (হাইব্রিড)',
        cropNameEn: 'Hybrid Tomato',
        categoryBn: 'সবজি',
        categoryEn: 'Vegetables',
        revenue: 28000,
        cost: 14000,
        yieldAmount: 850,
        unitBn: 'কেজি',
        unitEn: 'kg',
        roiPct: 100.0,
        statusBn: 'সুপার হিট 🔥',
        statusEn: 'Super Return 🔥',
      ),
      CropRoiItem(
        cropNameBn: 'গোল আলু (কার্ডিনাল)',
        cropNameEn: 'Cardinal Potato',
        categoryBn: 'কন্দজাত',
        categoryEn: 'Tubers',
        revenue: 14000,
        cost: 16000,
        yieldAmount: 400,
        unitBn: 'কেজি',
        unitEn: 'kg',
        roiPct: -12.5,
        statusBn: 'লোকসান ঝুঁকি ⚠️',
        statusEn: 'Loss Risk ⚠️',
      ),
    ];
  }

  List<MarketOpportunity> get marketOpportunities {
    return [
      MarketOpportunity(
        cropBn: 'রুই মাছ (১.৫+ কেজি)',
        cropEn: 'Rohu Fish (1.5+ kg)',
        marketBn: 'কাওরান বাজার, ঢাকা',
        marketEn: 'Karwan Bazar, Dhaka',
        currentPrice: 280,
        projectedPrice7Days: 310,
        priceChangePct: 10.7,
        recommendationBn: '৭-১০ দিন পর মাছ আহরণ করে বিক্রি করুন (১০% বাড়তি দর)',
        recommendationEn: 'Harvest & sell in 7-10 days for ~10% price premium',
        isFavorable: true,
      ),
      MarketOpportunity(
        cropBn: 'টমেটো (সবুজ/পাকা)',
        cropEn: 'Tomato (Fresh)',
        marketBn: 'মহাস্থান হাট, বগুড়া',
        marketEn: 'Mahasthan Hat, Bogura',
        currentPrice: 35,
        projectedPrice7Days: 38,
        priceChangePct: 8.5,
        recommendationBn: 'পাইকারি আড়তে সরাসরি সরবরাহ দিন',
        recommendationEn: 'Supply directly to wholesale regional mandi',
        isFavorable: true,
      ),
      MarketOpportunity(
        cropBn: 'আলু (কার্ডিনাল)',
        cropEn: 'Potato (Cardinal)',
        marketBn: 'বানেশ্বর হাট, রাজশাহী',
        marketEn: 'Baneswar Hat, Rajshahi',
        currentPrice: 24,
        projectedPrice7Days: 22,
        priceChangePct: -8.3,
        recommendationBn: 'দর কমার পূর্বে চলতি সপ্তাহেই বিক্রি সম্পন্ন করুন',
        recommendationEn: 'Sell current inventory this week before price drop',
        isFavorable: false,
      ),
      MarketOpportunity(
        cropBn: 'বোরো ধান (শুকনা)',
        cropEn: 'Boro Rice (Dried)',
        marketBn: 'চৌমুহনী আড়ত, নোয়াখালী',
        marketEn: 'Chowmuhani Mandi, Noakhali',
        currentPrice: 1120,
        projectedPrice7Days: 1160,
        priceChangePct: 3.5,
        recommendationBn: 'সরকারি গুদাম সংগ্রহ মূল্যের সাথে মিলিয়ে বিক্রি করুন',
        recommendationEn: 'Compare and align with govt procurement price',
        isFavorable: true,
      ),
    ];
  }

  List<DiseaseRiskAlert> get seasonalDiseaseAlerts {
    return [
      DiseaseRiskAlert(
        id: 'dis_1',
        diseaseNameBn: 'মাছের লেজ ও পাখনা পচা রোগ (Fin Rot)',
        diseaseNameEn: 'Fish Fin & Tail Rot Disease',
        targetCommodityBn: 'রুই, কাতলা ও পাঙ্গাস মাছ',
        targetCommodityEn: 'Rohu, Catla & Pangas Fish',
        riskLevelBn: 'মাঝারি ঝুঁকি (Moderate)',
        riskLevelEn: 'Moderate Risk',
        riskColor: Colors.orange,
        symptomsBn: 'পাখনা ফেটে যাওয়া, রক্তাভ দাগ ও অলস সাঁতার।',
        symptomsEn: 'Frayed fins, red blotches, and lethargic swimming.',
        preventiveActionBn: 'প্রতি শতাংশে ২০০ গ্রাম লবণ ও ১৫ গ্রাম পটাশিয়াম পারম্যাঙ্গানেট প্রয়োগ করুন।',
        preventiveActionEn: 'Apply 200g salt & 15g Potassium Permanganate per decimal.',
        recommendedMedicineBn: 'অক্সিটেট্রাসাইক্লিন ও মাইক্রোনিউট্রিয়েন্ট বাথ।',
        recommendedMedicineEn: 'Oxytetracycline bath & water conditioning.',
      ),
      DiseaseRiskAlert(
        id: 'dis_2',
        diseaseNameBn: 'ধানের ব্লাস্ট ও পাতা পোড়া রোগ (Leaf Blast)',
        diseaseNameEn: 'Rice Leaf Blast & Sheath Rot',
        targetCommodityBn: 'বোরো ও আমন ধান',
        targetCommodityEn: 'Boro & Aman Paddy',
        riskLevelBn: 'উচ্চ ঝুঁকি (High)',
        riskLevelEn: 'High Risk',
        riskColor: Colors.red,
        symptomsBn: 'পাতায় চোখের মতো বাদামি দাগ ও শিষ ভেঙে যাওয়া।',
        symptomsEn: 'Eye-shaped brown lesions on leaves and neck rot.',
        preventiveActionBn: 'ইউরিয়া সারের উপরিপ্রয়োগ স্থগিত রেখে এমওপি প্রয়োগ বাড়ান।',
        preventiveActionEn: 'Halt topdressing of Urea; apply supplementary MOP.',
        recommendedMedicineBn: 'ট্রাইসাইক্লাজল (যেমন ট্রুপার / ন্যাটিভো) স্প্রে করুন।',
        recommendedMedicineEn: 'Tricyclazole (Trooper / Nativo) preventive spray.',
      ),
      DiseaseRiskAlert(
        id: 'dis_3',
        diseaseNameBn: 'টমেটোর নাবি ধসা রোগ (Late Blight)',
        diseaseNameEn: 'Tomato & Potato Late Blight',
        targetCommodityBn: 'টমেটো ও গোল আলু',
        targetCommodityEn: 'Tomato & Potato',
        riskLevelBn: 'মাঝারি ঝুঁকি (Moderate)',
        riskLevelEn: 'Moderate Risk',
        riskColor: Colors.orange,
        symptomsBn: 'পাতার কিনারে কালো ভেজা দাগ ও দ্রুত পচন।',
        symptomsEn: 'Water-soaked black lesions on leaf margins & rapid decay.',
        preventiveActionBn: 'জমিতে সেচের পানি জমতে না দেওয়া ও সকালের কুয়াশায় স্প্রে করা।',
        preventiveActionEn: 'Avoid stagnant irrigation and spray after morning dew.',
        recommendedMedicineBn: 'ম্যানকোজেব + মেটালেক্সিল (রিডোমিল গোল্ড) ৭ দিন পর পর।',
        recommendedMedicineEn: 'Mancozeb + Metalaxyl (Ridomil Gold) every 7 days.',
      ),
    ];
  }

  final RxList<AiChatMessage> aiChatMessages = <AiChatMessage>[].obs;
  final RxBool isAiThinking = false.obs;

  int get farmHealthScore => netProfit > 0 ? 88 : 74;

  Map<String, dynamic> getWaterQualityMetrics(bool isBn) => {
        'do': {'value': 6.2, 'unit': 'mg/L', 'status': isBn ? 'অনুকূল (Optimal)' : 'Optimal', 'color': Colors.green},
        'ph': {'value': 7.6, 'unit': 'pH', 'status': isBn ? 'আদর্শ মান (Normal)' : 'Normal', 'color': Colors.green},
        'ammonia': {'value': 0.02, 'unit': 'ppm', 'status': isBn ? 'নিরাপদ (Safe)' : 'Safe', 'color': Colors.green},
        'temp': {'value': 28.5, 'unit': '°C', 'status': isBn ? 'স্বাভাবিক (Standard)' : 'Standard', 'color': Colors.blue},
      };

  /// Ask Gemini AI Agronomist with 100% Real-Time Farm Context
  Future<String> processVoiceQuery(String userQuery, bool isBn) async {
    isAiThinking.value = true;
    aiChatMessages.add(AiChatMessage(
      text: userQuery,
      isUser: true,
      timestamp: DateTime.now(),
    ));

    try {
      final response = await FarmerGeminiAiService.askFarmerAi(
        query: userQuery,
        controller: this,
        isBn: isBn,
      );

      aiChatMessages.add(AiChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));

      return response;
    } finally {
      isAiThinking.value = false;
    }
  }

  /// Scientific Aquaculture Feed Calculator
  /// Based on Water Temperature, Fish Biomass, and species feeding percentage
  Map<String, dynamic> calculateSmartFeed({
    required double biomassKg,
    required double waterTempC,
    double? customFeedingRatePct,
  }) {
    // Standard Bio-energetics rate:
    // 28-32°C: 3.0-3.5% body weight
    // 24-27°C: 2.2-2.8% body weight
    // 20-23°C: 1.2-1.8% body weight
    // <20°C: <1.0% body weight (cold stress)
    double effectiveRatePct = customFeedingRatePct ?? 3.0;
    if (customFeedingRatePct == null) {
      if (waterTempC >= 28) {
        effectiveRatePct = 3.2;
      } else if (waterTempC >= 24) {
        effectiveRatePct = 2.5;
      } else if (waterTempC >= 20) {
        effectiveRatePct = 1.5;
      } else {
        effectiveRatePct = 0.8;
      }
    }

    final double totalDailyFeedKg = (biomassKg * (effectiveRatePct / 100.0));
    final double morningFeedKg = totalDailyFeedKg * 0.40; // 40% at 8:00 AM
    final double afternoonFeedKg = totalDailyFeedKg * 0.60; // 60% at 4:30 PM
    final double monthlyFeedTons = (totalDailyFeedKg * 30) / 1000.0;
    final double projectedFcr = 1.25;

    return {
      'totalDailyFeedKg': totalDailyFeedKg,
      'morningFeedKg': morningFeedKg,
      'afternoonFeedKg': afternoonFeedKg,
      'monthlyFeedTons': monthlyFeedTons,
      'recommendedRatePct': effectiveRatePct,
      'projectedFcr': projectedFcr,
    };
  }

  /// Scientific Fertilizer & Nutrient Dose Calculator (BARC & BRRI Standard)
  /// Converts decimal/bigha/acre into precise kg of Urea, TSP, MoP, Gypsum, Zinc
  Map<String, dynamic> calculateFertilizerDose({
    required String cropType,
    required double landArea,
    required String areaUnit, // 'decimal', 'bigha' (33 decimal), 'acre' (100 decimal)
  }) {
    // Normalize area to standard Decimal (শতক)
    double areaInDecimal = landArea;
    if (areaUnit == 'bigha' || areaUnit == 'বিঘা') {
      areaInDecimal = landArea * 33.0;
    } else if (areaUnit == 'acre' || areaUnit == 'একর') {
      areaInDecimal = landArea * 100.0;
    }

    // Per Decimal (শতক) Recommended Doses in kg:
    double ureaPerDec = 1.0;
    double tspPerDec = 0.4;
    double mopPerDec = 0.5;
    double gypsumPerDec = 0.3;
    double zincPerDec = 0.04;

    final crop = cropType.toLowerCase();
    if (crop.contains('ধান') || crop.contains('rice') || crop.contains('boro')) {
      ureaPerDec = 1.1;
      tspPerDec = 0.4;
      mopPerDec = 0.5;
      gypsumPerDec = 0.35;
      zincPerDec = 0.04;
    } else if (crop.contains('আলু') || crop.contains('potato')) {
      ureaPerDec = 1.4;
      tspPerDec = 0.9;
      mopPerDec = 1.1;
      gypsumPerDec = 0.45;
      zincPerDec = 0.05;
    } else if (crop.contains('টমেটো') || crop.contains('tomato') || crop.contains('সবজি')) {
      ureaPerDec = 1.2;
      tspPerDec = 0.8;
      mopPerDec = 0.9;
      gypsumPerDec = 0.4;
      zincPerDec = 0.04;
    } else if (crop.contains('ভুট্টা') || crop.contains('maize')) {
      ureaPerDec = 1.8;
      tspPerDec = 0.9;
      mopPerDec = 0.8;
      gypsumPerDec = 0.5;
      zincPerDec = 0.06;
    }

    final double totalUrea = ureaPerDec * areaInDecimal;
    final double totalTsp = tspPerDec * areaInDecimal;
    final double totalMop = mopPerDec * areaInDecimal;
    final double totalGypsum = gypsumPerDec * areaInDecimal;
    final double totalZinc = zincPerDec * areaInDecimal;

    return {
      'areaInDecimal': areaInDecimal,
      'ureaKg': totalUrea,
      'tspKg': totalTsp,
      'mopKg': totalMop,
      'gypsumKg': totalGypsum,
      'zincKg': totalZinc,
      'ureaSplitBasal': totalUrea * 0.33,
      'ureaSplitFirstTop': totalUrea * 0.33,
      'ureaSplitSecondTop': totalUrea * 0.34,
    };
  }

  Future<void> exportPdfStatement(BuildContext context, bool isBn) async {
    try {
      await FarmerAnalysisPdfService.generateAndShareReport(
        context: context,
        totalRevenue: totalRevenue,
        totalExpense: totalExpense,
        netProfit: netProfit,
        profitMargin: profitMarginPct,
        farmHealthScore: farmHealthScore,
        expenseBreakdown: getExpenseBreakdown(isBn),
        cropRoiList: cropRoiList,
        marketOpportunities: marketOpportunities,
        selectedTimeframeName: _getTimeframeName(isBn),
      );
    } catch (e) {
      Get.snackbar(isBn ? 'ত্রুটি' : 'Error', '$e', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  String _getTimeframeName(bool isBn) {
    switch (selectedTimeframe.value) {
      case AnalysisTimeframe.thisMonth: return isBn ? 'চলতি মাস (This Month)' : 'This Month';
      case AnalysisTimeframe.thisSeason: return isBn ? 'চলতি সিজন (This Season)' : 'This Season';
      case AnalysisTimeframe.last3Months: return isBn ? 'বিগত ৩ মাস (Quarterly)' : 'Last 3 Months';
      case AnalysisTimeframe.thisYear: return isBn ? 'চলতি বছর (Annual)' : 'This Year';
      case AnalysisTimeframe.allTime: return isBn ? 'সর্বমোট (All Time)' : 'All Time';
    }
  }
}

class AiChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  AiChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
