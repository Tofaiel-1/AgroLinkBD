import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:agrolinkbd/core/controllers/user_controller.dart';
import '../models/pond_model.dart';

class PondController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable list of ponds
  var ponds = <PondModel>[].obs;
  var selectedFilter = 'all'.obs; // 'all', 'optimal', 'warning', 'ready'
  var isLoading = false.obs;

  StreamSubscription<QuerySnapshot>? _pondsSubscription;
  StreamSubscription<User?>? _authSubscription;
  String? _lastBoundUid;

  String get currentUserId {
    final authUid = _auth.currentUser?.uid;
    if (authUid != null && authUid.isNotEmpty) return authUid;
    if (Get.isRegistered<UserController>()) {
      final userCtrl = Get.find<UserController>();
      if (userCtrl.userId.isNotEmpty) return userCtrl.userId;
    }
    return 'farmer_demo_user';
  }

  String get _cacheKey => 'cached_ponds_${currentUserId}';

  CollectionReference<Map<String, dynamic>> _userPondsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('ponds');
  }

  CollectionReference<Map<String, dynamic>> get _globalPondsRef {
    return _firestore.collection('fisheries_ponds');
  }

  @override
  void onInit() {
    super.onInit();
    _lastBoundUid = currentUserId;
    _loadFromLocalCache();
    _initFirestoreListener();

    // Dynamically re-bind when auth state changes (login, logout, switch user)
    _authSubscription = _auth.authStateChanges().listen((user) {
      final uid = user?.uid ?? (Get.isRegistered<UserController>() ? Get.find<UserController>().userId : '');
      if (uid.isNotEmpty && uid != _lastBoundUid) {
        _lastBoundUid = uid;
        _reinitForActiveUser();
      }
    });
  }

  @override
  void onClose() {
    _pondsSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  /// Re-initialize cache and Firestore stream when user logs in or switches
  Future<void> _reinitForActiveUser() async {
    _pondsSubscription?.cancel();
    ponds.clear();
    await _loadFromLocalCache();
    _initFirestoreListener();
  }

  /// Load cached ponds from SharedPreferences for instant UI response
  Future<void> _loadFromLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(cachedJson);
        final list = decoded.map((item) {
          return PondModel.fromMap(Map<String, dynamic>.from(item as Map));
        }).toList();
        list.sort((a, b) => b.stockedDate.compareTo(a.stockedDate));
        if (list.isNotEmpty && ponds.isEmpty) {
          ponds.assignAll(list);
          update();
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error loading ponds from local cache: $e');
    }
  }

  /// Persist ponds to SharedPreferences
  Future<void> _saveToLocalCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encodedList = ponds.map((p) => p.toMap(forLocalCache: true)).toList();
      await prefs.setString(_cacheKey, jsonEncode(encodedList));
    } catch (e) {
      debugPrint('⚠️ Error saving ponds to local cache: $e');
    }
  }

  /// Listen to real-time Firestore stream from the user's self database
  void _initFirestoreListener() {
    isLoading.value = true;
    final uid = currentUserId;

    try {
      // Primary: Listen to user's dedicated self-database subcollection: users/{userId}/ponds
      _pondsSubscription = _userPondsRef(uid)
          .snapshots()
          .listen((snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs.map((doc) {
            return PondModel.fromMap(doc.data(), doc.id);
          }).toList();
          list.sort((a, b) => b.stockedDate.compareTo(a.stockedDate));
          ponds.assignAll(list);
          await _saveToLocalCache();
        } else {
          // If self database is empty, check global fisheries_ponds for backward compatibility & auto-migrate
          await _checkAndMigrateFromGlobalCollection(uid);
        }
        isLoading.value = false;
        update();
      }, onError: (error) {
        debugPrint('⚠️ Firestore pond stream error on self-database: $error');
        // Fallback: try listening to global fisheries_ponds
        _initGlobalFallbackListener(uid);
      });
    } catch (e) {
      debugPrint('⚠️ Error initializing self-database listener: $e');
      _initGlobalFallbackListener(uid);
    }
  }

  /// Fallback listener on global collection if user subcollection has issues
  void _initGlobalFallbackListener(String uid) {
    try {
      _pondsSubscription?.cancel();
      _pondsSubscription = _globalPondsRef
          .where('userId', isEqualTo: uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs.map((doc) {
            return PondModel.fromMap(doc.data(), doc.id);
          }).toList();
          list.sort((a, b) => b.stockedDate.compareTo(a.stockedDate));
          ponds.assignAll(list);
          _saveToLocalCache();
        }
        isLoading.value = false;
        update();
      }, onError: (e) {
        debugPrint('⚠️ Fallback global stream error: $e');
        isLoading.value = false;
      });
    } catch (e) {
      debugPrint('⚠️ Error initializing fallback listener: $e');
      isLoading.value = false;
    }
  }

  /// Seamlessly migrates any existing ponds from global fisheries_ponds to the user's self-database
  Future<void> _checkAndMigrateFromGlobalCollection(String uid) async {
    try {
      final globalQuery = await _globalPondsRef
          .where('userId', isEqualTo: uid)
          .get()
          .timeout(const Duration(seconds: 5));

      if (globalQuery.docs.isNotEmpty) {
        final list = globalQuery.docs.map((doc) {
          return PondModel.fromMap(doc.data(), doc.id);
        }).toList();
        list.sort((a, b) => b.stockedDate.compareTo(a.stockedDate));
        ponds.assignAll(list);
        await _saveToLocalCache();

        // Migrate into user's self database
        for (final doc in globalQuery.docs) {
          try {
            await _userPondsRef(uid).doc(doc.id).set(doc.data(), SetOptions(merge: true));
          } catch (_) {}
        }
        debugPrint('✅ Migrated ${globalQuery.docs.length} ponds to user self-database');
      } else if (ponds.isEmpty) {
        ponds.clear();
      }
    } catch (e) {
      debugPrint('ℹ️ Migration check skipped/error: $e');
    }
  }

  /// Manual pull-to-refresh
  Future<void> refreshPonds() async {
    isLoading.value = true;
    final uid = currentUserId;
    try {
      final snapshot = await _userPondsRef(uid).get().timeout(const Duration(seconds: 6));
      if (snapshot.docs.isNotEmpty) {
        final list = snapshot.docs.map((doc) => PondModel.fromMap(doc.data(), doc.id)).toList();
        list.sort((a, b) => b.stockedDate.compareTo(a.stockedDate));
        ponds.assignAll(list);
        await _saveToLocalCache();
      } else {
        await _checkAndMigrateFromGlobalCollection(uid);
      }
    } catch (e) {
      debugPrint('⚠️ Refresh ponds error: $e');
      await _loadFromLocalCache();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Filtered ponds list
  List<PondModel> get filteredPonds {
    if (selectedFilter.value == 'all') return ponds;
    if (selectedFilter.value == 'optimal') {
      return ponds.where((p) => p.status == 'স্বাভাবিক' || p.status == 'Optimal').toList();
    }
    if (selectedFilter.value == 'warning') {
      return ponds.where((p) => p.status == 'সতর্কতা' || p.status == 'ঝুঁকিপূর্ণ' || p.status == 'Warning' || p.status == 'Critical').toList();
    }
    if (selectedFilter.value == 'ready') {
      return ponds.where((p) => p.status == 'হারভেস্ট প্রস্তুত' || p.status == 'Ready to Harvest').toList();
    }
    return ponds;
  }

  // Toggle Aerator Hardware Switch & Save to both self database & global collection
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
      _saveToLocalCache();

      final updateData = {
        'aeratorOn': pond.aeratorOn,
        'dissolvedOxygen': pond.dissolvedOxygen,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final uid = pond.userId.isNotEmpty ? pond.userId : currentUserId;
      _updateInSelfAndGlobal(uid, pondId, updateData);
    }
  }

  // Toggle Auto Feeder & Save to both self database & global collection
  Future<void> toggleAutoFeeder(String pondId) async {
    final index = ponds.indexWhere((p) => p.id == pondId);
    if (index != -1) {
      final pond = ponds[index];
      pond.autoFeederActive = !pond.autoFeederActive;
      ponds[index] = pond;
      update();
      _saveToLocalCache();

      final updateData = {
        'autoFeederActive': pond.autoFeederActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final uid = pond.userId.isNotEmpty ? pond.userId : currentUserId;
      _updateInSelfAndGlobal(uid, pondId, updateData);
    }
  }

  // Add a new pond & Save to Self Database (users/{uid}/ponds) + Global Index + Local Cache
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

    // 1. Add locally for instant responsive UI & persist to offline cache
    ponds.insert(0, newPond);
    update();
    await _saveToLocalCache();

    // 2. Persist to Firestore: User's Self Database + Global Collection
    final pondMap = newPond.toMap();
    try {
      final batch = _firestore.batch();
      batch.set(_userPondsRef(uid).doc(pondId), pondMap);
      batch.set(_globalPondsRef.doc(pondId), pondMap);
      await batch.commit();
      debugPrint('✅ Pond saved to self-database & global collection: $pondId for user: $uid');
    } catch (e) {
      debugPrint('⚠️ Batch save failed, executing resilient individual saves: $e');
      try {
        await _userPondsRef(uid).doc(pondId).set(pondMap, SetOptions(merge: true));
        debugPrint('✅ Saved to user self-database: $pondId');
      } catch (e1) {
        debugPrint('⚠️ Error saving to user self-database: $e1');
      }
      try {
        await _globalPondsRef.doc(pondId).set(pondMap, SetOptions(merge: true));
        debugPrint('✅ Saved to global collection: $pondId');
      } catch (e2) {
        debugPrint('⚠️ Error saving to global collection: $e2');
      }
    }

    return newPond;
  }

  // Update existing pond details & Save to both self database & global collection
  Future<void> updatePond(PondModel updatedPond) async {
    final index = ponds.indexWhere((p) => p.id == updatedPond.id);
    if (index != -1) {
      ponds[index] = updatedPond;
    } else {
      ponds.add(updatedPond);
    }
    update();
    await _saveToLocalCache();

    final uid = updatedPond.userId.isNotEmpty ? updatedPond.userId : currentUserId;
    final pondMap = updatedPond.toMap();

    try {
      final batch = _firestore.batch();
      batch.set(_userPondsRef(uid).doc(updatedPond.id), pondMap, SetOptions(merge: true));
      batch.set(_globalPondsRef.doc(updatedPond.id), pondMap, SetOptions(merge: true));
      await batch.commit();
      debugPrint('✅ Pond updated in self-database & global collection: ${updatedPond.id}');
    } catch (e) {
      debugPrint('⚠️ Batch update failed, attempting individual updates: $e');
      try {
        await _userPondsRef(uid).doc(updatedPond.id).set(pondMap, SetOptions(merge: true));
      } catch (_) {}
      try {
        await _globalPondsRef.doc(updatedPond.id).set(pondMap, SetOptions(merge: true));
      } catch (_) {}
    }
  }

  // Add an activity (cost/income) to a specific pond & Save to both databases
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
      await _saveToLocalCache();

      final activitiesData = pond.activities.map((a) => a.toMap()).toList();
      final updateData = {
        'activities': activitiesData,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final uid = pond.userId.isNotEmpty ? pond.userId : currentUserId;
      _updateInSelfAndGlobal(uid, pondId, updateData);
    }
  }

  // Delete a pond from both databases
  Future<void> deletePond(String pondId) async {
    final pondIndex = ponds.indexWhere((p) => p.id == pondId);
    final uid = pondIndex != -1 && ponds[pondIndex].userId.isNotEmpty 
        ? ponds[pondIndex].userId 
        : currentUserId;

    ponds.removeWhere((p) => p.id == pondId);
    update();
    await _saveToLocalCache();

    try {
      final batch = _firestore.batch();
      batch.delete(_userPondsRef(uid).doc(pondId));
      batch.delete(_globalPondsRef.doc(pondId));
      await batch.commit();
      debugPrint('✅ Deleted pond from self-database & global collection: $pondId');
    } catch (e) {
      debugPrint('⚠️ Batch delete failed, attempting individual delete: $e');
      try {
        await _userPondsRef(uid).doc(pondId).delete();
      } catch (_) {}
      try {
        await _globalPondsRef.doc(pondId).delete();
      } catch (_) {}
    }
  }

  // Update pond telemetry & Save to both databases
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
      await _saveToLocalCache();

      final updateData = {
        'ph': pond.ph,
        'dissolvedOxygen': pond.dissolvedOxygen,
        'ammonia': pond.ammonia,
        'temperature': pond.temperature,
        'status': pond.status,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final uid = pond.userId.isNotEmpty ? pond.userId : currentUserId;
      _updateInSelfAndGlobal(uid, pondId, updateData);
    }
  }

  // Helper to update fields in both self database and global collection
  Future<void> _updateInSelfAndGlobal(String uid, String pondId, Map<String, dynamic> data) async {
    try {
      final batch = _firestore.batch();
      batch.update(_userPondsRef(uid).doc(pondId), data);
      batch.update(_globalPondsRef.doc(pondId), data);
      await batch.commit();
    } catch (e) {
      debugPrint('⚠️ Batch update error, attempting individual updates: $e');
      try {
        await _userPondsRef(uid).doc(pondId).update(data);
      } catch (_) {}
      try {
        await _globalPondsRef.doc(pondId).update(data);
      } catch (_) {}
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
