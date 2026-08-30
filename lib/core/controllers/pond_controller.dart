import 'dart:async';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/pond_model.dart';
import 'dart:math';

class PondController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable list of ponds (Starts completely empty for new users)
  var ponds = <PondModel>[].obs;
  var selectedFilter = 'all'.obs; // 'all', 'optimal', 'warning', 'ready'
  var isLoading = false.obs;

  StreamSubscription<QuerySnapshot>? _pondsSubscription;

  String get currentUserId {
    return _auth.currentUser?.uid ?? 'farmer_demo_user';
  }

  @override
  void onInit() {
    super.onInit();
    _initFirestoreListener();
  }

  @override
  void onClose() {
    _pondsSubscription?.cancel();
    super.onClose();
  }

  void _initFirestoreListener() {
    isLoading.value = true;
    final uid = currentUserId;

    // Listen to real-time Firestore stream for current user's ponds
    _pondsSubscription = _firestore
        .collection('fisheries_ponds')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs.map((doc) {
          return PondModel.fromMap(doc.data(), doc.id);
        }).toList();
        // Sort by stockedDate descending
        list.sort((a, b) => b.stockedDate.compareTo(a.stockedDate));
        ponds.assignAll(list);
      } else {
        // For a new user, keep the list completely clean and blank
        ponds.clear();
      }
      isLoading.value = false;
    }, onError: (error) {
      debugPrint('⚠️ Firestore pond stream error: $error');
      isLoading.value = false;
    });
  }

  // Filtered ponds list
  List<PondModel> get filteredPonds {
    if (selectedFilter.value == 'all') return ponds;
    if (selectedFilter.value == 'optimal') {
      return ponds.where((p) => p.status == 'স্বাভাবিক').toList();
    }
    if (selectedFilter.value == 'warning') {
      return ponds.where((p) => p.status == 'সতর্কতা' || p.status == 'ঝুঁকিপূর্ণ').toList();
    }
    if (selectedFilter.value == 'ready') {
      return ponds.where((p) => p.status == 'হারভেস্ট প্রস্তুত').toList();
    }
    return ponds;
  }

  // Toggle Aerator Hardware Switch & Save to Firestore
  Future<void> toggleAerator(String pondId) async {
    final index = ponds.indexWhere((p) => p.id == pondId);
    if (index != -1) {
      final pond = ponds[index];
      pond.aeratorOn = !pond.aeratorOn;
      if (pond.aeratorOn) {
        pond.dissolvedOxygen = (pond.dissolvedOxygen + 0.8).clamp(0.0, 9.5);
      } else {
        pond.dissolvedOxygen = (pond.dissolvedOxygen - 0.8).clamp(0.0, 9.5);
      }
      ponds[index] = pond;
      update();

      try {
        await _firestore.collection('fisheries_ponds').doc(pondId).update({
          'aeratorOn': pond.aeratorOn,
          'dissolvedOxygen': pond.dissolvedOxygen,
        });
      } catch (e) {
        debugPrint('⚠️ Error updating aerator in Firestore: $e');
      }
    }
  }

  // Toggle Auto Feeder & Save to Firestore
  Future<void> toggleAutoFeeder(String pondId) async {
    final index = ponds.indexWhere((p) => p.id == pondId);
    if (index != -1) {
      final pond = ponds[index];
      pond.autoFeederActive = !pond.autoFeederActive;
      ponds[index] = pond;
      update();

      try {
        await _firestore.collection('fisheries_ponds').doc(pondId).update({
          'autoFeederActive': pond.autoFeederActive,
        });
      } catch (e) {
        debugPrint('⚠️ Error updating auto feeder in Firestore: $e');
      }
    }
  }

  // Add a new pond & Save to Firestore
  Future<PondModel> addPond(
    String name,
    String area,
    String species,
    int fishCount,
    double initialCost, {
    String growthStage = 'নার্সারি ও পোনা',
    double expectedPrice = 350.0,
    String location = 'বাংলাদেশ',
    String? imageUrl,
    String farmCategory = 'বাণিজ্যিক কার্প পুকুর',
    String bioSecurity = 'Grade A+ (শতভাগ রোগমুক্ত)',
    String waterSource = 'নদীর মিষ্টি পানি ও গভীর নলকূপ',
    double avgWeightGrams = 50.0,
    double targetHarvestWeightGrams = 1500.0,
    int totalCycleDays = 120,
    double fcr = 1.25,
    double survivalRatePercent = 95.0,
    double dailyFeedingKg = 25.0,
    String feedBrand = 'মেগা ফিড ভাসমান প্রোটিন ২৮%',
    int aeratorCount = 4,
    String farmManagerName = '',
    String managerPhone = '',
  }) async {
    final String pondId = 'POND_${DateTime.now().millisecondsSinceEpoch}';
    final uid = currentUserId;

    final newPond = PondModel(
      id: pondId,
      userId: uid,
      name: name,
      area: area,
      fishSpecies: species,
      stockedDate: DateTime.now(),
      totalFishCount: fishCount,
      growthStage: growthStage,
      expectedMarketPricePerKg: expectedPrice,
      location: location,
      farmCategory: farmCategory,
      bioSecurityGrade: bioSecurity,
      waterSource: waterSource,
      avgWeightGrams: avgWeightGrams,
      targetHarvestWeightGrams: targetHarvestWeightGrams,
      totalCycleDays: totalCycleDays,
      fcr: fcr,
      survivalRatePercent: survivalRatePercent,
      dailyFeedingKg: dailyFeedingKg,
      feedBrand: feedBrand,
      aeratorCount: aeratorCount,
      aeratorOn: aeratorCount > 0,
      autoFeederActive: true,
      farmManagerName: farmManagerName,
      managerPhone: managerPhone,
      imageUrl: imageUrl ?? 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop&q=80',
    );

    if (initialCost > 0) {
      newPond.activities.add(
        PondActivityModel(
          id: 'ACT_${DateTime.now().millisecondsSinceEpoch}',
          title: 'পোনা ক্রয় ও সেটআপ খরচ',
          description: '$fishCount টি $species পোনা ও পুকুর প্রস্তুতি',
          amount: initialCost,
          date: DateTime.now(),
          type: 'Stock',
        ),
      );
    }

    // Add locally for instant responsive UI
    ponds.insert(0, newPond);
    update();

    // Persist to Firestore
    try {
      await _firestore.collection('fisheries_ponds').doc(pondId).set(newPond.toMap());
    } catch (e) {
      debugPrint('⚠️ Error saving pond to Firestore: $e');
    }

    return newPond;
  }

  // Update existing pond details & Save to Firestore
  Future<void> updatePond(PondModel updatedPond) async {
    final index = ponds.indexWhere((p) => p.id == updatedPond.id);
    if (index != -1) {
      ponds[index] = updatedPond;
    } else {
      ponds.add(updatedPond);
    }
    update();

    try {
      await _firestore.collection('fisheries_ponds').doc(updatedPond.id).update(updatedPond.toMap());
    } catch (e) {
      debugPrint('⚠️ Error updating pond in Firestore: $e');
    }
  }

  // Add an activity (cost/income) to a specific pond & Save to Firestore
  Future<void> addActivity(
    String pondId,
    String title,
    String description,
    double amount,
    String type, {
    bool isIncome = false,
    String performedBy = 'ফার্ম সুপারভাইজার',
    String receiptUrl = '',
  }) async {
    final pondIndex = ponds.indexWhere((p) => p.id == pondId);
    if (pondIndex != -1) {
      final pond = ponds[pondIndex];
      final newActivity = PondActivityModel(
        id: 'ACT_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
        title: title,
        description: description,
        amount: amount,
        date: DateTime.now(),
        type: type,
        isIncome: isIncome,
        performedBy: performedBy,
        invoiceOrReceiptUrl: receiptUrl,
      );

      pond.activities.insert(0, newActivity);
      ponds[pondIndex] = pond;
      update();

      try {
        await _firestore.collection('fisheries_ponds').doc(pondId).update({
          'activities': pond.activities.map((a) => a.toMap()).toList(),
        });
      } catch (e) {
        debugPrint('⚠️ Error saving activity to Firestore: $e');
      }
    }
  }

  // Delete a pond & delete from Firestore
  Future<void> deletePond(String pondId) async {
    ponds.removeWhere((p) => p.id == pondId);
    update();

    try {
      await _firestore.collection('fisheries_ponds').doc(pondId).delete();
    } catch (e) {
      debugPrint('⚠️ Error deleting pond from Firestore: $e');
    }
  }

  // Update pond telemetry & Save to Firestore
  Future<void> updateTelemetry(String pondId, {double? ph, double? doVal, double? ammonia, double? temp}) async {
    final pondIndex = ponds.indexWhere((p) => p.id == pondId);
    if (pondIndex != -1) {
      final pond = ponds[pondIndex];
      if (ph != null) pond.ph = ph;
      if (doVal != null) pond.dissolvedOxygen = doVal;
      if (ammonia != null) pond.ammonia = ammonia;
      if (temp != null) pond.temperature = temp;

      // evaluate status
      if (pond.ammonia > 0.03 || pond.dissolvedOxygen < 5.0 || pond.ph < 6.5) {
        pond.status = 'সতর্কতা';
      } else if (pond.daysRemainingForHarvest <= 15) {
        pond.status = 'হারভেস্ট প্রস্তুত';
      } else {
        pond.status = 'স্বাভাবিক';
      }

      ponds[pondIndex] = pond;
      update();

      try {
        await _firestore.collection('fisheries_ponds').doc(pondId).update({
          'ph': pond.ph,
          'dissolvedOxygen': pond.dissolvedOxygen,
          'ammonia': pond.ammonia,
          'temperature': pond.temperature,
          'status': pond.status,
        });
      } catch (e) {
        debugPrint('⚠️ Error updating telemetry in Firestore: $e');
      }
    }
  }

  // Aggregated Farm Metrics
  double get totalFarmCost {
    return ponds.fold(0.0, (sum, pond) => sum + pond.totalCost);
  }

  double get totalFarmIncome {
    return ponds.fold(0.0, (sum, pond) => sum + pond.totalIncome);
  }

  double get totalFarmBiomassKg {
    return ponds.fold(0.0, (sum, pond) => sum + pond.currentTotalBiomassKg);
  }

  double get totalFarmValuation {
    return ponds.fold(0.0, (sum, pond) => sum + pond.projectedValuation);
  }

  int get totalStockCount {
    return ponds.fold(0, (sum, pond) => sum + pond.totalFishCount);
  }

  double get averageDissolvedOxygen {
    if (ponds.isEmpty) return 0.0;
    return ponds.fold(0.0, (sum, pond) => sum + pond.dissolvedOxygen) / ponds.length;
  }
}
