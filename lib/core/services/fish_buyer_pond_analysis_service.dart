import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/fish_buyer_pond_analysis_model.dart';

class VerifiedCommercialPond {
  final String id;
  final String pondName;
  final String farmerName;
  final String farmerPhone;
  final String farmLocation;
  final String district;
  final String upazila;
  final String fishSpecies;
  final double pondSizeDecimal;
  final int totalFishCount;
  final double avgWeightGram;
  final double dissolvedOxygen;
  final double phLevel;
  final double ammoniaPpm;
  final double salinityPpt;
  final double waterDepthFeet;
  final double farmerAskingPricePerKg;
  final double defaultMarketSalePricePerKg;
  final bool isFormalinFree;
  final bool isOrganicFeed;
  final String imageUrl;
  final DateTime expectedHarvestDate;
  final String status;

  VerifiedCommercialPond({
    required this.id,
    required this.pondName,
    required this.farmerName,
    required this.farmerPhone,
    required this.farmLocation,
    required this.district,
    required this.upazila,
    required this.fishSpecies,
    required this.pondSizeDecimal,
    required this.totalFishCount,
    required this.avgWeightGram,
    required this.dissolvedOxygen,
    required this.phLevel,
    required this.ammoniaPpm,
    required this.salinityPpt,
    required this.waterDepthFeet,
    required this.farmerAskingPricePerKg,
    required this.defaultMarketSalePricePerKg,
    required this.isFormalinFree,
    required this.isOrganicFeed,
    required this.imageUrl,
    required this.expectedHarvestDate,
    this.status = 'Ready for Harvest',
  });

  double get estimatedTotalKg => (totalFishCount * avgWeightGram) / 1000.0;
  double get estimatedTotalMaunds => estimatedTotalKg / 40.0;
}

class FishBuyerPondAnalysisService extends GetxController {
  static FishBuyerPondAnalysisService get to => Get.find<FishBuyerPondAnalysisService>();

  final RxList<VerifiedCommercialPond> verifiedPonds = <VerifiedCommercialPond>[].obs;
  final RxList<FishBuyerPondAnalysisModel> savedAnalyses = <FishBuyerPondAnalysisModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSampleVerifiedPonds();
    _initFirestoreAnalysesStream();
  }

  void _loadSampleVerifiedPonds() {
    verifiedPonds.assignAll([
      VerifiedCommercialPond(
        id: 'POND-V-101',
        pondName: 'পুকুর-১ (চলনবিল গ্র্যান্ড দিঘি)',
        farmerName: 'মোঃ কুদ্দুস আলী',
        farmerPhone: '01711223344',
        farmLocation: 'সিংড়া বাজার, চলনবিল',
        district: 'নাটোর',
        upazila: 'সিংড়া',
        fishSpecies: 'দেশি রুই ও কাতলা (বড় সাইজ)',
        pondSizeDecimal: 80.0,
        totalFishCount: 2000,
        avgWeightGram: 1850.0, // 1.85 kg
        dissolvedOxygen: 7.2,
        phLevel: 7.6,
        ammoniaPpm: 0.01,
        salinityPpt: 0.0,
        waterDepthFeet: 6.0,
        farmerAskingPricePerKg: 320.0,
        defaultMarketSalePricePerKg: 380.0,
        isFormalinFree: true,
        isOrganicFeed: true,
        imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505454/images_jzjue9.jpg',
        expectedHarvestDate: DateTime.now().add(const Duration(days: 7)),
      ),
      VerifiedCommercialPond(
        id: 'POND-V-102',
        pondName: 'ঘের নং-৩ (শ্যামনগর বাগদা হাব)',
        farmerName: 'হাজী রফিকুল ইসলাম',
        farmerPhone: '01988776655',
        farmLocation: 'বুড়িগোয়ালিনী, শ্যামনগর',
        district: 'সাতক্ষীরা',
        upazila: 'শ্যামনগর',
        fishSpecies: 'রপ্তানি গ্রেড জম্বো বাগদা চিংড়ি',
        pondSizeDecimal: 120.0,
        totalFishCount: 8000,
        avgWeightGram: 50.0, // 20 pcs/kg
        dissolvedOxygen: 6.8,
        phLevel: 8.0,
        ammoniaPpm: 0.02,
        salinityPpt: 15.0,
        waterDepthFeet: 4.5,
        farmerAskingPricePerKg: 880.0,
        defaultMarketSalePricePerKg: 980.0,
        isFormalinFree: true,
        isOrganicFeed: true,
        imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505088/images_yhiizh.jpg',
        expectedHarvestDate: DateTime.now().add(const Duration(days: 4)),
      ),
      VerifiedCommercialPond(
        id: 'POND-V-103',
        pondName: 'পাবদা ও গুলশা প্রজেক্ট-২',
        farmerName: 'কামাল হোসেন চৌধুরী',
        farmerPhone: '01677889900',
        farmLocation: 'ত্রিশাল ফিশারি জোন',
        district: 'ময়মনসিংহ',
        upazila: 'ত্রিশাল',
        fishSpecies: 'দেশি পাবদা ও গুলশা টেংরা',
        pondSizeDecimal: 50.0,
        totalFishCount: 5000,
        avgWeightGram: 120.0,
        dissolvedOxygen: 7.5,
        phLevel: 7.4,
        ammoniaPpm: 0.01,
        salinityPpt: 0.0,
        waterDepthFeet: 5.0,
        farmerAskingPricePerKg: 420.0,
        defaultMarketSalePricePerKg: 490.0,
        isFormalinFree: true,
        isOrganicFeed: true,
        imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505500/images_f9axtg.jpg',
        expectedHarvestDate: DateTime.now().add(const Duration(days: 10)),
      ),
      VerifiedCommercialPond(
        id: 'POND-V-104',
        pondName: 'হালদা নদীর প্রাকৃতিক পোনা গ্রো-আউট',
        farmerName: 'মোঃ মোরশেদ আলম',
        farmerPhone: '01811998877',
        farmLocation: 'হাটহাজারী হালদা পাড়',
        district: 'চট্টগ্রাম',
        upazila: 'হাটহাজারী',
        fishSpecies: 'হালদার খাঁটি কাতলা ও মৃগেল',
        pondSizeDecimal: 100.0,
        totalFishCount: 1500,
        avgWeightGram: 2500.0, // 2.5 kg
        dissolvedOxygen: 8.1,
        phLevel: 7.8,
        ammoniaPpm: 0.01,
        salinityPpt: 0.0,
        waterDepthFeet: 7.0,
        farmerAskingPricePerKg: 350.0,
        defaultMarketSalePricePerKg: 420.0,
        isFormalinFree: true,
        isOrganicFeed: true,
        imageUrl: 'https://res.cloudinary.com/dbbvlg2dz/image/upload/v1788505305/images_l53fvw.jpg',
        expectedHarvestDate: DateTime.now().add(const Duration(days: 12)),
      ),
    ]);
  }

  void _initFirestoreAnalysesStream() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      FirebaseFirestore.instance
          .collection('buyer_pond_analyses')
          .where('buyerId', isEqualTo: user.uid)
          .snapshots()
          .listen((snapshot) {
        final List<FishBuyerPondAnalysisModel> list = [];
        for (var doc in snapshot.docs) {
          try {
            final data = doc.data();
            data['id'] = doc.id;
            list.add(FishBuyerPondAnalysisModel.fromJson(data));
          } catch (_) {}
        }
        savedAnalyses.assignAll(list);
      }, onError: (_) {});
    } catch (_) {}
  }

  // --- CALCULATION ENGINES ---

  static Map<String, dynamic> computeBiomass({
    required double decimal,
    required int fishCount,
    required double avgWeightGram,
  }) {
    final double totalYieldKg = (fishCount * avgWeightGram) / 1000.0;
    final double totalMaunds = totalYieldKg / 40.0;
    final double totalTons = totalYieldKg / 1000.0;
    final double densityPerDecimal = fishCount / (decimal > 0 ? decimal : 1.0);

    return {
      'totalYieldKg': totalYieldKg,
      'totalMaunds': totalMaunds,
      'totalTons': totalTons,
      'densityPerDecimal': densityPerDecimal,
    };
  }

  static Map<String, dynamic> computeWholesaleRoi({
    required double yieldKg,
    required double farmerPricePerKg,
    required double targetMarketSalePricePerKg,
    required double transportPackagingCostPerKg,
    required double shrinkagePercent, // e.g. 2.0%
  }) {
    final double effectiveYieldKg = yieldKg * (1.0 - (shrinkagePercent / 100.0));
    final double totalFarmerCost = yieldKg * farmerPricePerKg;
    final double totalLogisticsCost = yieldKg * transportPackagingCostPerKg;
    final double totalProcurementCost = totalFarmerCost + totalLogisticsCost;

    final double netLandingCostPerKg = totalProcurementCost / (effectiveYieldKg > 0 ? effectiveYieldKg : 1.0);
    final double totalGrossRevenue = effectiveYieldKg * targetMarketSalePricePerKg;
    final double projectedNetProfit = totalGrossRevenue - totalProcurementCost;
    final double roiPercentage = totalProcurementCost > 0
        ? (projectedNetProfit / totalProcurementCost) * 100.0
        : 0.0;

    return {
      'effectiveYieldKg': effectiveYieldKg,
      'totalProcurementCost': totalProcurementCost,
      'netLandingCostPerKg': netLandingCostPerKg,
      'totalGrossRevenue': totalGrossRevenue,
      'projectedNetProfit': projectedNetProfit,
      'roiPercentage': roiPercentage,
    };
  }

  static int computeSafetyScore({
    required double dissolvedOxygen,
    required double phLevel,
    required double ammoniaPpm,
    required bool isFormalinFree,
    required bool isOrganicFeed,
  }) {
    int score = 50;
    if (isFormalinFree) score += 20;
    if (isOrganicFeed) score += 10;
    if (dissolvedOxygen >= 6.0) score += 10;
    if (phLevel >= 7.2 && phLevel <= 8.2) score += 5;
    if (ammoniaPpm <= 0.03) score += 5;
    return score.clamp(0, 100);
  }

  // --- ACTIONS ---

  Future<bool> saveAnalysisReport(FishBuyerPondAnalysisModel model) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('buyer_pond_analyses').doc(model.id);
      
      await docRef.set(model.toJson(), SetOptions(merge: true));
      
      final index = savedAnalyses.indexWhere((a) => a.id == model.id);
      if (index != -1) {
        savedAnalyses[index] = model;
      } else {
        savedAnalyses.insert(0, model);
      }
      savedAnalyses.refresh();
      return true;
    } catch (_) {
      final index = savedAnalyses.indexWhere((a) => a.id == model.id);
      if (index != -1) {
        savedAnalyses[index] = model;
      } else {
        savedAnalyses.insert(0, model);
      }
      savedAnalyses.refresh();
      return true;
    }
  }

  Future<bool> requestSampleInspection({
    required String analysisId,
    required String pondName,
    required String farmerPhone,
    required DateTime preferredDate,
    required String notes,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final reqId = 'INSP_${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance.collection('sample_inspection_requests').doc(reqId).set({
        'id': reqId,
        'analysisId': analysisId,
        'buyerId': user?.uid ?? 'buyer_demo',
        'buyerName': user?.displayName ?? 'Wholesale Buyer',
        'buyerPhone': user?.phoneNumber ?? '01700000000',
        'pondName': pondName,
        'farmerPhone': farmerPhone,
        'preferredDate': preferredDate.toIso8601String(),
        'notes': notes,
        'status': 'Requested',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update local analysis status if exists
      final index = savedAnalyses.indexWhere((a) => a.id == analysisId);
      if (index != -1) {
        final current = savedAnalyses[index];
        savedAnalyses[index] = FishBuyerPondAnalysisModel(
          id: current.id,
          buyerId: current.buyerId,
          buyerName: current.buyerName,
          pondId: current.pondId,
          pondName: current.pondName,
          farmerName: current.farmerName,
          location: current.location,
          district: current.district,
          fishSpecies: current.fishSpecies,
          pondSizeDecimal: current.pondSizeDecimal,
          totalEstimatedCount: current.totalEstimatedCount,
          avgWeightGram: current.avgWeightGram,
          estimatedTotalYieldKg: current.estimatedTotalYieldKg,
          uniformityPercentage: current.uniformityPercentage,
          grade: current.grade,
          dissolvedOxygen: current.dissolvedOxygen,
          phLevel: current.phLevel,
          ammoniaPpm: current.ammoniaPpm,
          salinityPpt: current.salinityPpt,
          waterDepthFeet: current.waterDepthFeet,
          isFormalinFree: current.isFormalinFree,
          isOrganicFeed: current.isOrganicFeed,
          safetyScore: current.safetyScore,
          farmerAskingPricePerKg: current.farmerAskingPricePerKg,
          targetMarketSalePricePerKg: current.targetMarketSalePricePerKg,
          transportPackagingCostPerKg: current.transportPackagingCostPerKg,
          shrinkagePercentage: current.shrinkagePercentage,
          netLandingCostPerKg: current.netLandingCostPerKg,
          projectedNetProfit: current.projectedNetProfit,
          projectedRoiPercentage: current.projectedRoiPercentage,
          sampleRequested: true,
          sampleStatus: 'pending',
          inspectorNotes: 'ফিল্ড অফিসার অ্যাসাইনমেন্ট প্রক্রিয়াধীন',
          createdAt: current.createdAt,
        );
        savedAnalyses.refresh();
      }

      return true;
    } catch (_) {
      return true;
    }
  }
}
